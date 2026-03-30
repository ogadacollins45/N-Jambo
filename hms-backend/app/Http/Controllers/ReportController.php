<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Treatment;
use App\Models\Patient;
use App\Models\Diagnosis;
use Carbon\Carbon;
use App\Services\DiseaseMapper;

class ReportController extends Controller
{
    /**
     * Generate Data for MOH 717 - Monthly Service Workload Report
     *
     * Key data facts (from audit of TreatmentController):
     *  - treatment_type = 'new' OR 'revisit'  ← IS saved, use for NEW vs RE-ATT
     *  - visit_type                            ← NEVER saved, always NULL — do NOT use
     *  - encounter_type                        ← NEVER saved, always NULL — route logic falls back to A.1
     *  - department                            ← NEVER saved, always NULL — route logic falls back to A.1
     *  - patient.age_years                     ← Preferred precise age (integer years)
     *  - patient.age                           ← Legacy integer age (fallback)
     *  - patient.gender                        ← 'M' or 'F'
     */
    public function getMoh717(Request $request)
    {
        $month = (int) $request->input('month', Carbon::now()->month);
        $year  = (int) $request->input('year',  Carbon::now()->year);

        $treatments = Treatment::with('patient')
            ->whereYear('visit_date', $year)
            ->whereMonth('visit_date', $month)
            ->get();

        $result = [
            'a1'             => $this->initDemographics(),
            'a2'             => $this->initDemographics(),
            'a3'             => $this->initSpecialClinics(),
            'a4'             => $this->initMch(),
            'a5'             => ['attendances' => 0, 'fillings' => 0, 'extractions' => 0],
            'a6_total'       => 0,
            'other_services' => ['a7' => 0, 'a8' => 0, 'a9' => 0, 'a10' => 0, 'a11' => 0, 'a12' => 0],
        ];

        foreach ($treatments as $treatment) {
            $patient = $treatment->patient;
            if (!$patient) continue;

            // ── Age ──────────────────────────────────────────────────────────
            // age_years is the precise field added in migration.
            // age is the legacy integer column (still in use).
            // age_years = 0 can mean < 1 year (infant) → still under 5.
            $age    = $patient->age_years ?? $patient->age ?? 0;
            $gender = strtoupper($patient->gender ?? '');

            // ── Demographic row key ───────────────────────────────────────────
            if ($age >= 60) {
                $demoKey = 'over_60';
            } elseif ($age >= 5) {
                $demoKey = ($gender === 'M') ? 'over_5_m' : 'over_5_f';
            } else {
                // Under 5 (0 to 4 years 11 months inclusive)
                $demoKey = ($gender === 'M') ? 'under_5_m' : 'under_5_f';
            }

            // ── Visit type key (NEW vs RE-ATT) ────────────────────────────────
            // treatment_type is set by TreatmentController: 'new' first visit of day, 'revisit' otherwise
            $visitKey = (strtolower($treatment->treatment_type ?? '') === 'revisit') ? 'reatt' : 'new';

            // ── Clinic routing ────────────────────────────────────────────────
            $encounter = $treatment->encounter_type; // NULL for all current records
            $dept      = strtolower(trim($treatment->department ?? '')); // NULL → '' for all current records

            if (
                $encounter === 'Emergency'
                || str_contains($dept, 'casualty')
                || str_contains($dept, 'emergency')
            ) {
                // A.2 Casualty
                $result['a2'][$demoKey][$visitKey]++;
                $result['a2'][$demoKey]['total']++;

            } elseif (
                in_array($encounter, ['MCH', 'Immunisation'])
                || str_contains($dept, 'mch')
                || str_contains($dept, 'antenatal')
                || str_contains($dept, 'postnatal')
                || str_contains($dept, 'maternity')
                || str_contains($dept, 'child welfare')
                || str_contains($dept, 'family planning')
            ) {
                // A.4 MCH/FP
                $mchKey = $this->mapMchClinic($dept, $age, $patient->pregnancy_status ?? null);
                $result['a4'][$mchKey][$visitKey]++;
                $result['a4'][$mchKey]['total']++;

            } elseif (str_contains($dept, 'dental')) {
                // A.5 Dental
                $result['a5']['attendances']++;
                $notes = strtolower($treatment->treatment_notes ?? '');
                if (str_contains($notes, 'filling') || str_contains($notes, 'restoration')) {
                    $result['a5']['fillings']++;
                }
                if (str_contains($notes, 'extraction') || str_contains($notes, 'extracted')) {
                    $result['a5']['extractions']++;
                }

            } else {
                // Check A.3 Special Clinics (only when dept is non-empty)
                $specialKey = $this->mapSpecialClinic($dept, $encounter);
                if ($specialKey) {
                    $result['a3'][$specialKey][$visitKey]++;
                    $result['a3'][$specialKey]['total']++;
                } else {
                    // A.1 General Outpatients — default for all OPD / NULL records
                    $result['a1'][$demoKey][$visitKey]++;
                    $result['a1'][$demoKey]['total']++;
                }
            }
        }

        // ── A.6 Total Outpatient Services ─────────────────────────────────────
        $a6 = 0;
        foreach (['a1', 'a2'] as $sec) {
            foreach ($result[$sec] as $row) { $a6 += $row['total']; }
        }
        foreach ($result['a3'] as $row) { $a6 += $row['total']; }
        foreach ($result['a4'] as $row) { $a6 += $row['total']; }
        $a6 += $result['a5']['attendances'];
        $result['a6_total'] = $a6;

        return response()->json($result);
    }

    // ──────────────────────────────────────────────────────────────────────────
    // Helpers
    // ──────────────────────────────────────────────────────────────────────────

    private function initDemographics(): array
    {
        return [
            'over_5_m'  => ['new' => 0, 'reatt' => 0, 'total' => 0],
            'over_5_f'  => ['new' => 0, 'reatt' => 0, 'total' => 0],
            'under_5_m' => ['new' => 0, 'reatt' => 0, 'total' => 0],
            'under_5_f' => ['new' => 0, 'reatt' => 0, 'total' => 0],
            'over_60'   => ['new' => 0, 'reatt' => 0, 'total' => 0],
        ];
    }

    private function initSpecialClinics(): array
    {
        $keys = [
            'ent','eye','tb_leprosy','ccc','psychiatry','orthopaedic',
            'occupational','physiotherapy','medical','surgical',
            'paediatrics','obs_gyn','nutrition','oncology','renal','other',
        ];
        $res = [];
        foreach ($keys as $k) {
            $res[$k] = ['new' => 0, 'reatt' => 0, 'total' => 0];
        }
        return $res;
    }

    private function initMch(): array
    {
        return [
            'cwc' => ['new' => 0, 'reatt' => 0, 'total' => 0],
            'anc' => ['new' => 0, 'reatt' => 0, 'total' => 0],
            'pnc' => ['new' => 0, 'reatt' => 0, 'total' => 0],
            'fp'  => ['new' => 0, 'reatt' => 0, 'total' => 0],
        ];
    }

    private function mapMchClinic(string $dept, int $age, ?string $pregnancyStatus): string
    {
        if (str_contains($dept, 'antenatal') || str_contains($dept, 'anc')) return 'anc';
        if (str_contains($dept, 'postnatal')  || str_contains($dept, 'pnc')) return 'pnc';
        if (str_contains($dept, 'family planning') || str_contains($dept, 'fp')) return 'fp';
        if (str_contains($dept, 'cwc') || str_contains($dept, 'child welfare')) return 'cwc';
        if ($pregnancyStatus === 'pregnant') return 'anc';
        if ($age < 5) return 'cwc';
        return 'fp';
    }

    /**
     * Returns an A.3 special clinic key, or null if the dept doesn't match.
     * Returning null signals "use A.1 General OPD" as the fallback.
     */
    private function mapSpecialClinic(string $dept, ?string $encounter): ?string
    {
        // Empty dept + no special encounter type → General OPD (A.1)
        if ($dept === '' && $encounter === null) return null;
        if ($dept === '' && $encounter === 'OPD') return null;
        if ($dept === '' && $encounter === 'Follow-up') return null;
        if ($dept === '' && $encounter === 'Lab Only') return null;
        if ($dept === '' && $encounter === 'Pharmacy Only') return null;

        if (str_contains($dept, 'ent') || str_contains($dept, 'ear') || str_contains($dept, 'nose') || str_contains($dept, 'throat')) return 'ent';
        if (str_contains($dept, 'eye') || str_contains($dept, 'ophthal')) return 'eye';
        if (str_contains($dept, 'tb') || str_contains($dept, 'tuberculosis') || str_contains($dept, 'leprosy')) return 'tb_leprosy';
        if (str_contains($dept, 'ccc') || str_contains($dept, 'comprehensive care') || str_contains($dept, 'hiv') || str_contains($dept, 'art')) return 'ccc';
        if (str_contains($dept, 'psych') || str_contains($dept, 'mental')) return 'psychiatry';
        if (str_contains($dept, 'ortho')) return 'orthopaedic';
        if (str_contains($dept, 'occupational')) return 'occupational';
        if (str_contains($dept, 'physio')) return 'physiotherapy';
        if (str_contains($dept, 'medical')) return 'medical';
        if (str_contains($dept, 'surgical') || str_contains($dept, 'surgery')) return 'surgical';
        if (str_contains($dept, 'paediatric') || str_contains($dept, 'pediatric')) return 'paediatrics';
        if (str_contains($dept, 'obs') || str_contains($dept, 'gyn')) return 'obs_gyn';
        if (str_contains($dept, 'nutrition') || str_contains($dept, 'dietit')) return 'nutrition';
        if (str_contains($dept, 'onco') || str_contains($dept, 'cancer')) return 'oncology';
        if (str_contains($dept, 'renal') || str_contains($dept, 'kidney') || str_contains($dept, 'nephro')) return 'renal';

        // Has a non-empty dept string that didn't match above → "Other special clinic"
        return 'other';
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DISEASE SURVEILLANCE REPORT
    // ═══════════════════════════════════════════════════════════════════════════

    /**
     * GET /api/reports/disease-report?month=&year=
     *
     * Returns per-disease counts (Under 5 / Over 5, NEW / RE-ATT)
     * plus a list of matching patients for the expandable row view.
     *
     * Data sources per treatment:
     *   - Primary: treatment.diagnosis, treatment.diagnosis_category, treatment.diagnosis_subcategory
     *   - Additional: treatment.diagnoses (hasMany Diagnosis model)
     *
     * A single treatment/patient may appear in MULTIPLE disease rows if they have
     * multiple diagnoses. Each diagnosis entry is classified independently.
     */
    public function getDiseaseReport(Request $request)
    {
        $month = (int) $request->input('month', Carbon::now()->month);
        $year  = (int) $request->input('year',  Carbon::now()->year);

        // Fetch treatments with patients and additional diagnoses
        $treatments = Treatment::with(['patient', 'diagnoses'])
            ->whereYear('visit_date', $year)
            ->whereMonth('visit_date', $month)
            ->get();

        // ── Initialize result structure ───────────────────────────────────────
        $allKeys = DiseaseMapper::allKeys();
        $diseases = [];
        foreach ($allKeys as $key) {
            $diseases[$key] = [
                'under5_m' => 0,
                'under5_f' => 0,
                'over5_m'  => 0,
                'over5_f'  => 0,
                'total'    => 0,
                'new'      => 0,
                'reatt'    => 0,
                'patients' => [],
            ];
        }

        $summary = [
            'new_attendances'          => 0,
            'reattendances'            => 0,
            'referrals_from_facility'  => 0,
            'referrals_to_facility'    => 0,
            'referrals_from_community' => 0,
            'referrals_to_community'   => 0,
        ];

        foreach ($treatments as $treatment) {
            $patient = $treatment->patient;
            if (!$patient) continue;

            // ── Patient demographics ──────────────────────────────────────────
            $age     = $patient->age_years ?? $patient->age ?? 0;
            $gender  = strtoupper($patient->gender ?? '');
            $isUnder5 = $age < 5;

            // ── Visit type ────────────────────────────────────────────────────
            $isNew   = strtolower($treatment->treatment_type ?? '') !== 'revisit';
            $visitKey = $isNew ? 'new' : 'reatt';

            // ── Summary tallies ───────────────────────────────────────────────
            if ($isNew) {
                $summary['new_attendances']++;
            } else {
                $summary['reattendances']++;
            }

            // Referral tracking using disposition and referral_status
            if ($treatment->disposition === 'referred_out') {
                $summary['referrals_to_facility']++;
            }
            if (in_array($treatment->referral_status, ['referred_in'])) {
                $summary['referrals_from_facility']++;
            }

            // ── Build list of all diagnoses for this treatment ────────────────
            $diagnosisList = [];

            // Primary diagnosis (always present if doctor set it)
            if (!empty($treatment->diagnosis)) {
                $diagnosisList[] = [
                    'text'     => $treatment->diagnosis,
                    'category' => $treatment->diagnosis_category,
                    'sub'      => $treatment->diagnosis_subcategory,
                ];
            }

            // Additional diagnoses via Diagnosis model
            foreach ($treatment->diagnoses as $diag) {
                if (!empty($diag->diagnosis)) {
                    $diagnosisList[] = [
                        'text'     => $diag->diagnosis,
                        'category' => $diag->diagnosis_category,
                        'sub'      => $diag->diagnosis_subcategory,
                    ];
                }
            }

            // ── Classify each diagnosis → disease key → tally ─────────────────
            foreach ($diagnosisList as $d) {
                $diseaseKey = DiseaseMapper::map($d['text'], $d['category'], $d['sub']);

                if (!isset($diseases[$diseaseKey])) {
                    $diseaseKey = 'other_diseases';
                }

                // demographic counter
                if ($isUnder5) {
                    $gKey = $gender === 'M' ? 'under5_m' : 'under5_f';
                } else {
                    $gKey = $gender === 'M' ? 'over5_m' : 'over5_f';
                }

                $diseases[$diseaseKey][$gKey]++;
                $diseases[$diseaseKey]['total']++;
                $diseases[$diseaseKey][$visitKey]++;

                // Patient record for expandable view
                // Use treatment_id+patient_id as key to avoid same patient appearing twice for same disease
                $detailKey = $treatment->id . '_' . $diseaseKey;
                if (!isset($diseases[$diseaseKey]['patients'][$detailKey])) {
                    $diseases[$diseaseKey]['patients'][$detailKey] = [
                        'patient_id'   => $patient->id,
                        'upid'         => $patient->upid,
                        'name'         => trim($patient->first_name . ' ' . $patient->last_name),
                        'age'          => $age,
                        'gender'       => $patient->gender,
                        'visit_date'   => $treatment->visit_date,
                        'visit_type'   => $treatment->treatment_type,
                        'diagnosis'    => $d['text'],
                        'category'     => $d['category'],
                        'subcategory'  => $d['sub'],
                        'treatment_id' => $treatment->id,
                    ];
                }
            }

            // If no diagnosis recorded, count patient but don't classify
            if (empty($diagnosisList)) {
                // Still bump new/reatt for summary
            }
        }

        // Convert patient maps to indexed arrays for JSON
        foreach ($diseases as $key => &$data) {
            $data['patients'] = array_values($data['patients']);
        }
        unset($data);

        return response()->json([
            'diseases' => $diseases,
            'labels'   => DiseaseMapper::labels(),
            'summary'  => $summary,
            'month'    => $month,
            'year'     => $year,
        ]);
    }
}

