<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Patient;
use App\Models\Treatment;
use App\Models\Doctor;

class PatientController extends Controller
{
    /**
     * Display a listing of patients — lean payload for table view.
     * No eager-loading of treatments; only columns the UI table needs.
     */
    public function index(Request $request)
    {
        $query = Patient::select([
            'id', 'upid', 'national_id', 'first_name', 'last_name',
            'gender', 'phone', 'email', 'created_at'
        ])->orderByDesc('created_at');

        // Search filter (by name, phone, email, national_id, or upid)
        if ($search = $request->input('search')) {
            $query->where(function ($q) use ($search) {
                $q->where('first_name', 'like', "%{$search}%")
                ->orWhere('last_name', 'like', "%{$search}%")
                ->orWhere('email', 'like', "%{$search}%")
                ->orWhere('phone', 'like', "%{$search}%")
                ->orWhere('national_id', 'like', "%{$search}%")
                ->orWhere('upid', 'like', "%{$search}%");
            });
        }

        // Filter by today's patients
        if ($request->input('today') === 'true') {
            $query->whereDate('created_at', now()->toDateString());
        }

        // Paginate results (20 per page)
        $patients = $query->paginate(20);

        return response()->json($patients);
    }

    /**
     * Get patients with incomplete treatments — pure SQL, zero PHP filtering.
     * A treatment is incomplete if its latest active treatment is missing:
     * - Diagnosis (no primary diagnosis AND no additional diagnoses)
     * - Prescription
     * - Dispensation (prescription exists but not dispensed)
     * - Lab results (lab request exists but not completed)
     */
    public function getIncompletePatients(Request $request)
    {
        $query = Patient::select([
                'patients.id', 'patients.upid', 'patients.national_id',
                'patients.first_name', 'patients.last_name',
                'patients.phone', 'patients.gender', 'patients.created_at'
            ])
            ->whereHas('treatments', function ($q) {
                $q->where('status', 'active')
                  ->where(function ($incomplete) {
                      // Missing diagnosis: no primary AND no additional diagnoses
                      $incomplete->where(function ($noDiag) {
                          $noDiag->where(function ($primary) {
                              $primary->whereNull('diagnosis')->orWhere('diagnosis', '');
                          })->whereDoesntHave('diagnoses');
                      })
                      // OR missing prescription
                      ->orWhereDoesntHave('prescriptions')
                      // OR has undispensed prescription
                      ->orWhereHas('prescriptions', function ($p) {
                          $p->where(function ($notDispensed) {
                              $notDispensed->where('pharmacy_status', '!=', 'dispensed')
                                ->whereNull('dispensed_at');
                          });
                      })
                      // OR has incomplete lab request
                      ->orWhereHas('labRequests', function ($l) {
                          $l->where('status', '!=', 'completed');
                      });
                  });
            })
            ->with(['treatments' => function ($q) {
                $q->where('status', 'active')
                  ->orderByDesc('created_at')
                  ->limit(1)
                  ->select(['id', 'patient_id', 'diagnosis', 'status', 'created_at']);
            }])
            ->orderByDesc('created_at');

        $paginated = $query->paginate(20);

        // Compute incomplete_items for each patient's latest treatment efficiently
        $paginated->getCollection()->transform(function ($patient) {
            $latestTreatment = $patient->treatments->first();
            $incompleteItems = [];

            if ($latestTreatment) {
                // Check diagnosis (use counts to avoid loading relations)
                $hasDiagnosis = !empty($latestTreatment->diagnosis) ||
                    $latestTreatment->diagnoses()->exists();
                if (!$hasDiagnosis) {
                    $incompleteItems[] = 'diagnosis';
                }

                // Check prescription
                $hasPrescription = $latestTreatment->prescriptions()->exists();
                if (!$hasPrescription) {
                    $incompleteItems[] = 'prescription';
                } else {
                    // Check dispensation
                    $hasUndispensed = $latestTreatment->prescriptions()
                        ->where('pharmacy_status', '!=', 'dispensed')
                        ->whereNull('dispensed_at')
                        ->exists();
                    if ($hasUndispensed) {
                        $incompleteItems[] = 'dispensation';
                    }
                }

                // Check lab
                $hasIncompleteLab = $latestTreatment->labRequests()
                    ->where('status', '!=', 'completed')
                    ->exists();
                if ($hasIncompleteLab) {
                    $incompleteItems[] = 'lab';
                }

                $patient->latest_treatment_date = $latestTreatment->created_at;
            }

            $patient->incomplete_items = $incompleteItems;
            // Remove the treatments relation from the response to keep payload lean
            unset($patient->treatments);

            return $patient;
        });

        return response()->json($paginated);
    }

    /**
     * Store a newly created patient record.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'first_name'  => 'required|string|max:100',
            'last_name'   => 'required|string|max:100',
            'gender'      => 'required|string|max:10',
            'dob'         => 'nullable|date',
            'age'         => 'nullable|integer|min:0|max:150',
            'age_years'   => 'nullable|integer|min:0|max:150',
            'age_months'  => 'nullable|integer|min:0|max:11',
            'age_days'    => 'nullable|integer|min:0|max:30',
            'phone'       => 'nullable|string|max:20',
            'email'       => 'nullable|email|max:255',
            'address'     => 'nullable|string|max:255',
            'national_id' => 'nullable|string|max:50|unique:patients,national_id',
            
            // MOH fields
            'county'            => 'nullable|string|max:100',
            'sub_county'        => 'nullable|string|max:100',
            'ward'              => 'nullable|string|max:100',
            'village'           => 'nullable|string|max:100',
            'next_of_kin'       => 'nullable|string|max:100',
            'next_of_kin_phone' => 'nullable|string|max:20',
            'pregnancy_status'  => 'nullable|string|in:yes,no,unknown,na',
            'has_disability'    => 'nullable|boolean',
            'disability_type'   => 'nullable|string|max:100',
        ]);

        $patient = Patient::create($validated);

        return response()->json([
            'message' => 'Patient created successfully',
            'data'    => $patient,
        ], 201);
    }

    /**
     * Display a specific patient — lean payload.
     * Only returns patient fields + relationship counts for tab badges.
     * Treatments, lab requests, vitals, etc. are fetched on-demand by the frontend.
     */
    public function show($id)
    {
        $patient = Patient::withCount(['treatments', 'appointments', 'bills'])
            ->find($id);

        if (!$patient) {
            return response()->json(['message' => 'Patient not found'], 404);
        }

        return response()->json($patient);
    }

    /**
     * Update a patient record.
     */
    public function update(Request $request, $id)
    {
        $patient = Patient::find($id);

        if (!$patient) {
            return response()->json(['message' => 'Patient not found'], 404);
        }

        $validated = $request->validate([
            'upid'        => 'nullable|string|max:50|unique:patients,upid,' . $id,
            'first_name'  => 'required|string|max:100',
            'last_name'   => 'required|string|max:100',
            'gender'      => 'required|string|max:10',
            'dob'         => 'nullable|date',
            'age'         => 'nullable|integer|min:0|max:150',
            'age_years'   => 'nullable|integer|min:0|max:150',
            'age_months'  => 'nullable|integer|min:0|max:11',
            'age_days'    => 'nullable|integer|min:0|max:30',
            'phone'       => 'nullable|string|max:20',
            'email'       => 'nullable|email|max:255',
            'address'     => 'nullable|string|max:255',
            'national_id' => 'nullable|string|max:50|unique:patients,national_id,' . $id,
            
            // MOH fields
            'county'            => 'nullable|string|max:100',
            'sub_county'        => 'nullable|string|max:100',
            'ward'              => 'nullable|string|max:100',
            'village'           => 'nullable|string|max:100',
            'next_of_kin'       => 'nullable|string|max:100',
            'next_of_kin_phone' => 'nullable|string|max:20',
            'pregnancy_status'  => 'nullable|string|in:yes,no,unknown,na',
            'has_disability'    => 'nullable|boolean',
            'disability_type'   => 'nullable|string|max:100',
        ]);

        $patient->update($validated);

        return response()->json([
            'message' => 'Patient updated successfully',
            'data'    => $patient,
        ]);
    }

    /**
     * Remove a patient record.
     */
    public function destroy($id)
    {
        $patient = Patient::find($id);

        if (!$patient) {
            return response()->json(['message' => 'Patient not found'], 404);
        }

        $patient->delete();

        return response()->json(['message' => 'Patient deleted successfully']);
    }
}
