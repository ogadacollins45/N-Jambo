<?php

namespace App\Services;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

/**
 * DiseaseMapper
 *
 * Maps a treatment's diagnosis (free text) + diagnosis_category + diagnosis_subcategory
 * to one of the 73 official MOH disease rows.
 *
 * Classification strategy (in priority order):
 *  1. Cache lookup – return immediately if this exact text was classified before
 *  2. AI microservice – call FastAPI/Sentence-Transformers service if available
 *     (accepts result when confidence >= AI_DISEASE_CLASSIFIER_CONFIDENCE_THRESHOLD)
 *  3. Keyword match on free-text  (original Tier-1)
 *  4. Subcategory-based mapping   (original Tier-2)
 *  5. Category-level broad match  (original Tier-3)
 *  6. Fallback → 'other_diseases'
 */
class DiseaseMapper
{
    /** Seconds to cache a classification result (24 hours) */
    private const CACHE_TTL = 86400;

    /** Cache key prefix */
    private const CACHE_PREFIX = 'disease_map:';

    // ─────────────────────────────────────────────────────────────────────────
    // Public API
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Map a single diagnosis to a disease key.
     *
     * @param string|null $diagnosisText   Free-text diagnosis (e.g. "Malaria falciparum")
     * @param string|null $category        DIAGNOSIS_CATEGORIES key (e.g. "Infectious")
     * @param string|null $subcategory     Sub-key (e.g. "Parasitic")
     * @return string  One of the 73 disease keys or 'other_diseases'
     */
    public static function map(?string $diagnosisText, ?string $category, ?string $subcategory): string
    {
        $text = strtolower(trim($diagnosisText ?? ''));
        $cat  = strtolower(trim($category ?? ''));
        $sub  = strtolower(trim($subcategory ?? ''));

        if (empty($text) && empty($cat) && empty($sub)) {
            return 'other_diseases';
        }

        // ── 1. Cache lookup ──────────────────────────────────────────────────
        $cacheKey = self::CACHE_PREFIX . md5($text . '|' . $cat . '|' . $sub);
        $cached   = Cache::get($cacheKey);
        if ($cached !== null) {
            return $cached;
        }

        // ── 2. AI microservice (primary, high-confidence path) ───────────────
        $aiKey = self::classifyViaAI($text);
        if ($aiKey !== null) {
            Cache::put($cacheKey, $aiKey, self::CACHE_TTL);
            return $aiKey;
        }

        // ── 3. Keyword match on free-text ────────────────────────────────────
        $textKey = self::matchText($text);
        if ($textKey) {
            Cache::put($cacheKey, $textKey, self::CACHE_TTL);
            return $textKey;
        }

        // ── 4. Subcategory-based mapping ──────────────────────────────────────
        $subKey = self::matchSubcategory($sub, $cat);
        if ($subKey) {
            Cache::put($cacheKey, $subKey, self::CACHE_TTL);
            return $subKey;
        }

        // ── 5. Category-level broad fallback ─────────────────────────────────
        $catKey = self::matchCategory($cat);
        if ($catKey) {
            Cache::put($cacheKey, $catKey, self::CACHE_TTL);
            return $catKey;
        }

        // ── 6. Final fallback ─────────────────────────────────────────────────
        Cache::put($cacheKey, 'other_diseases', self::CACHE_TTL);
        return 'other_diseases';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // AI microservice call
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Call the local FastAPI AI classifier and return the disease key if confidence
     * meets the configured threshold, or null if the service is unavailable / low confidence.
     */
    private static function classifyViaAI(string $text): ?string
    {
        if (empty($text)) {
            return null;
        }

        $url       = config('services.ai_classifier.url', env('AI_DISEASE_CLASSIFIER_URL'));
        $threshold = (float) config('services.ai_classifier.threshold', env('AI_DISEASE_CLASSIFIER_CONFIDENCE_THRESHOLD', 0.60));
        $timeout   = (int)   config('services.ai_classifier.timeout',   env('AI_DISEASE_CLASSIFIER_TIMEOUT', 5));

        if (empty($url)) {
            return null;
        }

        try {
            $response = Http::timeout($timeout)
                ->post($url, ['text' => $text]);

            if ($response->successful()) {
                $data       = $response->json();
                $aiCategory = $data['predicted_category'] ?? null;
                $confidence = (float) ($data['confidence'] ?? 0.0);

                if ($aiCategory && $confidence >= $threshold) {
                    Log::debug("DiseaseMapper AI: '{$text}' → '{$aiCategory}' ({$confidence})");
                    return $aiCategory;
                }

                Log::debug("DiseaseMapper AI low confidence ({$confidence}) for '{$text}', falling back.");
            } else {
                Log::warning("DiseaseMapper AI service returned HTTP {$response->status()} for '{$text}'");
            }
        } catch (\Illuminate\Http\Client\ConnectionException $e) {
            // Service not running — silent fallback, no stack trace needed
            Log::info('DiseaseMapper: AI classifier offline, using keyword fallback. (' . $e->getMessage() . ')');
        } catch (\Throwable $e) {
            Log::warning('DiseaseMapper: AI classifier error — ' . $e->getMessage());
        }

        return null;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Free-text keyword matching (Tier-1 fallback)
    // ─────────────────────────────────────────────────────────────────────────
    private static function matchText(string $t): ?string
    {
        if (empty($t)) return null;

        // Exact or strong keyword matches — ordered from most specific to least
        $map = [
            // Diarrhoeal / GI
            'diarrhoea'               => ['diarrhoea', 'diarrhea', 'gastroenteritis', 'gastroenteritris', 'ge', 'loose stool', 'loose motions', 'dehydration', 'amoebiasis'],
            'dysentery'               => ['dysentery', 'bloody diarrhoea', 'bloody diarrhea', 'haemorrhagic diarrhoea'],
            'cholera'                 => ['cholera'],
            'intestinal_worms'        => ['worm', 'helminth', 'ascaris', 'hookworm', 'roundworm', 'tapeworm', 'pinworm', 'threadworm'],
            'bilharzia'               => ['bilharzia', 'schistosoma', 'schistosomiasis'],
            'typhoid_fever'           => ['typhoid', 'typhoid fever', 'salmonella typhi'],

            // Respiratory
            'upper_rti'               => ['urti', 'upper respiratory', 'common cold', 'rhinitis', 'allergic rhinitis', 'pharyngitis', 'tonsilitis', 'tonsillitis', 'acute tonsills', 'sinusitis', 'coryza', 'sore throat', 'cough', 'epistaxis', 'nose bleeding'],
            'pneumonia'               => ['pneumonia', 'pneumonitis', 'lobar pneumonia', 'community acquired pneumonia', 'bronchopneumonia'],
            'asthma'                  => ['asthma', 'bronchial asthma', 'reactive airway'],
            'other_respiratory'       => ['copd', 'bronchitis', 'pleural', 'pleurisy', 'emphysema', 'respiratory'],

            // Malaria
            'confirmed_malaria'       => ['confirmed malaria', 'malaria positive', 'plasmodium', 'malaria falciparum', 'malaria vivax', 'malaria malariae', 'blood slide positive', 'rdt positive'],
            'malaria_in_pregnancy'    => ['malaria in pregnancy', 'malaria pregnancy', 'mip'],
            'suspected_malaria'       => ['suspected malaria', 'sus mal', 'febrile illness', 'malaria'],

            // Fevers (catch after malaria)
            'fevers'                  => ['fever', 'pyrexia', 'hyperthermia', 'feverish', 'bacteremia', 'bacterial infection', 'acute bacterial infection', 'severe bacterial infection'],

            // Infections
            'tuberculosis'            => ['tuberculosis', 'tb ', ' tb', 'mycobacterium', 'koch', 'ptb', 'eptb', 'pulmonary tb'],
            'meningococcal_meningitis'=> ['meningococcal meningitis', 'neisseria meningitidis', 'meningococcal'],
            'other_meningitis'        => ['meningitis', 'bacterial meningitis', 'viral meningitis', 'cryptococcal meningitis'],
            'tetanus'                 => ['tetanus', 'lockjaw', 'clostridium tetani'],
            'poliomyelitis'           => ['polio', 'afp', 'acute flaccid paralysis', 'poliomyelitis'],
            'chicken_pox'             => ['chicken pox', 'chickenpox', 'varicella'],
            'measles'                 => ['measles', 'rubeola'],
            'hepatitis'               => ['hepatitis', 'jaundice', 'liver infection', 'hbsag'],
            'mumps'                   => ['mumps', 'parotitis', 'parotid'],
            'brucellosis'             => ['brucellosis', 'brucella', 'undulant fever'],
            'trypanosomiasis'         => ['trypanosomiasis', 'sleeping sickness', 'trypanosoma'],
            'kalazar'                 => ['kala-azar', 'kalazar', 'leishmaniasis', 'leishmania'],
            'dracunculosis'           => ['dracunculosis', 'guinea worm', 'dracunculus'],
            'yellow_fever'            => ['yellow fever'],
            'viral_haemorrhagic'      => ['vhf', 'viral haemorrhagic', 'ebola', 'marburg', 'rift valley fever', 'haemorrhagic fever'],
            'plague'                  => ['plague', 'yersinia pestis'],

            // STIs / HIV
            'sti'                     => ['sti', 'sexually transmitted', 'gonorrhoea', 'gonorrhea', 'syphilis', 'chlamydia', 'genital ulcer', 'herpes genitalis', 'vaginitis', 'urethral discharge', 'pid', 'pelvic inflammatory', 'balanitis'],
            'newly_diagnosed_hiv'     => ['newly diagnosed hiv', 'new hiv', 'hiv positive', 'hiv diagnosis', 'hiv confirmed', 'hiv seropositive'],

            // Urinary
            'uti'                     => ['uti', 'urinary tract infection', 'cystitis', 'pyelonephritis', 'urinary infection', 'dysuria', 'lower urinary tract obstruction', 'luto'],

            // Eye
            'eye_infections'          => ['conjunctivitis', 'conjuctivitis', 'allergic conjuctivitis', 'eye infection', 'ophthalmia', 'trachoma', 'keratitis'],
            'other_eye'               => ['eye', 'cataract', 'glaucoma', 'refractive error', 'visual', 'blindness', 'retinal'],

            // Ear
            'ear_infections'          => ['otitis', 'om', 'ear infection', 'ear discharge', 'deafness', 'hearing loss', 'ear pain', 'otalgia', 'earache', 'tinitus', 'tinnitus'],

            // Nutrition
            'malnutrition'            => ['malnutrition', 'kwashiorkor', 'marasmus', 'undernutrition', 'wasting', 'stunting', 'failure to thrive', 'nutritional deficiency'],
            'overweight'              => ['overweight', 'obesity', 'bmi >25', 'bmi>25', 'obese'],
            'anaemia'                 => ['anaemia', 'anemia', 'haemoglobin', 'low hb', 'iron deficiency', 'sickle cell'],

            // Maternal
            'abortion'                => ['abortion', 'miscarriage', 'incomplete abortion', 'spontaneous abortion'],
            'puerperium'              => ['puerperium', 'childbirth', 'postpartum', 'puerperal', 'obstetric', 'labour complications', 'postpartum haemorrhage', 'eclampsia', 'pre-eclampsia', 'peurperal sepsis', 'puerperal sepsis'],

            // Chronic / NCDs
            'hypertension'            => ['hypertension', 'high blood pressure', 'hbp', 'elevated bp', 'hypertensive', 'htn'],
            'diabetes'                => ['diabetes', 'diabetic', 'dm type', 'dm', 'type 1 diabetes', 'type 2 diabetes', 'dka', 'hypoglycaemia', 'hyperglycaemia'],
            'epilepsy'                => ['epilepsy', 'epileptic', 'seizure', 'convulsion', 'fits', 'status epilepticus'],
            'cardiovascular'          => ['heart failure', 'cardiac', 'angina', 'myocardial', 'coronary', 'arrhythmia', 'atrial fibrillation', 'heart disease', 'cardiovascular'],
            'cns_conditions'          => ['stroke', 'hemiplegia', 'paraplegia', 'cerebral', 'parkinson', 'dementia', 'neurological', 'cns', 'migraine', 'migrain', 'headache'],
            'mental_disorders'        => ['mental', 'psychiatric', 'depression', 'schizophrenia', 'bipolar', 'anxiety disorder', 'psychosis', 'ptsd', 'substance abuse'],
            'dental_disorders'        => ['dental', 'tooth', 'teeth', 'caries', 'gingivitis', 'periodontitis', 'oral', 'jaw'],
            'arthritis_joints'        => ['arthritis', 'joint pain', 'gout', 'osteoarthritis', 'rheumatoid', 'musculoskeletal', 'joint swelling', 'backache', 'lower back pain', 'lumbago', 'sciatica', 'mayalgia', 'myalgia'],
            'muscular_skeletal'       => ['fracture', 'sprain', 'muscle strain', 'dislocation', 'skeletal', 'bone'],
            'skin_diseases'           => ['skin', 'dermatitis', 'eczema', 'psoriasis', 'fungal infection', 'tinea', 'scabies', 'ringworm', 'rash', 'urticaria', 'cellulitis', 'pruritis', 't. unguium', 'taenia pedis'],
            'jiggers'                 => ['jigger', 'tungiasis'],
            'neoplasms'               => ['cancer', 'carcinoma', 'tumour', 'tumor', 'neoplasm', 'lymphoma', 'leukaemia', 'leukemia', 'malignancy', 'sarcoma', 'mass in the breast'],
            'fistula'                 => ['fistula', 'obstetric fistula', 'vesicovaginal', 'rectovaginal'],
            'physical_disability'     => ['disability', 'amputee', 'cerebral palsy', 'physically challenged'],

            // Injuries
            'road_traffic_injuries'   => ['rta', 'road traffic', 'road accident', 'mvt', 'motor vehicle', 'boda boda', 'motorcycle accident', 'pedestrian hit'],
            'deaths_road_traffic'     => ['death rta', 'died road traffic', 'fatal road accident'],
            'other_injuries'          => ['fall', 'injury', 'trauma', 'laceration', 'contusion', 'blunt trauma', 'crush injury', 'penetrating injury'],
            'poisoning'               => ['poisoning', 'overdose', 'toxic ingestion', 'chemical poison', 'organophosphate', 'kerosene ingestion', 'alcohol poisoning', 'alcohol indoxication', 'alcohol intoxication', 'medication intolerance'],
            'burns'                   => ['burn', 'scald', 'thermal injury', 'chemical burn'],
            'snake_bites'             => ['snake bite', 'snakebite', 'envenomation', 'viper bite'],
            'dog_bites'               => ['dog bite', 'animal bite', 'dog attack'],
            'other_bites'             => ['bite', 'insect bite', 'bee sting', 'scorpion sting', 'human bite'],
            'sexual_assault'          => ['sexual assault', 'rape', 'defilement', 'gender based violence', 'gbv'],
            'violence_injuries'       => ['assault', 'violence', 'stab', 'gunshot', 'domestic violence', 'fight'],

            // Explicitly map common "others" to avoid losing them
            'other_diseases'          => ['gastritis', 'abdominal upset', 'pud', 'haemoroids', 'hormonal imbalance', 'dysmenorrhea', 'menstrual cramping', 'allergy', 'alergic reaction', 'allergic reaction'],
        ];

        foreach ($map as $key => $keywords) {
            foreach ($keywords as $kw) {
                if (str_contains($t, $kw)) {
                    return $key;
                }
            }
        }

        return '';
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Subcategory → disease key (Tier-2 fallback)
    // ─────────────────────────────────────────────────────────────────────────
    private static function matchSubcategory(string $sub, string $cat): ?string
    {
        $subMap = [
            'parasitic'               => 'suspected_malaria',
            'viral'                   => 'fevers',
            'bacterial'               => 'other_diseases',
            'trauma'                  => 'other_injuries',
            'poisoning'               => 'poisoning',
            'burns'                   => 'burns',
            'diabetes & metabolic'    => 'diabetes',
            'cardiovascular chronic'  => 'cardiovascular',
            'respiratory chronic'     => 'asthma',
            'mood disorders'          => 'mental_disorders',
            'anxiety disorders'       => 'mental_disorders',
            'psychotic disorders'     => 'mental_disorders',
            'substance use disorders' => 'mental_disorders',
            'obstetrics'              => 'puerperium',
            'neonatal'                => 'malnutrition',
            'solid tumors'            => 'neoplasms',
            'hematologic malignancies'=> 'neoplasms',
            'fractures'               => 'muscular_skeletal',
            'soft tissue injury'      => 'other_injuries',
            'head injury'             => 'other_injuries',
        ];

        return $subMap[$sub] ?? null;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Broad category → disease group fallback (Tier-3 fallback)
    // ─────────────────────────────────────────────────────────────────────────
    private static function matchCategory(string $cat): ?string
    {
        $catMap = [
            'infectious'              => 'fevers',
            'mental health'           => 'mental_disorders',
            'cancer / oncology'       => 'neoplasms',
            'injury'                  => 'other_injuries',
            'emergency'               => 'other_injuries',
            'maternal & child health' => 'puerperium',
            'chronic conditions'      => 'cardiovascular',
        ];

        return $catMap[$cat] ?? null;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Static helpers
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * All 73 disease keys in order + summary keys
     */
    public static function allKeys(): array
    {
        return [
            'diarrhoea', 'tuberculosis', 'dysentery', 'cholera',
            'meningococcal_meningitis', 'other_meningitis', 'tetanus', 'poliomyelitis',
            'chicken_pox', 'measles', 'hepatitis', 'mumps',
            'fevers', 'suspected_malaria', 'confirmed_malaria', 'malaria_in_pregnancy',
            'typhoid_fever', 'sti', 'uti', 'bilharzia',
            'intestinal_worms', 'malnutrition', 'anaemia',
            'eye_infections', 'other_eye', 'ear_infections',
            'upper_rti', 'asthma', 'pneumonia', 'other_respiratory',
            'abortion', 'puerperium', 'hypertension', 'mental_disorders',
            'dental_disorders', 'jiggers', 'skin_diseases', 'arthritis_joints',
            'poisoning', 'road_traffic_injuries', 'other_injuries',
            'sexual_assault', 'violence_injuries', 'burns',
            'snake_bites', 'dog_bites', 'other_bites',
            'diabetes', 'epilepsy', 'newly_diagnosed_hiv', 'brucellosis',
            'cardiovascular', 'cns_conditions', 'overweight',
            'muscular_skeletal', 'fistula', 'neoplasms', 'physical_disability',
            'trypanosomiasis', 'kalazar', 'dracunculosis',
            'yellow_fever', 'viral_haemorrhagic', 'plague',
            'deaths_road_traffic',
            // Summary
            'other_diseases',
        ];
    }

    /**
     * Human-readable labels matching the 73 MOH rows
     */
    public static function labels(): array
    {
        return [
            'diarrhoea'               => 'Diarrhoea',
            'tuberculosis'            => 'Tuberculosis',
            'dysentery'               => 'Dysentery (Bloody diarrhoea)',
            'cholera'                 => 'Cholera',
            'meningococcal_meningitis'=> 'Meningococcal Meningitis',
            'other_meningitis'        => 'Other Meningitis',
            'tetanus'                 => 'Tetanus',
            'poliomyelitis'           => 'Poliomyelitis (AFP)',
            'chicken_pox'             => 'Chicken Pox',
            'measles'                 => 'Measles',
            'hepatitis'               => 'Hepatitis',
            'mumps'                   => 'Mumps',
            'fevers'                  => 'Fevers',
            'suspected_malaria'       => 'Suspected Malaria',
            'confirmed_malaria'       => 'Confirmed Malaria',
            'malaria_in_pregnancy'    => 'Malaria in Pregnancy',
            'typhoid_fever'           => 'Typhoid fever',
            'sti'                     => 'Sexually Transmitted Infections',
            'uti'                     => 'Urinary Tract Infection',
            'bilharzia'               => 'Bilharzia',
            'intestinal_worms'        => 'Intestinal worms',
            'malnutrition'            => 'Malnutrition',
            'anaemia'                 => 'Anaemia',
            'eye_infections'          => 'Eye Infections',
            'other_eye'               => 'Other Eye Conditions',
            'ear_infections'          => 'Ear Infections/Conditions',
            'upper_rti'               => 'Upper Respiratory Tract Infections',
            'asthma'                  => 'Asthma',
            'pneumonia'               => 'Pneumonia',
            'other_respiratory'       => 'Other Diseases of Respiratory System',
            'abortion'                => 'Abortion',
            'puerperium'              => 'Diseases of Puerperium & Childbirth',
            'hypertension'            => 'Hypertension',
            'mental_disorders'        => 'Mental Disorders',
            'dental_disorders'        => 'Dental Disorders',
            'jiggers'                 => 'Jiggers Infestation',
            'skin_diseases'           => 'Diseases of the skin',
            'arthritis_joints'        => 'Arthritis, Joint pains',
            'poisoning'               => 'Poisoning',
            'road_traffic_injuries'   => 'Road Traffic Injuries',
            'other_injuries'          => 'Other Injuries',
            'sexual_assault'          => 'Sexual Assault',
            'violence_injuries'       => 'Violence Related Injuries',
            'burns'                   => 'Burns',
            'snake_bites'             => 'Snake Bites',
            'dog_bites'               => 'Dog Bites',
            'other_bites'             => 'Other Bites',
            'diabetes'                => 'Diabetes',
            'epilepsy'                => 'Epilepsy',
            'newly_diagnosed_hiv'     => 'Newly Diagnosed HIV',
            'brucellosis'             => 'Brucellosis',
            'cardiovascular'          => 'Cardiovascular Conditions',
            'cns_conditions'          => 'Central Nervous System Conditions',
            'overweight'              => 'Overweight (BMI >25)',
            'muscular_skeletal'       => 'Muscular Skeletal Conditions',
            'fistula'                 => 'Fistula',
            'neoplasms'               => 'Neoplasms',
            'physical_disability'     => 'Physical Disability',
            'trypanosomiasis'         => 'Trypanosomiasis',
            'kalazar'                 => 'Kalazar (Leishmaniasis)',
            'dracunculosis'           => 'Dracunculosis',
            'yellow_fever'            => 'Yellow Fever',
            'viral_haemorrhagic'      => 'Viral Haemorrhagic Fever',
            'plague'                  => 'Plague',
            'deaths_road_traffic'     => 'Deaths due to Road Traffic Injuries',
            'other_diseases'          => 'All Other Diseases',
        ];
    }
}
