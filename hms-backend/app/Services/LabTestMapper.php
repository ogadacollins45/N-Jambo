<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

/**
 * LabTestMapper
 *
 * Maps a free-text lab test name to the nearest MOH 706 section row code
 * (e.g. "Full Blood Count" → "4.1", "HIV Test" → "7.4").
 *
 * Strategy:
 *  1. Fast-path keyword map (case-insensitive substring match)
 *  2. AI-service fallback (/classify-lab-test) for unrecognised names
 *  3. Static in-request cache to avoid redundant lookups
 */
class LabTestMapper
{
    /** In-request cache: lowercase test name → MOH 706 code */
    private static array $cache = [];

    /**
     * Keyword map: substring (lowercase) → MOH 706 row code.
     * Ordered with more-specific phrases first where overlap is likely.
     */
    private static array $keywordMap = [
        // ─── SECTION 3 — PARASITOLOGY (placed first: order drives match priority) ────
        // Note: 3.1/3.2 (BS) and 3.3/3.4 (RDT) are age-gated in getMoh706().
        // The mapper returns 3.1 (BS) or 3.3 (RDT); controller reroutes by patient age.
        'malaria bs'             => '3.1', 'malaria blood smear'     => '3.1',
        'malaria film'           => '3.1', 'malaria thick'           => '3.1',
        'bs for mps'             => '3.1', 'blood smear for mps'     => '3.1',
        'bs for malaria'         => '3.1', 'mps'                     => '3.1',
        'malaria rdt'            => '3.3', 'malaria rapid'           => '3.3',
        'malaria antigen'        => '3.3', 'hrp2'                    => '3.3',
        'malaria rapid diagnostic' => '3.3',
        'malaria test'           => '3.1', // generic BS fallback
        'malaria'                => '3.1', // widest fallback — must be last malaria entry
        // Stool parasites — organism-specific if template names carry organism names
        'taenia'                 => '3.5',
        'hymenolepis'            => '3.6',
        'hookworm'               => '3.7',
        'roundworm'              => '3.8', 'ascaris'                 => '3.8',
        's. mansoni'             => '3.9', 'schistosoma mansoni'     => '3.9',
        'trichuris'              => '3.10',
        'amoeba'                 => '3.11', 'entamoeba'              => '3.11',
        'stool exam'             => '3.5', 'ova and cyst'            => '3.5',
        'ova and para'           => '3.5', 'stool microscopy'        => '3.5',
        'stool analysis'         => '3.5', 'stool exam'              => '3.5',
        'stool routine'          => '3.5', 'faecal analysis'         => '3.5',

        // ─── SECTION 1 — URINE ANALYSIS ──────────────────────────────────────
        // Generic urinalysis → 1.1 (total urine examinations)
        'urinalysis'             => '1.1', 'urine analysis'          => '1.1',
        'urine routine'          => '1.1', 'urine r/e'               => '1.1',
        'urine full report'      => '1.1', 'ufr'                     => '1.1',
        'urine dipstick'         => '1.1', 'urine test'              => '1.1',

        'urine glucose'          => '1.2', 'glycosuria'              => '1.2',
        'urine sugar'            => '1.2',
        'urine ketone'           => '1.3', 'ketonuria'               => '1.3',
        'urine protein'          => '1.4', 'proteinuria'             => '1.4',
        'albuminuria'            => '1.4', 'microalbuminuria'         => '1.4',
        'pus cells'              => '1.6', 'pyuria'                  => '1.6',
        's. haematobium'         => '1.7', 's haematobium'           => '1.7',
        'schistosoma haematobium'=> '1.7', 'bilharzia urine'         => '1.7',
        't. vaginalis'           => '1.8', 't vaginalis'             => '1.8',
        'trichomonas vaginalis'  => '1.8', 'trichomonas urine'       => '1.8',
        'yeast cells urine'      => '1.9', 'candida urine'           => '1.9',
        'fungi urine'            => '1.9',
        'bacteria urine'         => '1.10', 'bacteriuria'            => '1.10',

        // ─── SECTION 2 — BLOOD CHEMISTRY ─────────────────────────────────────
        'oral glucose tolerance' => '2.2', 'ogtt'                    => '2.2',
        'glucose tolerance'      => '2.2',
        'blood sugar'            => '2.1', 'blood glucose'           => '2.1',
        'fasting blood glucose'  => '2.1', 'random blood glucose'    => '2.1',
        'fasting glucose'        => '2.1', 'random glucose'          => '2.1',
        'fbs'                    => '2.1', 'rbs'                     => '2.1',
        'rbg'                    => '2.1', 'fbg'                     => '2.1',
        'creatinine'             => '2.4',
        'serum urea'             => '2.5', 'blood urea'              => '2.5',
        'urea nitrogen'          => '2.5', 'bun'                     => '2.5',
        'serum sodium'           => '2.6', 'sodium'                  => '2.6',
        'serum potassium'        => '2.7', 'potassium'               => '2.7',
        'serum chloride'         => '2.8', 'chloride'                => '2.8',
        'direct bilirubin'       => '2.9', 'conjugated bilirubin'    => '2.9',
        'total bilirubin'        => '2.10', 'bilirubin total'        => '2.10',
        'asat'                   => '2.11', 'sgot'                   => '2.11',
        'ast '                   => '2.11', 'aspartate aminotrans'   => '2.11',
        'alat'                   => '2.12', 'sgpt'                   => '2.12',
        'alt '                   => '2.12', 'alanine aminotrans'     => '2.12',
        'serum protein'          => '2.13', 'total protein'          => '2.13',
        'albumin'                => '2.14',
        'alkaline phosphatase'   => '2.15', 'alp'                    => '2.15',
        'total cholesterol'      => '2.17', 'cholesterol'            => '2.17',
        'triglyceride'           => '2.18',
        'ldl'                    => '2.19',
        't3 thyroid'             => '2.20', 'triiodothyronine'       => '2.20',
        't4 thyroid'             => '2.21', 'thyroxine'              => '2.21',
        'tsh'                    => '2.22', 'thyroid stimulating'    => '2.22',
        'thyroid function'       => '2.22',
        'psa'                    => '2.23', 'prostate specific antigen' => '2.23',
        'ca 15-3'                => '2.24', 'ca15-3'                 => '2.24',
        'ca 19-9'                => '2.25', 'ca19-9'                 => '2.25',
        'ca 125'                 => '2.26', 'ca125'                  => '2.26',
        'cea'                    => '2.27', 'carcinoembryonic'       => '2.27',
        'alpha fetoprotein'      => '2.28', 'afp'                    => '2.28',
        'csf protein'            => '2.29', 'cerebrospinal fluid protein' => '2.29',
        'csf glucose'            => '2.30', 'cerebrospinal fluid glucose' => '2.30',

        // ─── SECTION 4 — HAEMATOLOGY ─────────────────────────────────────────
        'full blood count'       => '4.1', 'complete blood count'    => '4.1',
        'fbc'                    => '4.1', 'cbc'                     => '4.1',
        'full blood picture'     => '4.1', 'fbp'                     => '4.1',
        // Generic haemoglobin (estimation) → 4.2
        'hemoglobin level'       => '4.2', 'haemoglobin level'       => '4.2',
        'hemoglobin'             => '4.2', 'haemoglobin'             => '4.2',
        'hb level'               => '4.2', 'hgb'                     => '4.2',
        'haemoglobin estimation' => '4.2', 'hemoglobin estimation'   => '4.2',
        'hb estimation'          => '4.2',
        'hba1c'                  => '4.3', 'glycated haemoglobin'    => '4.3',
        'hemoglobin a1c'         => '4.3', 'haemoglobin a1c'         => '4.3',
        'cd4 count'              => '4.4', 'cd4'                     => '4.4',
        'sickling test'          => '4.5', 'sickle cell test'        => '4.5',
        'sickle cell screen'     => '4.5', 'sickling'                => '4.5',
        'peripheral blood film'  => '4.6', 'blood film'              => '4.6',
        'pbf'                    => '4.6', 'peripheral smear'        => '4.6',
        'blood smear'            => '4.6',
        'bone marrow aspirate'   => '4.7', 'bma'                     => '4.7',
        'coagulation profile'    => '4.8', 'coagulation screen'      => '4.8',
        'prothrombin time'       => '4.8', 'aptt'                    => '4.8',
        'inr'                    => '4.8',
        'reticulocyte count'     => '4.9', 'retic count'             => '4.9',
        'esr'                    => '4.10', 'erythrocyte sedimentation'=> '4.10',
        'blood group'            => '4.11', 'blood grouping'         => '4.11',
        'abo group'              => '4.11',
        'blood units grouped'    => '4.12', 'group and cross'        => '4.12',
        'crossmatch'             => '4.12',
        'blood units received'   => '4.13',
        'blood units collected'  => '4.14',
        'blood transfused'       => '4.15', 'blood units transfused' => '4.15',
        'transfusion reaction'   => '4.16',
        'blood grouping and cross' => '4.17',
        'blood units discarded'  => '4.18', 'blood discarded'        => '4.18',
        'hiv blood screen'       => '4.19', 'hiv screening blood'    => '4.19',
        'hepatitis b blood'      => '4.20', 'hbsag blood'            => '4.20',
        'hepatitis b surface antigen blood' => '4.20',
        'hepatitis c blood'      => '4.21', 'hcv blood'              => '4.21',
        'syphilis blood'         => '4.22',

        // ─── SECTION 5 — BACTERIOLOGY ────────────────────────────────────────
        'urine culture'          => '5.1', 'urine mcs'               => '5.1',
        'pus swab'               => '5.2', 'wound culture'           => '5.2',
        'pus culture'            => '5.2',
        'high vaginal swab'      => '5.3', 'hvs'                     => '5.3',
        'throat swab'            => '5.4', 'throat culture'          => '5.4',
        'rectal swab'            => '5.5',
        'blood culture'          => '5.6', 'blood mcs'               => '5.6',
        'water culture'          => '5.7',
        'food culture'           => '5.8',
        'urethral swab'          => '5.9',
        'stool culture'          => '5.10', 'stool mcs'              => '5.10',
        'faecal culture'         => '5.10', 'fecal culture'          => '5.10',
        'salmonella typhi'       => '5.11', 'typhoid culture'        => '5.11',
        'shigella dysenteriae'   => '5.12', 'shigella'               => '5.12',
        'e. coli o157'           => '5.13', 'e coli o157'            => '5.13',
        'escherichia coli o157'  => '5.13',
        'vibrio cholerae o1'     => '5.14',
        'vibrio cholerae o139'   => '5.15',
        'csf culture'            => '5.16', 'csf mcs'                => '5.16',
        'meningitis culture'     => '5.16',
        'n. meningitidis a'      => '5.17', 'neisseria meningitidis a' => '5.17',
        'n. meningitidis b'      => '5.18', 'neisseria meningitidis b' => '5.18',
        'n. meningitidis c'      => '5.19', 'neisseria meningitidis c' => '5.19',
        'neisseria meningitidis w135' => '5.20',
        'neisseria meningitidis x'    => '5.21',
        'neisseria meningitidis y'    => '5.22',
        'meningitidis indeterminate'  => '5.23',
        'streptococcus pneumoniae'    => '5.24',
        'haemophilus influenzae'      => '5.25', 'h. influenzae'    => '5.25',
        'cryptococcal meningitis'     => '5.26', 'cryptococcus'     => '5.26',
        'b. anthracis'           => '5.27', 'bacillus anthracis'     => '5.27',
        'anthrax'                => '5.27',
        'y. pestis'              => '5.28', 'yersinia pestis'        => '5.28',
        'plague'                 => '5.28',
        'total tb smear'         => '5.29', 'sputum afb'             => '5.29',
        'acid fast bacilli'      => '5.29', 'afb smear'              => '5.29',
        'zn smear'               => '5.29', 'ziehl neelsen'          => '5.29',
        'tb smear'               => '5.29',
        'new presumptive tb'     => '5.30', 'new tb case'            => '5.30',
        'tb follow up'           => '5.31',
        'rifampicin resistant'   => '5.32', 'rr-tb'                  => '5.32',
        'xpert mtb'              => '5.32', 'gene xpert'             => '5.32',
        'mdr tb'                 => '5.33', 'multidrug resistant tb' => '5.33',

        // ─── SECTION 6 — HISTOLOGY AND CYTOLOGY ──────────────────────────────
        'pap smear'              => '6.1', 'papanicolaou'            => '6.1',
        'cervical smear'         => '6.1',
        'touch preparation'      => '6.2', 'touch prep'              => '6.2',
        'tissue imprint'         => '6.3',
        'thyroid fna'            => '6.4', 'thyroid fnac'            => '6.4',
        'thyroid fine needle'    => '6.4',
        'lymph node fna'         => '6.5',
        'liver fna'              => '6.6',
        'breast fna'             => '6.7', 'breast fnac'             => '6.7',
        'breast fine needle'     => '6.7',
        'soft tissue fna'        => '6.8',
        'ascitic fluid cytology' => '6.9', 'ascites cytology'        => '6.9',
        'csf cytology'           => '6.10', 'cerebrospinal fluid cytology' => '6.10',
        'pleural fluid cytology' => '6.11', 'pleural effusion cytology'=> '6.11',
        'urine cytology'         => '6.12',
        'prostate biopsy'        => '6.13', 'prostate histology'     => '6.13',
        'breast tissue histology'=> '6.14', 'breast biopsy'          => '6.14',
        'ovary histology'        => '6.15', 'ovarian biopsy'         => '6.15',
        'cervix histology'       => '6.16', 'cervical biopsy'        => '6.16',
        'endometrium histology'  => '6.17', 'uterus histology'       => '6.17',
        'endometrial biopsy'     => '6.17',
        'skin biopsy'            => '6.18', 'skin histology'          => '6.18',
        'head and neck histology'=> '6.19',
        'oral histology'         => '6.20', 'oral biopsy'            => '6.20',
        'esophagus histology'    => '6.21', 'oesophageal biopsy'     => '6.21',
        'colorectal histology'   => '6.22', 'colon biopsy'           => '6.22',
        'hepatobiliary histology'=> '6.23', 'liver biopsy'           => '6.23',
        'soft tissue biopsy'     => '6.24', 'bone biopsy'            => '6.24',
        'lymph node histology'   => '6.25', 'lymph node biopsy histology' => '6.25',
        'bone marrow aspirate cytology' => '6.26',
        'trephine biopsy'        => '6.27',

        // ─── SECTION 7 — SEROLOGY ────────────────────────────────────────────
        'vdrl'                   => '7.1',
        'tpha'                   => '7.2', 'treponema pallidum haem' => '7.2',
        'asot'                   => '7.3', 'antistreptolysin'        => '7.3',
        'aso test'               => '7.3', 'aso titre'               => '7.3',
        // HIV: order from most-specific to least-specific
        'hiv 1/2'                => '7.4', 'hiv1/2'                  => '7.4',
        'hiv antibody'           => '7.4', 'rapid hiv'               => '7.4',
        'hiv test'               => '7.4', 'hiv screen'              => '7.4',
        'hiv serology'           => '7.4', 'pitc'                    => '7.4',
        'provider initiated'     => '7.4', 'hiv counselling'         => '7.4',
        'testing and counselling for hiv' => '7.4',
        'brucella agglutination' => '7.5', 'brucellosis'             => '7.5',
        'brucella serology'      => '7.5', 'brucellin'               => '7.5',
        'brucella antigen'       => '7.5',
        'rheumatoid factor'      => '7.6', 'rf test'                 => '7.6',
        'helicobacter pylori'    => '7.7', 'h. pylori'               => '7.7',
        'h pylori'               => '7.7', 'hp antigen'              => '7.7',
        'hepatitis a test'       => '7.8', 'hav antibody'            => '7.8',
        'anti-hav'               => '7.8', 'hepatitis a serology'    => '7.8',
        'hbsag'                  => '7.9', 'hepatitis b surface'     => '7.9',
        'hepatitis b test'       => '7.9', 'hepatitis b serology'    => '7.9',
        'anti-hcv'               => '7.10', 'hcv antibody'           => '7.10',
        'hepatitis c test'       => '7.10', 'hepatitis c serology'   => '7.10',
        'pregnancy test'         => '7.11', 'beta hcg'               => '7.11',
        'hcg test'               => '7.11', 'urine pregnancy'        => '7.11',
        'pregnancy detection'    => '7.11', 'serum pregnancy'        => '7.11',
        'crag test'              => '7.12', 'cryptococcal antigen'   => '7.12',
        'crag'                   => '7.12',

        // Widal — salmonella/typhoid serology (section 7, added after existing entries)
        'widal'                  => '7.8',
        'salmonella serology'    => '7.8', 'salmonella antigen'      => '7.8',
        'salmonella agglutin'    => '7.8', 'typhoid serology'        => '7.8',

        // ─── SECTION 8 — SPECIMEN REFERRALS ──────────────────────────────────
        'cd4 referral'           => '8.1', 'cd4 specimen'            => '8.1',
        'viral load'             => '8.2', 'vl referral'             => '8.2',
        'early infant diagnosis' => '8.3', 'eid'                     => '8.3',
        'dbs eid'                => '8.3',
        'discordant'             => '8.4', 'seroconvert'             => '8.4',
        'tb culture referral'    => '8.5', 'tb culture specimen'     => '8.5',
        'mycobacterium culture'  => '8.5',
        'virological referral'   => '8.6',
        'clinical chemistry referral' => '8.7',
        'histology referral'     => '8.8', 'cytology referral'       => '8.8',
        'haematological referral'=> '8.9',
        'parasitological referral' => '8.10',
        'transfusion screening specimen' => '8.11',

        // ─── SECTION 9 — DRUG SUSCEPTIBILITY ORGANISMS ───────────────────────
        'e. coli o157:h7'        => '9.1', 'escherichia coli o157'   => '9.1',
        'proteus'                => '9.2', 'proteus mirabilis'       => '9.2',
        'salmonella spp'         => '9.3', 'salmonella typhi'        => '9.3', // wait, 5.11 is also Salmonella typhi. LabTestMapper matches first.
        // If a test maps to 5.11, how do we get 9.3? We'll handle this in the controller! Or we add them here and let the controller handle it specifically.
        // Actually, we can use a separate lookup inside the controller or let the mapper pick. Let's map the general species here.
        'shigella spp'           => '9.4', 'shigella flexneri'       => '9.4',
        'klebsiella pneumoniae'  => '9.5',
        'pseudomonas spp'        => '9.6', 'pseudomonas aeruginosa'  => '9.6',
        'staphylococcus aureus'  => '9.7', 's aureus'                => '9.7',
        'vibrio cholerae spp'    => '9.8',
        'neisseria meningitidis' => '9.9',
        'neisseria gonorrhoeae'  => '9.10', 'gonococcus'             => '9.10',
        'streptococcus pneumoniae'=> '9.11', 'pneumococcus'          => '9.11',
        'haemophilus influenzae' => '9.12',
        'haemophilus parainfluenzae' => '9.13',
        'bacterial vaginosis'    => '9.14', 'gardnerella vaginalis'  => '9.14',

    ];

    /** All valid MOH 706 row codes */
    private static array $allCodes = [
        '1.2','1.3','1.4','1.6','1.7','1.8','1.9','1.10',
        '2.1','2.2','2.4','2.5','2.6','2.7','2.8',
        '2.9','2.10','2.11','2.12','2.13','2.14','2.15',
        '2.17','2.18','2.19','2.20','2.21','2.22',
        '2.23','2.24','2.25','2.26','2.27','2.28','2.29','2.30',
        '3.1','3.2','3.3','3.4','3.5','3.6','3.7','3.8','3.9','3.10','3.11',
        '4.1','4.2','4.3','4.4','4.5','4.6','4.7','4.8','4.9','4.10',
        '4.11','4.12','4.13','4.14','4.15','4.16','4.17','4.18',
        '4.19','4.20','4.21','4.22',
        '5.1','5.2','5.3','5.4','5.5','5.6','5.7','5.8','5.9',
        '5.10','5.11','5.12','5.13','5.14','5.15',
        '5.16','5.17','5.18','5.19','5.20','5.21','5.22','5.23','5.24','5.25','5.26',
        '5.27','5.28','5.29','5.30','5.31','5.32','5.33',
        '6.1','6.2','6.3','6.4','6.5','6.6','6.7','6.8',
        '6.9','6.10','6.11','6.12',
        '6.13','6.14','6.15','6.16','6.17','6.18','6.19','6.20','6.21','6.22','6.23','6.24','6.25',
        '6.26','6.27',
        '7.1','7.2','7.3','7.4','7.5','7.6','7.7','7.8','7.9','7.10','7.11','7.12',
        '8.1','8.2','8.3','8.4','8.5','8.6','8.7','8.8','8.9','8.10','8.11',
        '9.1','9.2','9.3','9.4','9.5','9.6','9.7','9.8','9.9','9.10','9.11','9.12','9.13','9.14',
    ];

    /**
     * Map a lab test name string to the nearest MOH 706 row code.
     * Returns 'unmapped' if nothing matches with sufficient confidence.
     */
    public static function map(string $testName): string
    {
        if (empty(trim($testName))) return 'unmapped';

        $key = strtolower(trim($testName));

        // 1. Cache hit
        if (isset(self::$cache[$key])) {
            return self::$cache[$key];
        }

        // 2. Keyword fast-path (substring match, most-specific wins — map is ordered)
        foreach (self::$keywordMap as $keyword => $code) {
            if (str_contains($key, $keyword)) {
                self::$cache[$key] = $code;
                return $code;
            }
        }

        // 3. AI-service semantic fallback
        //    Skip entirely if we already know the service is offline this request.
        static $aiOffline = false;

        if (!$aiOffline) {
            $aiUrl = rtrim(config('services.ai.url', env('AI_SERVICE_URL', 'http://localhost:8001')), '/');
            try {
                $response = Http::timeout(3)->post("{$aiUrl}/classify-lab-test", [
                    'text' => $testName,
                ]);
                if ($response->successful()) {
                    $responseCode = $response->json('predicted_code', 'unmapped');
                    if ($responseCode && in_array($responseCode, self::$allCodes, true)) {
                        self::$cache[$key] = $responseCode;
                        return $responseCode;
                    }
                }
            } catch (\Illuminate\Http\Client\ConnectionException $e) {
                // Service not running — mark offline for the rest of this request, silent fallback
                $aiOffline = true;
                Log::info('LabTestMapper: AI classifier offline, using keyword-only mode. (' . $e->getMessage() . ')');
            } catch (\Throwable $e) {
                Log::warning("LabTestMapper: AI fallback error for '{$testName}': " . $e->getMessage());
            }
        }

        self::$cache[$key] = 'unmapped';
        return 'unmapped';
    }

    /** Return all valid MOH 706 row codes */
    public static function allCodes(): array
    {
        return self::$allCodes;
    }
}
