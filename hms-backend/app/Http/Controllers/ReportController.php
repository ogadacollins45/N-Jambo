<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Treatment;
use App\Models\Patient;
use App\Models\Diagnosis;
use App\Models\LabResult;
use App\Models\LabRequest;
use Carbon\Carbon;
use App\Services\DiseaseMapper;
use App\Services\LabTestMapper;

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


    // ═══════════════════════════════════════════════════════════════════════
    // MOH 706 — LABORATORY MONTHLY REPORT
    // ═══════════════════════════════════════════════════════════════════════

    /**
     * GET /api/reports/moh-706?month=&year=
     *
     * Returns the MOH 706 aggregated laboratory data structure for the given
     * month/year. Currently covers Sections 1 (Urine Analysis), 7 (Serology),
     * and 8 (Specimen Referrals). Additional sections are added in future phases.
     *
     * Counting logic:
     *   total_exam         → count of completed/verified LabResults for the test
     *   number_positive    → count where at least one LabResultParameter is flagged
     *                        is_abnormal = true
     *   number_of_specimens      (Section 8) → LabRequests for referral-type tests
     *   number_of_results_received (Section 8) → those requests with a completed result
     */
    public function getMoh706(Request $request)
    {
        set_time_limit(300);

        $month = (int) $request->input('month', Carbon::now()->month);
        $year  = (int) $request->input('year',  Carbon::now()->year);

        // ── 1. Initialise structure ─────────────────────────────────────────────────────
        $sections = $this->initMoh706Structure();

        // Build a flat code → [sectionNum, subsectionIdx, rowIdx] lookup
        $codeIndex = [];
        foreach ($sections as $sNum => $section) {
            foreach ($section['subsections'] as $subIdx => $sub) {
                foreach ($sub['rows'] as $rowIdx => $row) {
                    $codeIndex[$row['code']] = [$sNum, $subIdx, $rowIdx];
                }
            }
        }

        // ── 2. Query completed lab results (all sections except 8) ─────────────
        $labResults = LabResult::with([
                'labRequestTest.template',
                'labRequest.patient',        // needed for age-gated rows (malaria, etc.)
                'parameters',
            ])
            ->whereHas('labRequest', function ($q) use ($month, $year) {
                $q->whereYear('request_date', $year)
                  ->whereMonth('request_date', $month)
                  ->whereNotIn('status', ['rejected', 'cancelled']);
            })
            ->whereIn('status', ['completed', 'verified'])
            ->get();

        foreach ($labResults as $result) {
            $testTemplate = $result->labRequestTest?->template;
            if (!$testTemplate) continue;

            $testName = trim($testTemplate->name ?? '');
            if ($testName === '') continue;

            $code = LabTestMapper::map($testName);
            if ($code === 'unmapped' || !isset($codeIndex[$code])) continue;

            // Section 8 rows handled separately
            if (str_starts_with($code, '8.')) continue;

            [$sNum, $subIdx, $rowIdx] = $codeIndex[$code];
            $columns = $sections[$sNum]['subsections'][$subIdx]['columns'];
            $patient   = $result->labRequest?->patient;
            $patientAge = $patient ? ($patient->age_years ?? $patient->age ?? 0) : 0;

            // ── Section 3: Malaria age-gated routing ─────────────────────────────
            // The keyword map routes "malaria bs" → 3.1 and "malaria rdt" → 3.3.
            // If the patient is 5+ the code should shift to 3.2 / 3.4 respectively.
            if ($code === '3.1' && $patientAge >= 5) $code = '3.2';
            if ($code === '3.3' && $patientAge >= 5) $code = '3.4';
            // Re-index after potential reroute
            if (!isset($codeIndex[$code])) continue;
            [$sNum, $subIdx, $rowIdx] = $codeIndex[$code];
            $columns = $sections[$sNum]['subsections'][$subIdx]['columns'] ?? [];

            // ── Determine abnormality flags from parameters ────────────────────────
            $isPositive      = false;
            $isLow           = false;
            $isHigh          = false;
            $hbValue         = null;   // for HB categorisation
            $isPreDiabetes   = false;
            $isDiabetes      = false;
            $cd4Value        = null;   // for CD4 <500 threshold
            $isMalignant     = false;
            $culturePositive = false;
            $isContaminated  = false;

            // Arrays for secondary row mappings (like parameter isolates)
            $organismCodesToIncrement = [];
            
            // Arrays for Section 9 Drug Susceptibility Matrix
            $foundSection9Organisms = [];
            if (str_starts_with($code, '9.')) {
                $foundSection9Organisms[] = $code;
            }
            $resistantAntibiotics = [];
            $antibioticKeys = [
                // Combinations & Aliases (placed first to match specific combos over generics)
                'sulbactam' => 'ampicillin_sulbactam',
                'avibactam' => 'ceftazidime_avibactam',
                'tazobactam' => 'piperacillin_tazobactam', 'piperacillin' => 'piperacillin_tazobactam',
                'cefoxitin' => 'cefoxitin_oxacillin', 'oxacillin' => 'cefoxitin_oxacillin',
                'trimethoprim' => 'trimethoprim_sulfamethoxazole', 'sulfamethoxazole' => 'trimethoprim_sulfamethoxazole', 'cotrimoxazole' => 'trimethoprim_sulfamethoxazole', 'septrin' => 'trimethoprim_sulfamethoxazole',
                'doxycycline' => 'doxycycline_tetracycline', 'tetracycline' => 'doxycycline_tetracycline',

                // Specific Generics
                'ciprofloxacin' => 'ciprofloxacin',
                'levofloxacin' => 'levofloxacin',
                'gentamicin' => 'gentamicin_c',
                'ceftazidime' => 'ceftazidime',
                'cefuroxime' => 'cefuroxime',
                'cefotaxime' => 'cefotaxime',
                'ampicillin' => 'ampicillin',
                'cefazolin' => 'cefazolin',
                'amikacin' => 'amikacin',
                'chloramphenicol' => 'chloramphenicol',
                'cefepime' => 'cefepime',
                'tobramycin' => 'obramycin', 'obramycin' => 'obramycin',
                'penicillin' => 'penicillin',
                'vancomycin' => 'vancomycin',
                'meropenem' => 'meropenem',
                'clindamycin' => 'clindamycin',
                'erythromycin' => 'erythromycin',
            ];

            // Check overall comment first for text flags
            $obsComment = strtolower($result->overall_comment ?? '');
            if (str_contains($obsComment, 'malignant') || str_contains($obsComment, 'carcinoma')) {
                $isMalignant = true;
            }
            if (str_contains($obsComment, 'contaminat')) {
                $isContaminated = true;
            }

            foreach ($result->parameters as $param) {
                $flag = strtoupper(trim($param->abnormal_flag ?? ''));
                $pVal = strtolower(trim($param->value ?? ''));
                $pName = strtolower(trim($param->parameter?->name ?? ''));
                
                // Text checking across parameters for malignant/contaminated
                if (str_contains($pVal, 'malignant') || str_contains($pName, 'malignant') || str_contains($pVal, 'carcinoma') || str_contains($pName, 'carcinoma')) {
                    $isMalignant = true;
                }
                if (str_contains($pVal, 'contaminat') || str_contains($pName, 'contaminat')) {
                    $isContaminated = true;
                }

                // Identify if this parameter maps to a Section 9 organism directly
                $paramCodeCheck = LabTestMapper::map($pName);
                if ($paramCodeCheck === 'unmapped' && !empty($pVal)) {
                    $paramCodeCheck = LabTestMapper::map($pVal);
                }
                if ($paramCodeCheck !== 'unmapped' && str_starts_with($paramCodeCheck, '9.') && isset($codeIndex[$paramCodeCheck])) {
                    if (!in_array($paramCodeCheck, $foundSection9Organisms)) {
                        $foundSection9Organisms[] = $paramCodeCheck;
                    }
                }

                // Check for Antibiotics Resistance
                if ($param->is_abnormal || $flag === 'R' || $pVal === 'r' || str_contains($pVal, 'resistant')) {
                    foreach ($antibioticKeys as $keyword => $colKey) {
                        if (str_contains($pName, $keyword)) {
                            $resistantAntibiotics[] = $colKey;
                            break;
                        }
                    }
                }

                if ($param->is_abnormal || in_array($pVal, ['positive', 'detected', 'isolated'])) {
                    $isPositive = true;
                    if ($flag === 'L' || $flag === 'LOW')  $isLow  = true;
                    if ($flag === 'H' || $flag === 'HIGH') $isHigh = true;

                    // Support for Section 5. If parent test is a culture (e.g. stool culture, urine culture), 
                    // an abnormal/positive parameter indicates culture positive.
                    if (str_starts_with($code, '5.')) {
                        $culturePositive = true;
                    }

                    // Mapping isolates to secondary rows for Section 5
                    if ($paramCodeCheck !== 'unmapped' && str_starts_with($paramCodeCheck, '5.') && $paramCodeCheck !== '5.10' && $paramCodeCheck !== '5.16' && isset($codeIndex[$paramCodeCheck])) {
                        if (!in_array($paramCodeCheck, $organismCodesToIncrement)) {
                            $organismCodesToIncrement[] = $paramCodeCheck;
                        }
                    }
                }

                // HB value capture
                if (str_contains($pName, 'haemoglobin') || str_contains($pName, 'hemoglobin') || $pName === 'hb') {
                    $hbValue = is_numeric($param->value) ? (float) $param->value : null;
                }
                // HbA1c classification (pre-diabetes 5.7-6.4%, diabetes ≥6.5%)
                if (str_contains($pName, 'hba1c') || str_contains($pName, 'a1c') || str_contains($pName, 'glycated')) {
                    $a1c = is_numeric($param->value) ? (float) $param->value : null;
                    if ($a1c !== null) {
                        if ($a1c >= 6.5)              $isDiabetes   = true;
                        elseif ($a1c >= 5.7)          $isPreDiabetes = true;
                    }
                }
                // CD4 value capture
                if (str_contains($pName, 'cd4')) {
                    $cd4Value = is_numeric($param->value) ? (float) $param->value : null;
                }
            }

            // ── Accumulate into the data structure ─────────────────────────────
            if (in_array('total_exam', $columns, true)) {
                $sections[$sNum]['subsections'][$subIdx]['rows'][$rowIdx]['total_exam']++;
            }
            if (in_array('total_cultures', $columns, true)) {
                $sections[$sNum]['subsections'][$subIdx]['rows'][$rowIdx]['total_cultures']++;
            }
            if (in_array('number', $columns, true)) {
                $sections[$sNum]['subsections'][$subIdx]['rows'][$rowIdx]['number']++;
            }
            if (in_array('number_positive', $columns, true) && $isPositive) {
                $sections[$sNum]['subsections'][$subIdx]['rows'][$rowIdx]['number_positive']++;
            }
            if (in_array('culture_positive', $columns, true) && ($isPositive || $culturePositive)) {
                $sections[$sNum]['subsections'][$subIdx]['rows'][$rowIdx]['culture_positive']++;
            }
            if (in_array('malignant', $columns, true) && $isMalignant) {
                $sections[$sNum]['subsections'][$subIdx]['rows'][$rowIdx]['malignant']++;
            }
            if (in_array('number_contaminated', $columns, true) && $isContaminated) {
                $sections[$sNum]['subsections'][$subIdx]['rows'][$rowIdx]['number_contaminated']++;
            }
            if (in_array('low', $columns, true) && $isLow) {
                $sections[$sNum]['subsections'][$subIdx]['rows'][$rowIdx]['low']++;
            }
            if (in_array('high', $columns, true) && $isHigh) {
                $sections[$sNum]['subsections'][$subIdx]['rows'][$rowIdx]['high']++;
            }
            // HbA1c-specific columns
            if (in_array('pre_diabetes', $columns, true) && $isPreDiabetes) {
                $sections[$sNum]['subsections'][$subIdx]['rows'][$rowIdx]['pre_diabetes']++;
            }
            if (in_array('diabetes', $columns, true) && $isDiabetes) {
                $sections[$sNum]['subsections'][$subIdx]['rows'][$rowIdx]['diabetes']++;
            }
            // HB range classification
            if (in_array('hb_lt_5_g_dl', $columns, true) && $hbValue !== null && $hbValue < 5) {
                $sections[$sNum]['subsections'][$subIdx]['rows'][$rowIdx]['hb_lt_5_g_dl']++;
            }
            if (in_array('hb_5_to_10_g_dl', $columns, true) && $hbValue !== null && $hbValue >= 5 && $hbValue <= 10) {
                $sections[$sNum]['subsections'][$subIdx]['rows'][$rowIdx]['hb_5_to_10_g_dl']++;
            }
            // CD4 <500 threshold
            if (in_array('number_lt_500', $columns, true) && $cd4Value !== null && $cd4Value < 500) {
                $sections[$sNum]['subsections'][$subIdx]['rows'][$rowIdx]['number_lt_500']++;
            }

            // ── Increment secondary organism rows (Isolates from parameters) ───────
            foreach ($organismCodesToIncrement as $oCode) {
                if (!isset($codeIndex[$oCode])) continue;
                [$oSNum, $oSubIdx, $oRowIdx] = $codeIndex[$oCode];
                $oCols = $sections[$oSNum]['subsections'][$oSubIdx]['columns'];
                
                if (in_array('number_positive', $oCols, true)) {
                    $sections[$oSNum]['subsections'][$oSubIdx]['rows'][$oRowIdx]['number_positive']++;
                }
            }

            // ── Increment Section 9 Matrix ─────────────────────────────────────────
            // Apply all found resistant antibiotics to all found Section 9 organisms
            $resistantAntibiotics = array_unique($resistantAntibiotics);
            foreach ($foundSection9Organisms as $orgCode) {
                if (!isset($codeIndex[$orgCode])) continue;
                [$oSNum, $oSubIdx, $oRowIdx] = $codeIndex[$orgCode];
                foreach ($resistantAntibiotics as $antiCol) {
                    if (isset($sections[$oSNum]['subsections'][$oSubIdx]['rows'][$oRowIdx][$antiCol])) {
                        $sections[$oSNum]['subsections'][$oSubIdx]['rows'][$oRowIdx][$antiCol]++;
                    }
                }
            }
        }

        // ── 3. Section 8 — Specimen Referrals ──────────────────────────────────
        $allRequests = LabRequest::with([

                'tests.template',
                'tests.result',
            ])
            ->whereYear('request_date', $year)
            ->whereMonth('request_date', $month)
            ->whereNotIn('status', ['rejected', 'cancelled'])
            ->get();

        foreach ($allRequests as $req) {
            foreach ($req->tests as $reqTest) {
                $tName = trim($reqTest->template?->name ?? '');
                if ($tName === '') continue;

                $code = LabTestMapper::map($tName);
                if (!str_starts_with((string) $code, '8.') || !isset($codeIndex[$code])) continue;

                [$sNum, $subIdx, $rowIdx] = $codeIndex[$code];
                $sections[$sNum]['subsections'][$subIdx]['rows'][$rowIdx]['number_of_specimens']++;

                $res = $reqTest->result;
                if ($res && in_array($res->status, ['completed', 'verified'], true)) {
                    $sections[$sNum]['subsections'][$subIdx]['rows'][$rowIdx]['number_of_results_received']++;
                }
            }
        }

        return response()->json([
            'sections'     => $sections,
            'month'        => $month,
            'year'         => $year,
            'generated_at' => now()->toIso8601String(),
        ]);
    }

    /**
     * Build the empty MOH 706 data structure.
     * Phase 2: All sections 1–4 + 7–8.
     */
    private function initMoh706Structure(): array
    {
        // Row builder helpers
        $r   = fn(string $code, string $label) => [
            'code' => $code, 'label' => $label, 'total_exam' => 0, 'number_positive' => 0,
        ];
        $rlh = fn(string $code, string $label) => [
            'code' => $code, 'label' => $label, 'total_exam' => 0, 'low' => 0, 'high' => 0,
        ];
        $rn  = fn(string $code, string $label) => [
            'code' => $code, 'label' => $label, 'number' => 0,
        ];
        $rnp = fn(string $code, string $label) => [
            'code' => $code, 'label' => $label, 'number_positive' => 0,
        ];
        $rhb = fn(string $code, string $label) => [
            'code' => $code, 'label' => $label, 'total_exam' => 0, 'hb_lt_5_g_dl' => 0, 'hb_5_to_10_g_dl' => 0,
        ];
        $ra1c = fn(string $code, string $label) => [
            'code' => $code, 'label' => $label, 'total_exam' => 0, 'pre_diabetes' => 0, 'diabetes' => 0,
        ];
        $rcd4 = fn(string $code, string $label) => [
            'code' => $code, 'label' => $label, 'total_exam' => 0, 'number_lt_500' => 0,
        ];
        $ref  = fn(string $code, string $label) => [
            'code' => $code, 'label' => $label, 'number_of_specimens' => 0, 'number_of_results_received' => 0,
        ];
        // Section 5/6 specific helpers
        $rcult = fn(string $code, string $label) => [
            'code' => $code, 'label' => $label, 'total_exam' => 0, 'total_cultures' => 0, 'culture_positive' => 0,
        ];
        $rcsf = fn(string $code, string $label) => [
            'code' => $code, 'label' => $label, 'total_exam' => 0, 'number_positive' => 0, 'number_contaminated' => 0,
        ];
        $rmal = fn(string $code, string $label) => [
            'code' => $code, 'label' => $label, 'total_exam' => 0, 'malignant' => 0,
        ];

        return [
            // ═════════════════════════════════════════════════════════════════════
            '1' => [
                'number' => '1',
                'title'  => 'URINE ANALYSIS',
                'subsections' => [
                    [
                        'code'    => '1.1',  'title'   => 'Urine Chemistry',
                        'columns' => ['total_exam', 'number_positive'],
                        'rows'    => [
                            $r('1.2', 'Glucose'), $r('1.3', 'Ketones'), $r('1.4', 'Proteins'),
                        ],
                    ],
                    [
                        'code'    => '1.5',  'title'   => 'Urine Microscopy',
                        'columns' => ['total_exam', 'number_positive'],
                        'rows'    => [
                            $r('1.6', 'Pus cells (p/s/hpf)'), $r('1.7', 'S. haematobium'),
                            $r('1.8', 'T. vaginalis'),         $r('1.9', 'Yeast cells'),
                            $r('1.10', 'Bacteria'),
                        ],
                    ],
                ],
            ],

            // ═════════════════════════════════════════════════════════════════════
            '2' => [
                'number' => '2',
                'title'  => 'BLOOD CHEMISTRY',
                'subsections' => [
                    [
                        'code'    => '2.1',  'title'   => 'Blood Sugar Test',
                        'columns' => ['total_exam', 'low', 'high'],
                        'rows'    => [ $rlh('2.1', 'Blood sugar'), $rlh('2.2', 'OGTT') ],
                    ],
                    [
                        'code'    => '2.3',  'title'   => 'Renal Function Test',
                        'columns' => ['total_exam', 'low', 'high'],
                        'rows'    => [
                            $rlh('2.4', 'Creatinine'),   $rlh('2.5', 'Urea'),
                            $rlh('2.6', 'Sodium'),        $rlh('2.7', 'Potassium'),
                            $rlh('2.8', 'Chlorides'),
                        ],
                    ],
                    [
                        'code'    => '2.8b', 'title'   => 'Liver Function Test',
                        'columns' => ['total_exam', 'low', 'high'],
                        'rows'    => [
                            $rlh('2.9',  'Direct bilirubin'),  $rlh('2.10', 'Total bilirubin'),
                            $rlh('2.11', 'ASAT (SGOT)'),       $rlh('2.12', 'ALAT (SGPT)'),
                            $rlh('2.13', 'Serum Protein'),     $rlh('2.14', 'Albumin'),
                            $rlh('2.15', 'Alkaline Phosphatase'),
                        ],
                    ],
                    [
                        'code'    => '2.16', 'title'   => 'Lipid Profile',
                        'columns' => ['total_exam', 'low', 'high'],
                        'rows'    => [
                            $rlh('2.17', 'Total cholesterol'), $rlh('2.18', 'Triglycerides'), $rlh('2.19', 'LDL'),
                        ],
                    ],
                    [
                        'code'    => '2.20', 'title'   => 'Hormonal Test',
                        'columns' => ['total_exam', 'low', 'high'],
                        'rows'    => [ $rlh('2.20', 'T3'), $rlh('2.21', 'T4'), $rlh('2.22', 'TSH') ],
                    ],
                    [
                        'code'    => '2.23', 'title'   => 'Tumor Markers',
                        'columns' => ['total_exam', 'number_positive'],
                        'rows'    => [
                            $r('2.23', 'PSA'),    $r('2.24', 'CA 15-3'), $r('2.25', 'CA 19-9'),
                            $r('2.26', 'CA 125'), $r('2.27', 'CEA'),     $r('2.28', 'AFP'),
                        ],
                    ],
                    [
                        'code'    => '2.29', 'title'   => 'CSF Chemistry',
                        'columns' => ['total_exam', 'low', 'high'],
                        'rows'    => [ $rlh('2.29', 'Proteins'), $rlh('2.30', 'Glucose') ],
                    ],
                ],
            ],

            // ═════════════════════════════════════════════════════════════════════
            '3' => [
                'number' => '3',
                'title'  => 'PARASITOLOGY',
                'subsections' => [
                    [
                        'code'    => '3.1',  'title'   => 'Malaria Test',
                        'columns' => ['total_exam', 'number_positive'],
                        'rows'    => [
                            $r('3.1', 'Malaria BS (Under five years)'),
                            $r('3.2', 'Malaria BS (5 years and above)'),
                            $r('3.3', 'Malaria RDT (Under five years)'),
                            $r('3.4', 'Malaria RDT (5 years and above)'),
                        ],
                    ],
                    [
                        'code'    => '3.5',  'title'   => 'Stool Examination',
                        'columns' => ['total_exam', 'number_positive'],
                        'rows'    => [
                            $r('3.5',  'Taenia spp.'),          $r('3.6',  'Hymenolepis nana'),
                            $r('3.7',  'Hookworm'),             $r('3.8',  'Roundworms'),
                            $r('3.9',  'S. mansoni'),           $r('3.10', 'Trichuris trichiura'),
                            $r('3.11', 'Amoeba'),
                        ],
                    ],
                ],
            ],

            // ═════════════════════════════════════════════════════════════════════
            '4' => [
                'number' => '4',
                'title'  => 'HAEMATOLOGY',
                'subsections' => [
                    [
                        'code'    => '4.1',  'title'   => 'Haematology Tests',
                        'columns' => ['total_exam', 'hb_lt_5_g_dl', 'hb_5_to_10_g_dl'],
                        'rows'    => [
                            $rhb('4.1', 'Full blood count'),
                            $rhb('4.2', 'HB estimation tests (other techniques)'),
                        ],
                    ],
                    [
                        'code'    => '4.3',  'title'   => 'HbA1c',
                        'columns' => ['total_exam', 'pre_diabetes', 'diabetes'],
                        'rows'    => [ $ra1c('4.3', 'Hemoglobin A1c (HbA1c)') ],
                    ],
                    [
                        'code'    => '4.4',  'title'   => 'CD4 Count',
                        'columns' => ['total_exam', 'number_lt_500'],
                        'rows'    => [ $rcd4('4.4', 'CD4 count') ],
                    ],
                    [
                        'code'    => '4.5',  'title'   => 'Other Haematology Tests',
                        'columns' => ['total_exam', 'number_positive'],
                        'rows'    => [
                            $r('4.5', 'Sickling test'),          $r('4.6', 'Peripheral blood films'),
                            $r('4.7', 'BMA'),                    $r('4.8', 'Coagulation profile'),
                            $r('4.9', 'Reticulocyte Count'),
                        ],
                    ],
                    [
                        'code'    => '4.10', 'title'   => 'ESR',
                        'columns' => ['total_exam', 'high'],
                        'rows'    => [
                            ['code' => '4.10', 'label' => 'Erythrocyte Sedimentation Rate', 'total_exam' => 0, 'high' => 0],
                        ],
                    ],
                    [
                        'code'    => '4.11', 'title'   => 'Blood Grouping',
                        'columns' => ['number'],
                        'rows'    => [
                            $rn('4.11', 'Total blood group tests'), $rn('4.12', 'Blood units grouped'),
                        ],
                    ],
                    [
                        'code'    => '4.13', 'title'   => 'Blood Safety',
                        'columns' => ['number'],
                        'rows'    => [
                            $rn('4.13', 'Blood units received from blood transfusion centres'),
                            $rn('4.14', 'Blood units collected at facility'),
                            $rn('4.15', 'Blood units transfused'),
                            $rn('4.16', 'Transfusion reactions reported and investigated'),
                            $rn('4.17', 'Blood grouping and cross matched'),
                            $rn('4.18', 'Blood units discarded'),
                        ],
                    ],
                    [
                        'code'    => '4.19', 'title'   => 'Blood Screening at Facility',
                        'columns' => ['number_positive'],
                        'rows'    => [
                            $rnp('4.19', 'HIV'),         $rnp('4.20', 'Hepatitis B'),
                            $rnp('4.21', 'Hepatitis C'), $rnp('4.22', 'Syphilis'),
                        ],
                    ],
                ],
            ],

            // ═════════════════════════════════════════════════════════════════════
            '5' => [
                'number' => '5',
                'title'  => 'BACTERIOLOGY',
                'subsections' => [
                    [
                        'title'   => 'Bacteriological Samples',
                        'code'    => '5.1',
                        'columns' => ['total_exam', 'total_cultures', 'culture_positive'],
                        'rows'    => [
                            $rcult('5.1', 'Urine'),
                            $rcult('5.2', 'Pus swab'),
                            $rcult('5.3', 'High Vaginal Swab (HVS)'),
                            $rcult('5.4', 'Throat swab'),
                            $rcult('5.5', 'Rectal swab'),
                            $rcult('5.6', 'Blood'),
                            $rcult('5.7', 'Water'),
                            $rcult('5.8', 'Food'),
                            $rcult('5.9', 'Urethral swabs'),
                        ]
                    ],
                    [
                        'title'   => 'Bacterial Enteric Pathogens / Stool Isolates',
                        'code'    => '5.10',
                        'columns' => ['total_exam', 'number_positive'],
                        'rows'    => [
                            $r('5.10', 'Stool cultures'),
                            $rnp('5.11', 'Salmonella typhi'),
                            $rnp('5.12', 'Shigella dysenteriae type 1'),
                            $rnp('5.13', 'E. coli O157:H7'),
                            $rnp('5.14', 'Vibrio cholerae O1'),
                            $rnp('5.15', 'Vibrio cholerae O139'),
                        ]
                    ],
                    [
                        'title'   => 'Bacterial Meningitis',
                        'code'    => '5.16',
                        'columns' => ['total_exam', 'number_positive', 'number_contaminated'],
                        'rows'    => [
                            $rcsf('5.16', 'CSF'),
                        ]
                    ],
                    [
                        'title'   => 'Bacterial Meningitis Serotypes',
                        'code'    => '5.17',
                        'columns' => ['number_positive'],
                        'rows'    => [
                            $rnp('5.17', 'Neisseria meningitidis A'),
                            $rnp('5.18', 'Neisseria meningitidis B'),
                            $rnp('5.19', 'Neisseria meningitidis C'),
                            $rnp('5.20', 'Neisseria meningitidis W135'),
                            $rnp('5.21', 'Neisseria meningitidis X'),
                            $rnp('5.22', 'Neisseria meningitidis Y'),
                            $rnp('5.23', 'N. meningitidis (indeterminate)'),
                            $rnp('5.24', 'Streptococcus pneumoniae'),
                            $rnp('5.25', 'Haemophilus influenzae (type b)'),
                            $rnp('5.26', 'Cryptococcal meningitis'),
                        ]
                    ],
                    [
                        'title'   => 'Bacterial Pathogens from Other Types of Specimen',
                        'code'    => '5.27',
                        'columns' => ['number_positive'],
                        'rows'    => [
                            $rnp('5.27', 'B. anthracis'),
                            $rnp('5.28', 'Y. pestis'),
                        ]
                    ],
                    [
                        'title'   => 'Sputum',
                        'code'    => '5.29',
                        'columns' => ['total_exam', 'number_positive'],
                        'rows'    => [
                            $r('5.29', 'Total TB smears'),
                            $r('5.30', 'New presumptive TB cases'),
                            $r('5.31', 'TB Follow up'),
                            $r('5.32', 'Rifampicin Resistant TB'),
                            $r('5.33', 'MDR TB'),
                        ]
                    ],
                ]
            ],

            // ═════════════════════════════════════════════════════════════════════
            '6' => [
                'number' => '6',
                'title'  => 'HISTOLOGY AND CYTOLOGY',
                'subsections' => [
                    [
                        'title'   => 'Smears',
                        'code'    => '6.1',
                        'columns' => ['total_exam', 'malignant'],
                        'rows'    => [
                            $rmal('6.1', 'PAP smear'),
                            $rmal('6.2', 'Touch preparations'),
                            $rmal('6.3', 'Tissue imprints'),
                        ]
                    ],
                    [
                        'title'   => 'Fine Needle Aspirates',
                        'code'    => '6.4',
                        'columns' => ['total_exam', 'malignant'],
                        'rows'    => [
                            $rmal('6.4', 'Thyroid'),
                            $rmal('6.5', 'Lymph nodes'),
                            $rmal('6.6', 'Liver'),
                            $rmal('6.7', 'Breast'),
                            $rmal('6.8', 'Soft tissue masses'),
                        ]
                    ],
                    [
                        'title'   => 'Fluid Cytology',
                        'code'    => '6.9',
                        'columns' => ['total_exam', 'malignant'],
                        'rows'    => [
                            $rmal('6.9', 'Ascitic fluid'),
                            $rmal('6.10', 'CSF'),
                            $rmal('6.11', 'Pleural fluid'),
                            $rmal('6.12', 'Urine'),
                        ]
                    ],
                    [
                        'title'   => 'Tissue Histology',
                        'code'    => '6.13',
                        'columns' => ['total_exam', 'malignant'],
                        'rows'    => [
                            $rmal('6.13', 'Prostate'),
                            $rmal('6.14', 'Breast tissue'),
                            $rmal('6.15', 'Ovary'),
                            $rmal('6.16', 'Uterus (Cervix)'),
                            $rmal('6.17', 'Uterus (Endometrium)'),
                            $rmal('6.18', 'Skin'),
                            $rmal('6.19', 'Head and Neck'),
                            $rmal('6.20', 'Oral'),
                            $rmal('6.21', 'Esophagus'),
                            $rmal('6.22', 'Colorectal'),
                            $rmal('6.23', 'Hepatobiliary'),
                            $rmal('6.24', 'Soft tissue and bone'),
                            $rmal('6.25', 'Lymph nodes tissue'),
                        ]
                    ],
                    [
                        'title'   => 'Bone Marrow Studies',
                        'code'    => '6.26',
                        'columns' => ['total_exam', 'malignant'],
                        'rows'    => [
                            $rmal('6.26', 'Bone marrow aspirate'),
                            $rmal('6.27', 'Trephine biopsy'),
                        ]
                    ],
                ]
            ],

            // ═════════════════════════════════════════════════════════════════════
            '7' => [
                'number' => '7',
                'title'  => 'SEROLOGY',
                'subsections' => [
                    [
                        'code'    => '7',  'title'   => 'Serology',
                        'columns' => ['total_exam', 'number_positive'],
                        'rows'    => [
                            $r('7.1', 'VDRL'),                $r('7.2', 'TPHA'),
                            $r('7.3', 'ASOT'),                $r('7.4', 'HIV'),
                            $r('7.5', 'Brucella'),            $r('7.6', 'Rheumatoid factor'),
                            $r('7.7', 'Helicobacter pylori'), $r('7.8', 'Hepatitis A test'),
                            $r('7.9', 'Hepatitis B test'),    $r('7.10', 'Hepatitis C test'),
                            $r('7.11', 'HCG'),                $r('7.12', 'CRAG Test'),
                        ],
                    ],
                ],
            ],

            // ═════════════════════════════════════════════════════════════════════
            '8' => [
                'number' => '8',
                'title'  => 'SPECIMEN REFERRAL TO HIGHER LEVELS',
                'subsections' => [
                    [
                        'code'    => '8',  'title'   => 'Specimen Referral to Higher Levels',
                        'columns' => ['number_of_specimens', 'number_of_results_received'],
                        'rows'    => [
                            $ref('8.1',  'CD4'),                  $ref('8.2',  'Viral load'),
                            $ref('8.3',  'EID'),                  $ref('8.4',  'Discordant/seroconvert'),
                            $ref('8.5',  'TB Culture'),           $ref('8.6',  'Virological'),
                            $ref('8.7',  'Clinical Chemistry'),   $ref('8.8',  'Histology/Cytology'),
                            $ref('8.9',  'Haematological'),       $ref('8.10', 'Parasitological'),
                            $ref('8.11', 'Blood samples for transfusion screening'),
                        ],
                    ],
                ],
            ],

            // ═════════════════════════════════════════════════════════════════════
            '9' => [
                'number' => '9',
                'title'  => 'DRUG SUSCEPTIBILITY TESTING',
                'type'   => 'matrix_table',
                'subsections' => [
                    [
                        'code'    => '9',
                        'title'   => 'Drug Susceptibility Testing',
                        // columns array definition explicitly for the frontend matrix
                        'matrix_columns' => [
                            ['name' => 'ciprofloxacin',                 'label' => 'Ciprofloxacin'],
                            ['name' => 'levofloxacin',                  'label' => 'Levofloxacin'],
                            ['name' => 'gentamicin_c',                  'label' => 'Gentamicin'],
                            ['name' => 'ceftazidime',                   'label' => 'Ceftazidime'],
                            ['name' => 'cefuroxime',                    'label' => 'Cefuroxime'],
                            ['name' => 'cefotaxime',                    'label' => 'Cefotaxime'],
                            ['name' => 'ampicillin',                    'label' => 'Ampicillin'],
                            ['name' => 'cefazolin',                     'label' => 'Cefazolin'],
                            ['name' => 'amikacin',                      'label' => 'Amikacin'],
                            ['name' => 'cefoxitin_oxacillin',           'label' => 'Cefoxitin/Oxacillin'],
                            ['name' => 'chloramphenicol',               'label' => 'Chloramphenicol'],
                            ['name' => 'cefepime',                      'label' => 'Cefepime'],
                            ['name' => 'obramycin',                     'label' => 'Obramycin'],
                            ['name' => 'ampicillin_sulbactam',          'label' => 'Ampicillin Sulbactam'],
                            ['name' => 'trimethoprim_sulfamethoxazole', 'label' => 'Trimethoprim Sulfamethoxazole'],
                            ['name' => 'vancomycin',                    'label' => 'Vancomycin'],
                            ['name' => 'meropenem',                     'label' => 'Meropenem'],
                            ['name' => 'clindamycin',                   'label' => 'Clindamycin'],
                            ['name' => 'doxycycline_tetracycline',      'label' => 'Doxycycline/Tetracycline'],
                            ['name' => 'ceftazidime_avibactam',         'label' => 'Ceftazidime avibactam'],
                            ['name' => 'erythromycin',                  'label' => 'Erythromycin'],
                            ['name' => 'gentamicin_aa',                 'label' => 'Gentamicin']
                        ],
                        'rows'    => array_map(function($code, $label) {
                            $row = ['code' => $code, 'label' => $label];
                            $drugs = [
                                'ciprofloxacin', 'levofloxacin', 'gentamicin_c', 'ceftazidime',
                                'cefuroxime', 'cefotaxime', 'ampicillin', 'cefazolin', 'amikacin',
                                'cefoxitin_oxacillin', 'chloramphenicol', 'cefepime', 'obramycin',
                                'ampicillin_sulbactam', 'trimethoprim_sulfamethoxazole', 'vancomycin',
                                'meropenem', 'clindamycin', 'doxycycline_tetracycline',
                                'ceftazidime_avibactam', 'erythromycin', 'gentamicin_aa'
                            ];
                            foreach($drugs as $drug) {
                                $row[$drug] = 0;
                            }
                            return $row;
                        }, 
                        ['9.1', '9.2', '9.3', '9.4', '9.5', '9.6', '9.7', '9.8', '9.9', '9.10', '9.11', '9.12', '9.13', '9.14'],
                        [
                            'E. coli O157:H7', 'Proteus spp', 'Salmonella spp', 'Shigella spp',
                            'Klebsiella pneumoniae', 'Pseudomonas spp', 'Staphylococcus aureus', 'Vibrio cholerae spp',
                            'Neisseria meningitidis', 'Neisseria gonorrhoeae', 'Streptococcus pneumoniae',
                            'Haemophilus influenzae', 'Haemophilus parainfluenzae', 'Bacterial vaginosis'
                        ])
                    ],
                ]
            ],
        ];
    }
}

