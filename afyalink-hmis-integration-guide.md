# Integrating a PHP/Laravel HMIS with Kenya's AfyaLink HIE

A working developer walkthrough: auth → registries → eligibility → claims.

Base URL (sandbox/UAT): `https://uat.dha.go.ke`
Production base URL: issued to you after certification + security review — same paths, different host.

> **The one thing that will break your integration if you miss it:** the JWT token from `/v1/hie-auth` expires after **20 seconds**. Do not cache it like a normal OAuth token. Fetch a fresh one immediately before every downstream call (or a few seconds before, at most). The architecture below builds this in from the start so you don't have to remember it in every controller.

---

## 0. Prerequisites (do these before writing code)

1. **Register on Afyayangu first** — `https://afyayangu.go.ke/` — this is a hard prerequisite for AfyaLink registration.
2. **Register on the AfyaLink developer portal** — `https://developer.dha.go.ke/register`. This gets you a **sandbox** environment immediately.
3. From your AfyaLink dashboard, request API access for your organization/system. Once approved you'll receive a **credential set**:
   - `consumer_key` + `consumer_secret` — used to generate tokens
   - `agent` — a string identifier unique to your facility/system (never use the generic `SAFARICOM-CONSORTIUM-SANDBOX` value from docs examples in real integration — use the one issued to you)
   - a **public key** (used by AfyaLink to encrypt data sent to you) and your own **private key** (used by you to decrypt it) — needed for any endpoint that returns sensitive patient data
4. Separately, apply for **DHA certification** of your HMIS itself (Form HMIS 4, via `certification.dha.go.ke`) — this runs in parallel with your dev work but is required before you're allowed into production.

---

## 1. Laravel project structure

```
app/
  Services/
    AfyaLink/
      AfyaLinkAuthService.php        # token generation
      AfyaLinkClient.php             # low-level HTTP wrapper
      ClientRegistryService.php      # patient search/fetch/update
      FacilityRegistryService.php
      PractitionerRegistryService.php
      EligibilityService.php
      ClaimsService.php              # FHIR bundle build + submit + poll
      Support/
        FhirBundleBuilder.php
        AfyaLinkEncryption.php
  Jobs/
    PollClaimStatus.php
  Models/
    HieClientCache.php
    HieClaimSubmission.php
config/
  afyalink.php
database/migrations/
  xxxx_create_hie_client_cache_table.php
  xxxx_create_hie_claim_submissions_table.php
```

---

## 2. Configuration

`.env`

```env
AFYALINK_BASE_URL=https://uat.dha.go.ke
AFYALINK_CONSUMER_KEY=your_consumer_key
AFYALINK_CONSUMER_SECRET=your_consumer_secret
AFYALINK_AGENT=YOUR-ASSIGNED-AGENT-ID
AFYALINK_PRIVATE_KEY_PATH=storage/keys/afyalink_private.pem
AFYALINK_BACKEND_PUBLIC_KEY_PATH=storage/keys/afyalink_backend_public.pem
```

Never commit the keys or `.env`. Store the PEM files outside version control, ideally pulled from a secrets manager at deploy time.

`config/afyalink.php`

```php
<?php

return [
    'base_url' => env('AFYALINK_BASE_URL', 'https://uat.dha.go.ke'),
    'consumer_key' => env('AFYALINK_CONSUMER_KEY'),
    'consumer_secret' => env('AFYALINK_CONSUMER_SECRET'),
    'agent' => env('AFYALINK_AGENT'),
    'private_key_path' => env('AFYALINK_PRIVATE_KEY_PATH'),
    'backend_public_key_path' => env('AFYALINK_BACKEND_PUBLIC_KEY_PATH'),
    'token_ttl_seconds' => 18, // stay under the real 20s expiry with a safety margin
];
```

---

## 3. Authentication service

`GET /v1/hie-auth?key={consumer_key}` with a `Basic` auth header (base64 `username:password` — in AfyaLink's case this is generally `consumer_key:consumer_secret`) returns a JWT valid for ~20 seconds.

```php
<?php

namespace App\Services\AfyaLink;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Cache;

class AfyaLinkAuthService
{
    public function getToken(): string
    {
        // Deliberately NOT cached beyond a couple seconds — token lifetime is ~20s.
        return Cache::remember('afyalink_token', now()->addSeconds(config('afyalink.token_ttl_seconds')), function () {
            $response = Http::withBasicAuth(
                    config('afyalink.consumer_key'),
                    config('afyalink.consumer_secret')
                )
                ->get(config('afyalink.base_url') . '/v1/hie-auth', [
                    'key' => config('afyalink.consumer_key'),
                ]);

            if (! $response->successful()) {
                throw new \RuntimeException('Failed to obtain AfyaLink token: ' . $response->body());
            }

            return $response->json('token');
        });
    }

    /**
     * Forces a fresh token, bypassing cache. Use this if a call fails
     * with a 401 mid-request — the 18s window may have lapsed.
     */
    public function refreshToken(): string
    {
        Cache::forget('afyalink_token');
        return $this->getToken();
    }
}
```

**Why cache for even 18 seconds instead of fetching per-call?** Because a single logical operation (e.g. "submit a claim") often needs 2–3 sequential calls (fetch practitioner → fetch client → submit bundle). Caching for a few seconds avoids hammering the auth endpoint while staying safely inside the 20s window. If you're doing anything slower than that, refresh.

---

## 4. Low-level HTTP client with auto-retry-on-401

```php
<?php

namespace App\Services\AfyaLink;

use Illuminate\Support\Facades\Http;
use Illuminate\Http\Client\PendingRequest;
use Illuminate\Http\Client\Response;

class AfyaLinkClient
{
    public function __construct(private AfyaLinkAuthService $auth) {}

    protected function request(): PendingRequest
    {
        return Http::baseUrl(config('afyalink.base_url'))
            ->withToken($this->auth->getToken())
            ->withHeaders(['Content-Type' => 'application/json'])
            ->timeout(15);
    }

    public function get(string $uri, array $query = []): Response
    {
        $response = $this->request()->get($uri, $query);

        if ($response->status() === 401) {
            // token likely expired mid-flight — refresh once and retry
            $response = Http::baseUrl(config('afyalink.base_url'))
                ->withToken($this->auth->refreshToken())
                ->withHeaders(['Content-Type' => 'application/json'])
                ->get($uri, $query);
        }

        return $response;
    }

    public function post(string $uri, array $body = []): Response
    {
        $response = $this->request()->post($uri, $body);

        if ($response->status() === 401) {
            $response = Http::baseUrl(config('afyalink.base_url'))
                ->withToken($this->auth->refreshToken())
                ->withHeaders(['Content-Type' => 'application/json'])
                ->post($uri, $body);
        }

        return $response;
    }

    public function put(string $uri, array $body = []): Response
    {
        return $this->request()->put($uri, $body);
    }
}
```

Bind it as a singleton in `AppServiceProvider`:

```php
$this->app->singleton(AfyaLinkClient::class);
```

---

## 5. Client Registry (patient search / fetch / update)

Endpoint: `GET /v3/client-registry/fetch-client?identification_type=...&identification_number=...&agent=...`

```php
<?php

namespace App\Services\AfyaLink;

use App\Models\HieClientCache;

class ClientRegistryService
{
    public function __construct(private AfyaLinkClient $client) {}

    public function fetchByIdentifier(string $idType, string $idNumber): ?array
    {
        $response = $this->client->get('/v3/client-registry/fetch-client', [
            'identification_type' => $idType,       // e.g. "National ID"
            'identification_number' => $idNumber,
            'agent' => config('afyalink.agent'),
        ]);

        if (! $response->successful()) {
            return null;
        }

        $patient = $response->json();

        // Cache locally so subsequent visits don't re-hit the API for
        // every screen render — refresh periodically, not on every page load.
        HieClientCache::updateOrCreate(
            ['cr_id' => $patient['id'] ?? null],
            [
                'identification_type' => $idType,
                'identification_number' => $idNumber,
                'payload' => $patient,
                'synced_at' => now(),
            ]
        );

        return $patient;
    }

    public function update(string $crId, array $fields): bool
    {
        $response = $this->client->put("/v3/client-registry/{$crId}", $fields);
        return $response->successful();
    }
}
```

**Always search before you register/create locally** — the docs explicitly flag duplicate-record creation as the main data-quality risk in the Client Registry. Your patient-registration screen in the HMIS should call `fetchByIdentifier()` first (by National ID, then by SHA/CR number as fallback) before falling back to a manual "new patient" form.

The Patient resource returned includes demographics, county/sub-county/ward, other identifications (SHA number, household number, KRA PIN), and eligibility-relevant fields — map these into your existing patients table via a translation layer rather than reshaping your schema around AfyaLink's field names.

---

## 6. Facility Registry

```php
<?php

namespace App\Services\AfyaLink;

class FacilityRegistryService
{
    public function __construct(private AfyaLinkClient $client) {}

    public function findByCode(string $facilityCode): ?array
    {
        $response = $this->client->get('/v1/facility-search', [
            'facility_code' => $facilityCode,
        ]);

        return $response->successful() ? $response->json('message') : null;
    }
}
```

Sample response shape (fields can be null — handle that defensively before you gate any workflow on them):

```json
{
  "message": {
    "facility_code": "24749",
    "found": 1,
    "approved": null,
    "facility_level": null,
    "operational_status": null,
    "current_license_expiry_date": ""
  }
}
```

Cache facility lookups aggressively (they change rarely) — a daily-refreshed local table is fine.

---

## 7. Health Worker / Practitioner Registry

```php
<?php

namespace App\Services\AfyaLink;

class PractitionerRegistryService
{
    public function __construct(private AfyaLinkClient $client) {}

    public function verify(string $idType, string $idNumber): ?array
    {
        $response = $this->client->get('/v1/practitioner-search', [
            'identification_type' => $idType,     // "ID"
            'identification_number' => $idNumber,
        ]);

        return $response->successful() ? $response->json('message') : null;
    }
}
```

Response:

```json
{ "message": { "registration_number": 40675898, "found": 1, "is_active": "yes" } }
```

Use this at staff-onboarding time (verify a clinician's license before granting them prescribing/claims rights in your HMIS) rather than on every single claim — cache the verification result against the staff record with a re-check interval (e.g. every 90 days), since license status doesn't change per-visit.

---

## 8. Eligibility check (SHA/SHIF coverage)

Before you build the claims bundle, verify the patient's SHA coverage and flag any services that require pre-authorization. This uses the Client Registry's `Coverage` data plus your local benefit-code mapping — cache eligibility results locally per visit rather than re-querying repeatedly during the same encounter.

```php
<?php

namespace App\Services\AfyaLink;

class EligibilityService
{
    public function __construct(private ClientRegistryService $clientRegistry) {}

    public function checkEligibility(string $idType, string $idNumber): array
    {
        $patient = $this->clientRegistry->fetchByIdentifier($idType, $idNumber);

        if (! $patient) {
            return ['eligible' => false, 'reason' => 'Patient not found in HIE'];
        }

        $shaId = collect($patient['other_identifications'] ?? [])
            ->firstWhere('identification_type', 'SHA Number');

        return [
            'eligible' => (bool) $shaId,
            'sha_number' => $shaId['identification_number'] ?? null,
            'patient' => $patient,
        ];
    }
}
```

In your UI: block or flag service selection for anything on your **pre-authorization list** until a preauth confirmation is recorded — this was explicitly called out as a required Critical component.

---

## 9. Claims — the FHIR bundle

This is the most involved part. Claims are submitted as a FHIR-style `Bundle` containing `Organization` (your facility), `Coverage` (SHA scheme), `Patient`, and `Claim` resources, to:

`POST /v1/shr-med/bundle` (also documented as `/v1/shr-med/post-bundle` — confirm the live path against your sandbox Postman collection, both forms appear in DHA's own docs).

### 9.1 Bundle builder

```php
<?php

namespace App\Services\AfyaLink\Support;

use Illuminate\Support\Str;

class FhirBundleBuilder
{
    public function buildClaimBundle(array $data): array
    {
        return [
            'id' => (string) Str::uuid(),
            'agent' => config('afyalink.agent'),
            'timestamp' => now()->toIso8601String(),
            'type' => 'message',
            'resourceType' => 'Bundle',
            'entry' => [
                [
                    'resourceType' => 'Organization',
                    'id' => $data['facility_id'],           // e.g. "FID-22-101101-0"
                    'name' => $data['facility_name'],
                    'active' => true,
                    'facilityLevel' => $data['facility_level'], // "LEVEL 4"
                    'identifier' => $data['facility_id'],
                ],
                [
                    'resourceType' => 'Coverage',
                    'identifier' => $data['coverage_identifier'], // "{CR_ID}-sha-coverage"
                    'status' => 'active',
                    'schemeCategory' => 'SOCIAL HEALTH AUTHORITY',
                    'beneficiary' => "Patient/{$data['patient_cr_id']}",
                ],
                [
                    'resourceType' => 'Patient',
                    'id' => $data['patient_cr_id'],
                    'name' => $data['patient_name'],
                    'gender' => $data['patient_gender'],
                    'birthDate' => $data['patient_dob'], // Y-m-d
                ],
                [
                    'resourceType' => 'Claim',
                    'id' => (string) Str::uuid(),
                    'status' => 'active',
                    'type' => 'institutional',
                    'subType' => $data['visit_type'], // "op" or "ip"
                    'patient' => $data['patient_cr_id'],
                    'billablePeriod' => [
                        'start' => $data['visit_start'],
                        'end' => $data['visit_end'],
                    ],
                    'insurance' => $data['coverage_identifier'],
                    'provider' => $data['facility_id'],
                    'diagnosis' => [
                        'code' => $data['icd11_code'],     // ICD-11 code, e.g. "1A00"
                        'display' => $data['icd11_display'],
                    ],
                    'item' => [
                        'productOrService' => $data['sha_benefit_code'], // e.g. "SHA-02-005"
                        'quantity' => $data['quantity'],
                        'unitPrice' => $data['unit_price'],
                        'currency' => 'KES',
                        'category' => $data['item_category'], // "Procedure", "Consultation", etc.
                    ],
                    'total' => [
                        'value' => $data['total_value'],
                        'currency' => 'KES',
                    ],
                ],
            ],
        ];
    }
}
```

> Note: the real payload uses a single `item`/`diagnosis` object per sample, but for multi-line claims (multiple procedures/diagnoses per visit) check the current OpenAPI spec in your sandbox — DHA's claims schema has been evolving and multi-item support may be array-based by the time you integrate. Validate structure against the live Swagger docs in `developer.dha.go.ke`, not just this guide.

### 9.2 Submitting and polling

```php
<?php

namespace App\Services\AfyaLink;

use App\Services\AfyaLink\Support\FhirBundleBuilder;
use App\Models\HieClaimSubmission;

class ClaimsService
{
    public function __construct(
        private AfyaLinkClient $client,
        private FhirBundleBuilder $builder
    ) {}

    public function submit(array $claimData): array
    {
        $bundle = $this->builder->buildClaimBundle($claimData);

        $response = $this->client->post('/v1/shr-med/bundle', $bundle);

        if (! $response->successful()) {
            throw new \RuntimeException('Claim submission failed: ' . $response->body());
        }

        $mediatorId = $response->json('message.mediator_id');

        HieClaimSubmission::create([
            'bundle_id' => $bundle['id'],
            'mediator_id' => $mediatorId,
            'claim_id' => $bundle['entry'][3]['id'],
            'status' => 'submitted',
            'payload' => $bundle,
        ]);

        // Claim adjudication is asynchronous — don't block the UI waiting on it.
        \App\Jobs\PollClaimStatus::dispatch($mediatorId, $bundle['entry'][3]['id'])
            ->delay(now()->addSeconds(30));

        return ['mediator_id' => $mediatorId, 'bundle_id' => $bundle['id']];
    }

    public function fetchStatus(string $claimId, string $bundleId): ?string
    {
        $response = $this->client->get('/v1/shr-med/claim-status', [
            'claim_id' => $claimId,
            'bundle_id' => $bundleId,
        ]);

        return $response->successful() ? $response->json('message') : null;
    }
}
```

### 9.3 Background polling job

```php
<?php

namespace App\Jobs;

use App\Services\AfyaLink\ClaimsService;
use App\Models\HieClaimSubmission;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;

class PollClaimStatus implements ShouldQueue
{
    use Dispatchable, Queueable;

    public int $tries = 10;

    public function __construct(
        private string $mediatorId,
        private string $claimId
    ) {}

    public function handle(ClaimsService $claims): void
    {
        $status = $claims->fetchStatus($this->claimId, $this->mediatorId);

        HieClaimSubmission::where('mediator_id', $this->mediatorId)
            ->update(['status' => $status ?? 'unknown', 'last_checked_at' => now()]);

        if (in_array($status, ['draft', 'pending', null])) {
            // still adjudicating — check again shortly, with backoff
            self::dispatch($this->mediatorId, $this->claimId)
                ->delay(now()->addMinutes(min(2 ** $this->attempts(), 30)));
        }
    }
}
```

---

## 10. Encryption layer (for endpoints returning sensitive payloads)

AfyaLink uses asymmetric encryption on top of the JWT for certain sensitive operations (e.g. `cr-validate-pin`): you encrypt outgoing sensitive fields with **AfyaLink's public key**, and decrypt anything AfyaLink sends you with **your own private key**.

```php
<?php

namespace App\Services\AfyaLink\Support;

class AfyaLinkEncryption
{
    public function encryptForBackend(string $plaintext): string
    {
        $publicKey = openssl_pkey_get_public(
            file_get_contents(base_path(config('afyalink.backend_public_key_path')))
        );

        openssl_public_encrypt($plaintext, $encrypted, $publicKey);

        return base64_encode($encrypted);
    }

    public function decryptOwnPayload(string $base64Ciphertext): string
    {
        $privateKey = openssl_pkey_get_private(
            file_get_contents(base_path(config('afyalink.private_key_path')))
        );

        openssl_private_decrypt(base64_decode($base64Ciphertext), $decrypted, $privateKey);

        return $decrypted;
    }
}
```

Only apply this to fields the specific endpoint's docs say are encrypted (e.g. PIN validation flows) — most registry/claims payloads in the sandbox docs travel as plain JSON over TLS with just the JWT for auth. Check each endpoint's spec individually rather than encrypting everything by default.

---

## 11. Local database tables to support the integration

```php
// database/migrations/xxxx_create_hie_client_cache_table.php
Schema::create('hie_client_cache', function (Blueprint $table) {
    $table->id();
    $table->string('cr_id')->nullable()->index();
    $table->string('identification_type');
    $table->string('identification_number')->index();
    $table->json('payload');
    $table->timestamp('synced_at');
    $table->timestamps();
});

// database/migrations/xxxx_create_hie_claim_submissions_table.php
Schema::create('hie_claim_submissions', function (Blueprint $table) {
    $table->id();
    $table->uuid('bundle_id')->index();
    $table->string('mediator_id')->nullable()->index();
    $table->uuid('claim_id')->index();
    $table->string('status')->default('submitted');
    $table->json('payload');
    $table->timestamp('last_checked_at')->nullable();
    $table->timestamps();
});
```

---

## 12. Testing sequence in sandbox

Work through these in order — each depends on the previous one working:

1. `GET /v1/hie-auth` → confirm you get a token back within ~1s of your request (given the 20s expiry, latency matters).
2. `GET /v3/client-registry/fetch-client` with a sandbox test patient identifier (DHA's sandbox ships with test identifiers — pull them from your onboarding docs/Postman collection).
3. `GET /v1/facility-search` with your own assigned test facility code.
4. `GET /v1/practitioner-search` with a sandbox practitioner ID.
5. Build a minimal `Bundle` and `POST /v1/shr-med/bundle` — expect a `mediator_id` back, not a final adjudication.
6. Poll `GET /v1/shr-med/claim-status` with that `mediator_id`/`claim_id` until status moves off `draft`.
7. Only after all of the above pass consistently, request your **security review** from DHA before being moved to production credentials.

## 13. Before you go live — the checklist DHA actually grades you on

Per the published HIE integration guide, all of the following must be 100% complete (not just the claims piece) before production sign-off: patient search/decrypt/local-store, eligibility check with SHA scheme display, facility and practitioner search with local caching, pre-authorization gating in the service-selection UI, ICD-11 diagnosis search, FHIR claim bundle construction/submission, and claim status polling. Treat the list above as your literal go-live checklist, module by module.

---

### Caveats on this guide

- Exact endpoint paths (`/v1/shr-med/bundle` vs `/v1/shr-med/post-bundle`) and payload shapes (single vs array `item`/`diagnosis`) appear inconsistently even across DHA's own published docs, which suggests the API is still being finalized — **always cross-check against the live Postman/Swagger collection in your sandbox dashboard before writing production code**, and treat this guide as the architecture/pattern to follow rather than a byte-exact spec.
- Token TTL, auth header format, and encryption requirements are as documented as of mid-2026 — confirm current values at onboarding, since DHA has been iterating on this platform actively.
