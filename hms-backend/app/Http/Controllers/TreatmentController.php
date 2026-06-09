<?php

namespace App\Http\Controllers;

use App\Models\Treatment;
use App\Models\Patient;
use App\Models\Doctor;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Validation\ValidationException;
use App\Http\Controllers\BillingController;

class TreatmentController extends Controller
{
    /**
     * Get all treatments for a patient
     */
    public function index($patient_id)
    {
        $patient = Patient::with(['treatments.doctor', 'treatments.diagnoses'])->find($patient_id);

        if (!$patient) {
            return response()->json(['message' => 'Patient not found'], 404);
        }

        return response()->json($patient->treatments);
    }

    /**
     * Get all treatments performed today
     * Includes both new patients and revisits
     */
    public function getTodaysTreatments(Request $request)
    {
        $query = Treatment::with([
            'patient',
            'doctor',
            'diagnoses'
        ])
        ->whereDate('visit_date', now()->toDateString())
        ->orderByDesc('created_at');

        // Search filter (by patient name, UPID, national ID, or phone)
        if ($search = $request->input('search')) {
            $query->whereHas('patient', function ($q) use ($search) {
                $q->where('first_name', 'like', "%{$search}%")
                ->orWhere('last_name', 'like', "%{$search}%")
                ->orWhere('upid', 'like', "%{$search}%")
                ->orWhere('national_id', 'like', "%{$search}%")
                ->orWhere('phone', 'like', "%{$search}%");
            });
        }

        // Paginate results (20 per page)
        $treatments = $query->paginate(20);

        return response()->json($treatments);
    }

    /**
     * Create a new treatment record
     * AND automatically generate the bill for that treatment.
     *
     * RULES:
     * - Receptionist CANNOT create treatments.
     * - Doctor users automatically get assigned as the treatment doctor.
     * - Admin MUST select a doctor.
     * - One Treatment = One Bill
     */
    public function store(Request $request, $patient_id)
    {
        $validated = $request->validate([
            'visit_date'           => 'required|date',
            'diagnosis'            => 'nullable|string|max:255',
            'diagnosis_category'    => 'nullable|string|max:100',
            'diagnosis_subcategory' => 'nullable|string|max:100',
            'treatment_notes'      => 'nullable|string',
            'chief_complaint'      => 'nullable|string',
            'history_presenting_illness' => 'nullable|string',
            'premedication'        => 'nullable|string',
            'past_medical_history' => 'nullable|string',
            'systemic_review'      => 'nullable|string',
            'general_systemic_examination' => 'nullable|string',
            'impression'           => 'nullable|string',
            'payment_type'         => 'nullable|string|max:50',
            'doctor_id'            => 'nullable|exists:doctors,id',
            'attending_doctor'     => 'nullable|string|max:255',
        ]);

        $user = $request->user();
        $role = $user->role ?? null;

        // 🚫 Receptionist cannot create treatments
        if ($role === 'reception') {
            return response()->json(['message' => 'Not authorized'], 403);
        }

        /*
        |--------------------------------------------------------------------------
        | DETERMINE DOCTOR
        |--------------------------------------------------------------------------
        */

        $doctorId = $validated['doctor_id'] ?? null;
        $attendingDoctor = $validated['attending_doctor'] ?? null;

        if ($role === 'doctor') {

            // Try matching doctor using email
            $doctor = Doctor::where('email', $user->email)->first();

            if ($doctor) {
                $doctorId = $doctor->id;
                $attendingDoctor = "Dr. {$doctor->first_name} {$doctor->last_name}";
            } else {
                // fallback
                $attendingDoctor = $attendingDoctor ?? ($user->name ?? $user->email ?? 'Doctor');
            }
        }

        if ($role === 'admin') {
            if (!$doctorId) {
                throw ValidationException::withMessages([
                    'doctor_id' => 'A doctor must be assigned for this treatment.',
                ]);
            }
        }

        // If doctor ID provided but no attending_doctor name, fill it
        if ($doctorId && !$attendingDoctor) {
            $doctor = Doctor::find($doctorId);
            if ($doctor) {
                $attendingDoctor = "Dr. {$doctor->first_name} {$doctor->last_name}";
            }
        }

        /*
        |--------------------------------------------------------------------------
        | DETERMINE TREATMENT TYPE (New Visit or Same-Day Revisit)
        |--------------------------------------------------------------------------
        */

        $treatmentType = 'new'; // Default to new treatment

        // Check if patient already has a treatment on this day
        if (Treatment::hasTreatmentOnDay($patient_id, $validated['visit_date'])) {
            $treatmentType = 'revisit';
            Log::info("TreatmentController: Patient #{$patient_id} already has treatment on {$validated['visit_date']} - marking as REVISIT");
        } else {
            Log::info("TreatmentController: First treatment for patient #{$patient_id} on {$validated['visit_date']} - marking as NEW");
        }

        /*
        |--------------------------------------------------------------------------
        | RESOLVE DIAGNOSIS CATEGORY & SUBCATEGORY
        |--------------------------------------------------------------------------
        */
        $resolvedCategory = $validated['diagnosis_category'] ?? null;
        $resolvedSubcategory = $validated['diagnosis_subcategory'] ?? null;

        if (!empty($validated['diagnosis'])) {
            $diseaseOption = \App\Models\DiseaseOption::with(['category', 'subcategory'])->where('name', $validated['diagnosis'])->first();
            if ($diseaseOption) {
                if ($diseaseOption->category) {
                    $resolvedCategory = $diseaseOption->category->name;
                }
                if ($diseaseOption->subcategory) {
                    $resolvedSubcategory = $diseaseOption->subcategory->name;
                }
            }
        }

        /*
        |--------------------------------------------------------------------------
        | CREATE TREATMENT
        |--------------------------------------------------------------------------
        */

        // Automatically determine diagnosis status based on diagnosis presence
        $diagnosisStatus = !empty($validated['diagnosis']) ? 'confirmed' : 'pending';

        $treatment = Treatment::create([
            'patient_id'           => $patient_id,
            'doctor_id'            => $doctorId,
            'visit_date'           => $validated['visit_date'],
            'treatment_type'       => $treatmentType, // NEW - Mark as 'new' or 'revisit'
            'diagnosis'            => $validated['diagnosis'] ?? null,
            'diagnosis_category'    => $resolvedCategory,
            'diagnosis_subcategory' => $resolvedSubcategory,
            'diagnosis_status'     => $diagnosisStatus,
            'treatment_notes'      => $validated['treatment_notes'] ?? null,
            'chief_complaint'      => $validated['chief_complaint'] ?? null,
            'history_presenting_illness' => $validated['history_presenting_illness'] ?? null,
            'premedication'        => $validated['premedication'] ?? null,
            'past_medical_history' => $validated['past_medical_history'] ?? null,
            'systemic_review'      => $validated['systemic_review'] ?? null,
            'general_systemic_examination' => $validated['general_systemic_examination'] ?? null,
            'impression'           => $validated['impression'] ?? null,
            'payment_type'         => $validated['payment_type'] ?? null,
            'attending_doctor'     => $attendingDoctor,
            'status'               => 'active',
        ]);

        /*
        |--------------------------------------------------------------------------
        | AUTO-CREATE BILL FOR THIS TREATMENT (ONE Treatment → ONE Bill)
        |--------------------------------------------------------------------------
        */

        try {
            // Use BillingService for clean, centralized billing logic
            $billingService = app(\App\Services\BillingService::class);
            $bill = $billingService->getOrCreateBillForTreatment($treatment->id);
            $billingService->addConsultationFee($bill);
            $billingService->recalculateBill($bill);
            
            $billData = $bill->load(['items', 'payments', 'patient.bills', 'doctor', 'treatment']);

        } catch (\Throwable $e) {
            Log::error("Auto billing failed for treatment {$treatment->id}: " . $e->getMessage());
            $billData = null;
        }

        /*
        |--------------------------------------------------------------------------
        | RETURN FULL RESPONSE with:
        | - treatment
        | - assigned doctor
        | - bill
        | - patient past bills (inside bill.patient.bills)
        |--------------------------------------------------------------------------
        */

        return response()->json([
            'message'   => 'Treatment and bill created successfully',
            'treatment' => $treatment->load('doctor'),
            'bill'      => $billData,     // includes patient.bills (PAST RECEIPTS)
        ], 201);
    }

    /**
     * Update a treatment record
     * Automatically updates diagnosis_status based on diagnosis presence
     */
    public function update(Request $request, $id)
    {
        $treatment = Treatment::find($id);

        if (!$treatment) {
            return response()->json(['message' => 'Treatment not found'], 404);
        }

        $validated = $request->validate([
            'visit_date'           => 'sometimes|date',
            'diagnosis'            => 'nullable|string|max:255',
            'diagnosis_category'    => 'nullable|string|max:100',
            'diagnosis_subcategory' => 'nullable|string|max:100',
            'treatment_notes'      => 'nullable|string',
            'chief_complaint'      => 'nullable|string',
            'history_presenting_illness' => 'nullable|string',
            'premedication'        => 'nullable|string',
            'past_medical_history' => 'nullable|string',
            'systemic_review'      => 'nullable|string',
            'general_systemic_examination' => 'nullable|string',
            'impression'           => 'nullable|string',
            'payment_type'         => 'nullable|string|max:50',
            'doctor_id'            => 'nullable|exists:doctors,id',
            'attending_doctor'     => 'nullable|string|max:255',
            'status'               => 'sometimes|string',
        ]);

        // Update fields
        if (array_key_exists('visit_date', $validated)) {
            $treatment->visit_date = $validated['visit_date'];
        }
        if (array_key_exists('diagnosis', $validated)) {
            $treatment->diagnosis = $validated['diagnosis'];
            
            // Auto resolve category and subcategory
            if (!empty($validated['diagnosis'])) {
                $diseaseOption = \App\Models\DiseaseOption::with(['category', 'subcategory'])->where('name', $validated['diagnosis'])->first();
                if ($diseaseOption) {
                    if ($diseaseOption->category) {
                        $treatment->diagnosis_category = $diseaseOption->category->name;
                    }
                    if ($diseaseOption->subcategory) {
                        $treatment->diagnosis_subcategory = $diseaseOption->subcategory->name;
                    }
                }
            } else {
                $treatment->diagnosis_category = null;
                $treatment->diagnosis_subcategory = null;
            }
        }
        
        // Only override if explicitly provided in request, otherwise keep the auto-resolved ones
        if (array_key_exists('diagnosis_category', $validated) && $validated['diagnosis_category'] !== null) {
            $treatment->diagnosis_category = $validated['diagnosis_category'];
        }
        if (array_key_exists('diagnosis_subcategory', $validated) && $validated['diagnosis_subcategory'] !== null) {
            $treatment->diagnosis_subcategory = $validated['diagnosis_subcategory'];
        }
        if (array_key_exists('treatment_notes', $validated)) {
            $treatment->treatment_notes = $validated['treatment_notes'];
        }
        if (array_key_exists('chief_complaint', $validated)) {
            $treatment->chief_complaint = $validated['chief_complaint'];
        }
        if (array_key_exists('history_presenting_illness', $validated)) {
            $treatment->history_presenting_illness = $validated['history_presenting_illness'];
        }
        if (array_key_exists('premedication', $validated)) {
            $treatment->premedication = $validated['premedication'];
        }
        if (array_key_exists('past_medical_history', $validated)) {
            $treatment->past_medical_history = $validated['past_medical_history'];
        }
        if (array_key_exists('systemic_review', $validated)) {
            $treatment->systemic_review = $validated['systemic_review'];
        }
        if (array_key_exists('general_systemic_examination', $validated)) {
            $treatment->general_systemic_examination = $validated['general_systemic_examination'];
        }
        if (array_key_exists('impression', $validated)) {
            $treatment->impression = $validated['impression'];
        }
        if (array_key_exists('payment_type', $validated)) {
            $treatment->payment_type = $validated['payment_type'];
        }
        if (array_key_exists('doctor_id', $validated)) {
            $treatment->doctor_id = $validated['doctor_id'];
        }
        if (array_key_exists('attending_doctor', $validated)) {
            $treatment->attending_doctor = $validated['attending_doctor'];
        }
        if (array_key_exists('status', $validated)) {
            $treatment->status = $validated['status'];
        }

        // Automatically update diagnosis_status based on diagnosis presence
        if (array_key_exists('diagnosis', $validated)) {
            $treatment->diagnosis_status = !empty($validated['diagnosis']) ? 'confirmed' : 'pending';
        }

        $treatment->save();

        return response()->json([
            'message' => 'Treatment updated successfully',
            'treatment' => $treatment->load('doctor'),
        ]);
    }

    /**
     * Delete a treatment
     */
    public function destroy($id)
    {
        $treatment = Treatment::find($id);

        if (!$treatment) {
            return response()->json(['message' => 'Treatment not found'], 404);
        }

        $treatment->delete();

        return response()->json(['message' => 'Treatment deleted successfully']);
    }
}
