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
        // First time processing may take a while if querying the AI service for un-cached diagnoses
        set_time_limit(300);

        $month = (int) $request->input('month', Carbon::now()->month);
        $year  = (int) $request->input('year',  Carbon::now()->year);

        $treatments = Treatment::with(['patient', 'diagnoses'])
            ->whereYear('visit_date', $year)
            ->whereMonth('visit_date', $month)
            ->get();

        $result = [
            'a1'             => $this->initDemographics(),
            'a2'             => $this->initDemographics(),
            'a3'             => $this->initSpecialClinics(),
            'a4'             => $this->initMch(),
            'a5'             => ['attendances' => 0, 'fillings' => 0, 'extractions' => 0, 'patients' => []],
            'a6_total'       => 0,
            'other_services' => ['a7' => 0, 'a8' => 0, 'a9' => 0, 'a10' => 0, 'a11' => 0, 'a12' => 0, 'patients' => []],
        ];

        foreach ($treatments as $treatment) {
            $patient = $treatment->patient;
            if (!$patient) continue;

            $age    = $patient->age_years ?? $patient->age ?? 0;
            $gender = strtoupper($patient->gender ?? '');

            // ── Demographic row key ───────────────────────────────────────────
            if ($age >= 60) {
                $demoKey = 'over_60';
            } elseif ($age >= 5) {
                $demoKey = ($gender === 'M') ? 'over_5_m' : 'over_5_f';
            } else {
                $demoKey = ($gender === 'M') ? 'under_5_m' : 'under_5_f';
            }

            // ── Visit type key (NEW vs RE-ATT) ────────────────────────────────
            $visitKey = (strtolower($treatment->treatment_type ?? '') === 'revisit') ? 'reatt' : 'new';

            $patientPayload = [
                'patient_id'   => $patient->id,
                'upid'         => $patient->upid,
                'name'         => trim($patient->first_name . ' ' . $patient->last_name),
                'age'          => $age,
                'gender'       => $gender,
                'visit_date'   => $treatment->visit_date,
                'visit_type'   => $treatment->treatment_type,
                'diagnosis'    => $treatment->diagnosis,
                'category'     => $treatment->diagnosis_category,
                'subcategory'  => $treatment->diagnosis_subcategory,
                'treatment_id' => $treatment->id,
            ];

            // ── Extract all relevant text fields ──────────────────────────────
            $chiefComplaint = strtolower($treatment->chief_complaint ?? '');
            $notes          = strtolower($treatment->treatment_notes ?? '');
            
            // Collect all diagnoses strings for AI Mapping
            $diagnosesTexts = [];
            if (!empty($treatment->diagnosis)) $diagnosesTexts[] = $treatment->diagnosis;
            foreach ($treatment->diagnoses as $diag) {
                if (!empty($diag->diagnosis)) $diagnosesTexts[] = $diag->diagnosis;
            }
            
            // Run AI mapping on the primary diagnosis to detect special clinics
            $primaryDiagnosisText = $diagnosesTexts[0] ?? '';
            $diseaseGroup = 'other_diseases';
            if (!empty($primaryDiagnosisText)) {
                $diseaseGroup = DiseaseMapper::map($primaryDiagnosisText, $treatment->diagnosis_category, $treatment->diagnosis_subcategory);
            }

            // ── 1. A.2 Casualty / Emergency (Regex check) ─────────────────────
            if (preg_match('/\b(rta|accident|bleeding|unconscious|collapse|burns|assault|emergency|casualty)\b/i', $chiefComplaint . ' ' . $notes)) {
                $result['a2'][$demoKey][$visitKey]++;
                $result['a2'][$demoKey]['total']++;
                $result['a2'][$demoKey]['patients'][] = $patientPayload;
                continue;
            }

            // ── 2. A.4 MCH / Family Planning / CWC ────────────────────────────
            if ($age < 5 && preg_match('/\b(vaccin|immuniz|polio|measles|bcp|bcg|growth monitoring|cwc)\b/i', $notes . ' ' . $primaryDiagnosisText)) {
                $result['a4']['cwc'][$visitKey]++;
                $result['a4']['cwc']['total']++;
                $result['a4']['cwc']['patients'][] = $patientPayload;
                continue;
            }
            if (preg_match('/\b(family planning|fp|implant|iucd|depo|jadelle|pill|condom)\b/i', $notes . ' ' . $primaryDiagnosisText)) {
                $result['a4']['fp'][$visitKey]++;
                $result['a4']['fp']['total']++;
                $result['a4']['fp']['patients'][] = $patientPayload;
                continue;
            }
            if ($gender === 'F' && ($patient->pregnancy_status === 'pregnant' || preg_match('/\b(anc|antenatal|pregnancy)\b/i', $notes))) {
                $result['a4']['anc'][$visitKey]++;
                $result['a4']['anc']['total']++;
                $result['a4']['anc']['patients'][] = $patientPayload;
                continue;
            }

            // ── 3. A.5 Dental Procedures ──────────────────────────────────────
            if ($diseaseGroup === 'dental_disorders' || preg_match('/\b(dental|tooth|teeth)\b/i', $primaryDiagnosisText)) {
                $result['a5']['attendances']++;
                $result['a5']['patients'][] = $patientPayload;
                if (preg_match('/\b(filling|amalgam|composite|restor)\b/i', $notes)) {
                    $result['a5']['fillings']++;
                }
                if (preg_match('/\b(extract|xla|pulled)\b/i', $notes)) {
                    $result['a5']['extractions']++;
                }
                continue; // Processed
            }

            // ── 4. A.3 Special Clinics (Based on AI Disease Mapping) ──────────
            $specialKey = $this->mapDiseaseToSpecialClinic($diseaseGroup);
            if ($specialKey) {
                $result['a3'][$specialKey][$visitKey]++;
                $result['a3'][$specialKey]['total']++;
                $result['a3'][$specialKey]['patients'][] = $patientPayload;
                continue;
            }

            // ── 5. Fallback -> A.1 General Outpatients ────────────────────────
            $result['a1'][$demoKey][$visitKey]++;
            $result['a1'][$demoKey]['total']++;
            $result['a1'][$demoKey]['patients'][] = $patientPayload;
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
            'over_5_m'  => ['new' => 0, 'reatt' => 0, 'total' => 0, 'patients' => []],
            'over_5_f'  => ['new' => 0, 'reatt' => 0, 'total' => 0, 'patients' => []],
            'under_5_m' => ['new' => 0, 'reatt' => 0, 'total' => 0, 'patients' => []],
            'under_5_f' => ['new' => 0, 'reatt' => 0, 'total' => 0, 'patients' => []],
            'over_60'   => ['new' => 0, 'reatt' => 0, 'total' => 0, 'patients' => []],
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
            $res[$k] = ['new' => 0, 'reatt' => 0, 'total' => 0, 'patients' => []];
        }
        return $res;
    }

    private function initMch(): array
    {
        return [
            'cwc' => ['new' => 0, 'reatt' => 0, 'total' => 0, 'patients' => []],
            'anc' => ['new' => 0, 'reatt' => 0, 'total' => 0, 'patients' => []],
            'pnc' => ['new' => 0, 'reatt' => 0, 'total' => 0, 'patients' => []],
            'fp'  => ['new' => 0, 'reatt' => 0, 'total' => 0, 'patients' => []],
        ];
    }

    /**
     * Map the AI disease output to an A.3 Special Clinic.
     * Returns null if it doesn't belong to a special clinic (meaning A.1 fallback).
     */
    private function mapDiseaseToSpecialClinic(string $diseaseGroup): ?string
    {
        switch ($diseaseGroup) {
            case 'eye_infections':
            case 'other_eye':
                return 'eye';
            case 'tuberculosis':
                return 'tb_leprosy';
            case 'mental_disorders':
            case 'epilepsy':
                return 'psychiatry';
            case 'muscular_skeletal':
            case 'road_traffic_injuries':
            case 'other_injuries':
            case 'fractures':
                return 'orthopaedic';
            case 'newly_diagnosed_hiv':
            case 'sti':
                return 'ccc';
            case 'hypertension':
            case 'diabetes':
            case 'cardiovascular':
            case 'cns_conditions':
            case 'neoplasms':
            case 'asthma':
                return 'medical';
            case 'abortion':
            case 'fistula':
            case 'puerperium':
            case 'post_abortion':
                return 'obs_gyn';
            case 'malnutrition':
                return 'nutrition';
            case 'dental_disorders': // Should be handled in A.5, but just in case
                return null;
            default:
                return null;
        }
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
        // Generating for a large month for the first time before AI results are cached 
        // can exceed the default 30s limit due to sequential HTTP calls.
        set_time_limit(300); 

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

