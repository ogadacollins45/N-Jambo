"""
AI Disease Classification Microservice
FastAPI + Sentence-Transformers (all-MiniLM-L6-v2)
Maps raw diagnosis text to one of 73 MOH disease categories via semantic similarity.
"""

from contextlib import asynccontextmanager
from typing import Optional
import logging
import numpy as np
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from sentence_transformers import SentenceTransformer, util

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# ─────────────────────────────────────────────────────────────────────────────
# Disease category knowledge base
# Each category has a list of representative phrases to build a rich embedding
# ─────────────────────────────────────────────────────────────────────────────
DISEASE_KNOWLEDGE: dict[str, list[str]] = {
    "diarrhoea": [
        "diarrhoea", "diarrhea", "gastroenteritis", "loose stool",
        "loose motions", "dehydration", "amoebiasis", "watery stool",
        "stomach upset with diarrhoea",
    ],
    "dysentery": [
        "dysentery", "bloody diarrhoea", "bloody diarrhea",
        "haemorrhagic diarrhoea", "blood in stool",
    ],
    "cholera": ["cholera", "rice water stool", "vibrio cholerae"],
    "intestinal_worms": [
        "intestinal worm", "helminth", "ascaris", "hookworm", "roundworm",
        "tapeworm", "pinworm", "threadworm", "worm infestation",
    ],
    "bilharzia": ["bilharzia", "schistosoma", "schistosomiasis"],
    "typhoid_fever": ["typhoid", "typhoid fever", "salmonella typhi", "enteric fever"],
    "upper_rti": [
        "upper respiratory tract infection", "common cold", "rhinitis",
        "pharyngitis", "tonsillitis", "tonsilitis", "sinusitis", "coryza",
        "sore throat", "cough", "epistaxis", "nose bleeding", "acute tonsils",
        "allergic rhinitis", "nasal congestion",
    ],
    "pneumonia": [
        "pneumonia", "pneumonitis", "lobar pneumonia",
        "community acquired pneumonia", "bronchopneumonia",
        "chest infection with fever", "lung infection",
    ],
    "asthma": ["asthma", "bronchial asthma", "reactive airway disease", "wheezing"],
    "other_respiratory": [
        "chronic obstructive pulmonary disease", "copd", "bronchitis",
        "pleural effusion", "pleurisy", "emphysema", "respiratory failure",
    ],
    "confirmed_malaria": [
        "confirmed malaria", "malaria positive", "plasmodium falciparum",
        "plasmodium vivax", "malaria test positive", "blood slide positive",
        "rdt positive", "malaria malariae",
    ],
    "malaria_in_pregnancy": [
        "malaria in pregnancy", "malaria in pregnant woman",
        "malaria pregnancy", "mip",
    ],
    "suspected_malaria": [
        "suspected malaria", "febrile illness", "malaria suspected",
        "clinical malaria", "fever possibly malaria",
    ],
    "fevers": [
        "fever", "pyrexia", "hyperthermia", "bacteremia", "bacterial infection",
        "acute fever", "high temperature", "feverish", "febrile",
    ],
    "tuberculosis": [
        "tuberculosis", "pulmonary tuberculosis", "tb disease",
        "mycobacterium tuberculosis", "ptb", "eptb", "pulmonary tb",
        "low grade fever with cough and weight loss",
    ],
    "meningococcal_meningitis": [
        "meningococcal meningitis", "neisseria meningitidis",
        "meningococcal disease",
    ],
    "other_meningitis": [
        "meningitis", "bacterial meningitis", "viral meningitis",
        "cryptococcal meningitis", "brain infection", "stiff neck fever",
    ],
    "tetanus": ["tetanus", "lockjaw", "clostridium tetani", "trismus"],
    "poliomyelitis": [
        "polio", "poliomyelitis", "acute flaccid paralysis", "afp",
    ],
    "chicken_pox": ["chicken pox", "chickenpox", "varicella", "varicella zoster"],
    "measles": ["measles", "rubeola", "morbilli", "measles rash"],
    "hepatitis": [
        "hepatitis", "jaundice", "liver infection", "hbsag positive",
        "liver inflammation", "hepatitis b", "hepatitis c",
    ],
    "mumps": ["mumps", "parotitis", "parotid swelling"],
    "brucellosis": ["brucellosis", "brucella", "undulant fever"],
    "trypanosomiasis": ["trypanosomiasis", "sleeping sickness", "trypanosoma"],
    "kalazar": ["kala-azar", "kalazar", "leishmaniasis", "leishmania"],
    "dracunculosis": ["dracunculosis", "guinea worm", "dracunculus"],
    "yellow_fever": ["yellow fever", "yellow fever virus"],
    "viral_haemorrhagic": [
        "viral haemorrhagic fever", "vhf", "ebola", "marburg",
        "rift valley fever", "haemorrhagic fever",
    ],
    "plague": ["plague", "yersinia pestis", "bubonic plague"],
    "sti": [
        "sexually transmitted infection", "gonorrhoea", "gonorrhea",
        "syphilis", "chlamydia", "genital ulcer", "herpes genitalis",
        "vaginitis", "urethral discharge", "pelvic inflammatory disease",
        "pid", "balanitis", "genital discharge",
    ],
    "newly_diagnosed_hiv": [
        "newly diagnosed hiv", "new hiv", "hiv positive", "hiv diagnosis",
        "hiv confirmed", "hiv seropositive", "human immunodeficiency virus",
    ],
    "uti": [
        "urinary tract infection", "uti", "cystitis", "pyelonephritis",
        "urinary infection", "dysuria", "burning urination",
        "lower urinary tract obstruction",
    ],
    "eye_infections": [
        "conjunctivitis", "eye infection", "ophthalmia", "trachoma",
        "keratitis", "pink eye", "eye discharge", "red eye",
    ],
    "other_eye": [
        "cataract", "glaucoma", "refractive error", "visual impairment",
        "blindness", "retinal disease", "eye problem",
    ],
    "ear_infections": [
        "otitis media", "ear infection", "ear discharge", "deafness",
        "hearing loss", "ear pain", "otalgia", "tinnitus",
    ],
    "malnutrition": [
        "malnutrition", "kwashiorkor", "marasmus", "undernutrition",
        "wasting", "stunting", "failure to thrive", "nutritional deficiency",
        "severe acute malnutrition",
    ],
    "overweight": ["overweight", "obesity", "obese", "high bmi", "body mass index over 25"],
    "anaemia": [
        "anaemia", "anemia", "low haemoglobin", "iron deficiency anaemia",
        "sickle cell anaemia", "pale conjunctiva",
    ],
    "abortion": [
        "abortion", "miscarriage", "incomplete abortion",
        "spontaneous abortion", "pregnancy loss",
    ],
    "puerperium": [
        "puerperium", "childbirth complication", "postpartum", "puerperal",
        "obstetric complication", "postpartum haemorrhage", "eclampsia",
        "pre-eclampsia", "puerperal sepsis", "labour complication",
    ],
    "hypertension": [
        "hypertension", "high blood pressure", "elevated blood pressure",
        "hypertensive disease", "htn",
    ],
    "diabetes": [
        "diabetes mellitus", "diabetic", "dm type 2", "dm type 1",
        "type 2 diabetes", "type 1 diabetes", "diabetic ketoacidosis",
        "dka", "hypoglycaemia", "hyperglycaemia", "high blood sugar",
    ],
    "epilepsy": [
        "epilepsy", "seizure disorder", "convulsion", "fits", "epileptic fit",
        "status epilepticus", "generalized seizure",
    ],
    "cardiovascular": [
        "heart failure", "cardiac disease", "angina pectoris",
        "myocardial infarction", "coronary artery disease", "arrhythmia",
        "atrial fibrillation", "heart disease", "cardiovascular disease",
    ],
    "cns_conditions": [
        "stroke", "cerebrovascular accident", "hemiplegia", "paraplegia",
        "cerebral palsy", "parkinson disease", "dementia", "neurological condition",
        "migraine", "severe headache",
    ],
    "mental_disorders": [
        "mental disorder", "psychiatric illness", "depression", "schizophrenia",
        "bipolar disorder", "anxiety disorder", "psychosis", "ptsd",
        "substance abuse", "alcohol use disorder",
    ],
    "dental_disorders": [
        "dental caries", "tooth decay", "gingivitis", "periodontitis",
        "toothache", "oral health problem", "jaw pain",
    ],
    "arthritis_joints": [
        "arthritis", "joint pain", "gout", "osteoarthritis",
        "rheumatoid arthritis", "musculoskeletal pain", "backache",
        "lower back pain", "lumbago", "sciatica", "myalgia",
    ],
    "muscular_skeletal": [
        "fracture", "broken bone", "sprain", "muscle strain",
        "dislocation", "skeletal injury", "bone fracture",
    ],
    "skin_diseases": [
        "dermatitis", "eczema", "psoriasis", "fungal skin infection",
        "tinea", "scabies", "ringworm", "skin rash", "urticaria",
        "cellulitis", "pruritus", "skin disease",
    ],
    "jiggers": ["jiggers", "tungiasis", "jigger infestation"],
    "neoplasms": [
        "cancer", "carcinoma", "tumour", "tumor", "neoplasm",
        "lymphoma", "leukaemia", "leukemia", "malignancy", "sarcoma",
        "breast cancer", "cervical cancer", "prostate cancer",
    ],
    "fistula": [
        "fistula", "obstetric fistula", "vesicovaginal fistula",
        "rectovaginal fistula",
    ],
    "physical_disability": [
        "physical disability", "amputee", "cerebral palsy",
        "physically challenged", "limb loss",
    ],
    "road_traffic_injuries": [
        "road traffic accident", "road traffic injury", "motor vehicle accident",
        "motorcycle accident", "boda boda accident", "pedestrian knocked",
        "rta",
    ],
    "deaths_road_traffic": [
        "death from road traffic accident", "fatal road accident",
        "died in road accident",
    ],
    "other_injuries": [
        "fall injury", "blunt trauma", "laceration", "contusion",
        "crush injury", "penetrating injury", "accidental injury",
    ],
    "poisoning": [
        "poisoning", "drug overdose", "toxic ingestion",
        "organophosphate poisoning", "kerosene ingestion",
        "alcohol intoxication", "chemical poisoning",
    ],
    "burns": [
        "burn injury", "scald", "thermal burn", "chemical burn",
        "fire injury", "hot liquid burn",
    ],
    "snake_bites": [
        "snake bite", "snakebite", "snake envenomation", "viper bite",
    ],
    "dog_bites": ["dog bite", "animal bite from dog", "dog attack"],
    "other_bites": [
        "insect bite", "bee sting", "scorpion sting", "human bite",
        "animal bite",
    ],
    "sexual_assault": [
        "sexual assault", "rape", "defilement", "gender based violence",
        "gbv", "sexual violence",
    ],
    "violence_injuries": [
        "assault", "physical violence", "stab wound", "gunshot wound",
        "domestic violence", "fight injury",
    ],
    "other_diseases": [
        "gastritis", "peptic ulcer disease", "abdominal pain",
        "hormonal imbalance", "dysmenorrhea", "menstrual cramps",
        "allergy", "allergic reaction", "general illness",
    ],
}


# ─────────────────────────────────────────────────────────────────────────────
# MOH 706 Lab Test Knowledge Base
# Each MOH 706 row code is mapped to representative lab test name phrases.
# ─────────────────────────────────────────────────────────────────────────────
LAB_TEST_KNOWLEDGE: dict[str, list[str]] = {
    # SECTION 1 — URINE ANALYSIS
    "1.2":  ["urine glucose", "glycosuria", "urine sugar", "glucose in urine", "urine glucose test"],
    "1.3":  ["urine ketones", "ketonuria", "ketone bodies urine", "acetone in urine"],
    "1.4":  ["urine protein", "proteinuria", "albuminuria", "urine albumin", "microalbuminuria"],
    "1.6":  ["pus cells in urine", "pyuria", "urine microscopy pus cells", "leukocytes in urine"],
    "1.7":  ["schistosoma haematobium", "s haematobium eggs", "bilharzia urine", "urine schistosoma"],
    "1.8":  ["trichomonas vaginalis urine", "t vaginalis urine", "trichomonas in urine"],
    "1.9":  ["yeast cells urine", "candida in urine", "fungal cells urine"],
    "1.10": ["bacteria in urine", "bacteriuria", "urine bacteria microscopy"],
    # SECTION 3 — PARASITOLOGY
    # Note: 3.1 & 3.2 are same test (Malaria BS) split by age in the backend.
    # Similarly 3.3 & 3.4 for Malaria RDT. Age-neutral phrases used here.
    "3.1":  ["malaria blood smear", "malaria film", "malaria thick film", "malaria bs", "malaria test"],
    "3.2":  ["malaria blood smear 5 years", "malaria film adult", "malaria bs above five"],
    "3.3":  ["malaria rapid diagnostic test", "malaria rdt", "malaria antigen test", "hrp2 malaria test"],
    "3.4":  ["malaria rdt 5 years", "malaria rapid adult"],
    "3.5":  ["taenia stool", "stool taenia", "tapeworm stool"],
    "3.6":  ["hymenolepis nana", "dwarf tapeworm stool"],
    "3.7":  ["hookworm stool", "ancylostoma stool", "necator americanus"],
    "3.8":  ["roundworm stool", "ascaris lumbricoides", "ascaris stool"],
    "3.9":  ["schistosoma mansoni stool", "s mansoni ova", "stool schistosoma"],
    "3.10": ["trichuris trichiura", "whipworm stool"],
    "3.11": ["amoeba stool", "entamoeba histolytica", "stool amoeba"],
    # SECTION 5 — BACTERIOLOGY (Cultures & Isolates)
    "5.1":  ["urine culture", "urine c/s", "urine c&s"],
    "5.2":  ["pus swab culture", "pus c&s", "wound swab culture"],
    "5.3":  ["high vaginal swab culture", "hvs culture", "vaginal culture"],
    "5.4":  ["throat swab culture"],
    "5.5":  ["rectal swab culture"],
    "5.6":  ["blood culture"],
    "5.7":  ["water culture bacteriology"],
    "5.8":  ["food culture bacteriology"],
    "5.9":  ["urethral swab culture"],
    "5.10": ["stool culture", "stool c&s"],
    "5.11": ["salmonella typhi", "s typhi isolate"],
    "5.12": ["shigella dysenteriae"],
    "5.13": ["e coli o157", "escherichia coli o157"],
    "5.14": ["vibrio cholerae o1"],
    "5.15": ["vibrio cholerae o139"],
    "5.16": ["csf culture", "cerebrospinal fluid culture"],
    "5.17": ["neisseria meningitidis a"],
    "5.18": ["neisseria meningitidis b"],
    "5.19": ["neisseria meningitidis c"],
    "5.20": ["neisseria meningitidis w135"],
    "5.21": ["neisseria meningitidis x"],
    "5.22": ["neisseria meningitidis y"],
    "5.23": ["n meningitidis indeterminate"],
    "5.24": ["streptococcus pneumoniae isolate"],
    "5.25": ["haemophilus influenzae b", "hib isolate"],
    "5.26": ["cryptococcal meningitis", "cryptococcus isolate"],
    "5.27": ["bacillus anthracis", "anthrax isolate"],
    "5.28": ["yersinia pestis", "plague isolate"],
    "5.29": ["sputum smears afb", "tb smear", "zn stain"],
    "5.30": ["sputum tb culture", "mycobacterium culture"],
    "5.31": ["other tb samples smears"],
    "5.32": ["genexpert rif resistance", "rr tb xpert"],
    "5.33": ["genexpert mdr tb"],
    # SECTION 6 — HISTOLOGY & CYTOLOGY
    "6.1":  ["pap smear", "papanicolaou test", "cervical smear"],
    "6.2":  ["fna breast", "fine needle aspiration breast"],
    "6.3":  ["fna lymph node"],
    "6.4":  ["fna thyroid"],
    "6.5":  ["fna prostate"],
    "6.6":  ["fna others", "fna general"],
    "6.7":  ["peritoneal fluid cytology", "ascitic fluid cytology"],
    "6.8":  ["pleural fluid cytology"],
    "6.9":  ["csf cytology", "cerebrospinal fluid cytology"],
    "6.10": ["urine cytology"],
    "6.11": ["synovial fluid cytology"],
    "6.12": ["other fluids cytology"],
    "6.13": ["prostate biopsy histology"],
    "6.14": ["gastro-intestinal tract biopsy", "git biopsy", "endoscopy biopsy"],
    "6.15": ["cervical biopsy"],
    "6.16": ["endometrial biopsy"],
    "6.17": ["products of conception histology", "poc histology", "evacuation histology"],
    "6.18": ["skin biopsy"],
    "6.19": ["breast biopsy", "breast lumpectomy histology"],
    "6.20": ["lymph node biopsy"],
    "6.21": ["thyroid biopsy"],
    "6.22": ["bone biopsy", "bone marrow trephine histology"],
    "6.23": ["ovarian mass histology", "ovarian biopsy"],
    "6.24": ["uterine mass histology", "fibroid histology", "hysterectomy histology"],
    "6.25": ["renal biopsy", "kidney biopsy"],
    "6.26": ["liver biopsy"],
    "6.27": ["others histology", "general histology specimen"],
    # SECTION 9 — DRUG SUSCEPTIBILITY ORGANISMS
    "9.1":  ["e coli o157 h7", "escherichia coli o157:h7"],
    "9.2":  ["proteus isolate", "proteus mirabilis", "proteus spp"],
    "9.3":  ["salmonella isolate", "salmonella spp", "salmonella typhi", "salmonella paratyphi"],
    "9.4":  ["shigella isolate", "shigella spp", "shigella sonnei", "shigella flexneri"],
    "9.5":  ["klebsiella pneumoniae", "klebsiella isolate", "klebsiella spp"],
    "9.6":  ["pseudomonas aeruginosa", "pseudomonas isolate", "pseudomonas spp"],
    "9.7":  ["staphylococcus aureus", "staph aureus isolate", "s aureus"],
    "9.8":  ["vibrio cholerae isolate", "vibrio cholerae spp"],
    "9.9":  ["neisseria meningitidis isolate", "n meningitidis"],
    "9.10": ["neisseria gonorrhoeae isolate", "n gonorrhoeae", "gonococcus"],
    "9.11": ["streptococcus pneumoniae isolate", "s pneumoniae", "pneumococcus"],
    "9.12": ["haemophilus influenzae isolate", "h influenzae"],
    "9.13": ["haemophilus parainfluenzae", "h parainfluenzae"],
    "9.14": ["bacterial vaginosis", "gardnerella vaginalis", "bv isolate"],
    # SECTION 2 — BLOOD CHEMISTRY

    "2.1":  ["blood sugar", "blood glucose", "fasting blood glucose", "random blood glucose", "fbs", "rbs"],
    "2.2":  ["oral glucose tolerance test", "ogtt", "glucose tolerance test"],
    "2.4":  ["creatinine", "serum creatinine", "kidney function creatinine"],
    "2.5":  ["urea", "blood urea nitrogen", "serum urea", "bun"],
    "2.6":  ["sodium", "serum sodium", "sodium electrolyte"],
    "2.7":  ["potassium", "serum potassium", "potassium electrolyte"],
    "2.8":  ["chlorides", "serum chloride", "chloride"],
    "2.9":  ["direct bilirubin", "conjugated bilirubin"],
    "2.10": ["total bilirubin", "bilirubin"],
    "2.11": ["asat", "sgot", "aspartate aminotransferase", "ast liver"],
    "2.12": ["alat", "sgpt", "alanine aminotransferase", "alt liver"],
    "2.13": ["serum protein", "total protein"],
    "2.14": ["albumin", "serum albumin"],
    "2.15": ["alkaline phosphatase", "alp"],
    "2.17": ["total cholesterol", "cholesterol"],
    "2.18": ["triglycerides", "triglyceride"],
    "2.19": ["ldl cholesterol", "ldl"],
    "2.20": ["t3", "triiodothyronine", "thyroid t3"],
    "2.21": ["t4", "thyroxine", "thyroid t4"],
    "2.22": ["tsh", "thyroid stimulating hormone", "thyroid function test"],
    "2.23": ["psa", "prostate specific antigen"],
    "2.24": ["ca 15-3", "cancer antigen 15-3"],
    "2.25": ["ca 19-9", "cancer antigen 19-9"],
    "2.26": ["ca 125", "cancer antigen 125", "ovarian cancer marker"],
    "2.27": ["cea", "carcinoembryonic antigen"],
    "2.28": ["afp", "alpha fetoprotein"],
    "2.29": ["csf protein", "cerebrospinal fluid protein"],
    "2.30": ["csf glucose", "cerebrospinal fluid glucose"],
    # SECTION 4 — HAEMATOLOGY
    "4.1":  ["full blood count", "fbc", "cbc", "complete blood count", "full blood picture"],
    "4.2":  ["haemoglobin estimation", "hemoglobin estimation", "hb estimation", "hb level"],
    "4.3":  ["hba1c", "glycated haemoglobin", "hemoglobin a1c", "glycosylated hemoglobin"],
    "4.4":  ["cd4 count", "cd4", "cd4+ count", "t cell count"],
    "4.5":  ["sickling test", "sickle cell test", "sickle cell screen"],
    "4.6":  ["peripheral blood film", "blood film", "pbf", "peripheral smear", "malaria film"],
    "4.7":  ["bone marrow aspirate", "bma", "bone marrow aspiration"],
    "4.8":  ["coagulation profile", "coagulation screen", "prothrombin time", "aptt", "inr"],
    "4.9":  ["reticulocyte count", "retic count"],
    "4.10": ["esr", "erythrocyte sedimentation rate"],
    "4.11": ["blood grouping", "blood group test", "abo grouping"],
    "4.12": ["blood units grouped", "group and crossmatch"],
    "4.13": ["blood units received from transfusion"],
    "4.14": ["blood units collected at facility"],
    "4.15": ["blood units transfused", "blood transfusion given"],
    "4.16": ["transfusion reaction", "adverse transfusion reaction"],
    "4.17": ["blood grouping and crossmatch"],
    "4.18": ["blood units discarded"],
    "4.19": ["hiv blood screening", "hiv blood screen"],
    "4.20": ["hepatitis b blood screening", "hbsag blood"],
    "4.21": ["hepatitis c blood screening", "hcv blood"],
    "4.22": ["syphilis blood screening"],
    # SECTION 5 — BACTERIOLOGY
    "5.1":  ["urine culture", "urine mcs", "urine culture sensitivity"],
    "5.2":  ["pus swab culture", "wound culture", "pus culture"],
    "5.3":  ["high vaginal swab", "hvs culture", "hvs"],
    "5.4":  ["throat swab", "throat culture"],
    "5.5":  ["rectal swab"],
    "5.6":  ["blood culture", "blood mcs"],
    "5.7":  ["water culture"],
    "5.8":  ["food culture"],
    "5.9":  ["urethral swab"],
    "5.10": ["stool culture", "stool mcs", "faecal culture"],
    "5.11": ["salmonella typhi isolation", "typhoid culture"],
    "5.12": ["shigella dysenteriae"],
    "5.13": ["e. coli o157", "escherichia coli o157"],
    "5.14": ["vibrio cholerae o1"],
    "5.15": ["vibrio cholerae o139"],
    "5.16": ["csf culture", "meningitis csf culture", "cerebrospinal fluid culture"],
    "5.17": ["neisseria meningitidis serotype a"],
    "5.18": ["neisseria meningitidis serotype b"],
    "5.19": ["neisseria meningitidis serotype c"],
    "5.20": ["neisseria meningitidis w135"],
    "5.21": ["neisseria meningitidis x"],
    "5.22": ["neisseria meningitidis y"],
    "5.23": ["neisseria meningitidis indeterminate"],
    "5.24": ["streptococcus pneumoniae isolation"],
    "5.25": ["haemophilus influenzae type b"],
    "5.26": ["cryptococcal meningitis", "cryptococcus neoformans"],
    "5.27": ["bacillus anthracis", "anthrax"],
    "5.28": ["yersinia pestis", "plague"],
    "5.29": ["tb smear", "sputum afb", "acid fast bacilli smear", "ziehl neelsen smear"],
    "5.30": ["new presumptive tb case", "new tb case smear"],
    "5.31": ["tb follow up smear"],
    "5.32": ["rifampicin resistant tb", "xpert mtb rif"],
    "5.33": ["mdr tb", "multidrug resistant tuberculosis"],
    # SECTION 6 — HISTOLOGY AND CYTOLOGY
    "6.1":  ["pap smear", "papanicolaou smear", "cervical smear cytology"],
    "6.2":  ["touch preparation", "touch prep"],
    "6.3":  ["tissue imprint"],
    "6.4":  ["thyroid fine needle aspirate", "thyroid fna"],
    "6.5":  ["lymph node fna", "lymph node fine needle aspirate"],
    "6.6":  ["liver fna", "liver fine needle aspirate"],
    "6.7":  ["breast fine needle aspirate", "breast fna"],
    "6.8":  ["soft tissue fna", "soft tissue fine needle aspirate"],
    "6.9":  ["ascitic fluid cytology", "ascites cytology"],
    "6.10": ["csf cytology", "cerebrospinal fluid cytology"],
    "6.11": ["pleural fluid cytology", "pleural effusion cytology"],
    "6.12": ["urine cytology"],
    "6.13": ["prostate biopsy", "prostate histology"],
    "6.14": ["breast tissue histology", "breast biopsy histology"],
    "6.15": ["ovary histology", "ovarian biopsy"],
    "6.16": ["cervix histology", "cervical biopsy histology"],
    "6.17": ["endometrium histology", "uterus endometrium histology"],
    "6.18": ["skin biopsy histology"],
    "6.19": ["head and neck histology"],
    "6.20": ["oral histology", "oral biopsy histology"],
    "6.21": ["esophagus histology", "oesophageal biopsy"],
    "6.22": ["colorectal histology", "colon biopsy histology"],
    "6.23": ["liver biopsy histology", "hepatobiliary histology"],
    "6.24": ["soft tissue biopsy histology", "bone biopsy histology"],
    "6.25": ["lymph node histology biopsy"],
    "6.26": ["bone marrow aspirate cytology"],
    "6.27": ["trephine biopsy", "bone marrow trephine"],
    # SECTION 7 — SEROLOGY
    "7.1":  ["vdrl", "venereal disease research laboratory test", "syphilis vdrl screening"],
    "7.2":  ["tpha", "treponema pallidum haemagglutination assay"],
    "7.3":  ["asot", "antistreptolysin o titre", "aso test"],
    "7.4":  ["hiv test", "hiv antibody test", "hiv screening rapid test", "hiv serology test"],
    "7.5":  ["brucella test", "brucellosis serology", "brucella agglutination"],
    "7.6":  ["rheumatoid factor", "rf test"],
    "7.7":  ["helicobacter pylori antigen", "h pylori test", "h. pylori antibody"],
    "7.8":  ["hepatitis a serology", "hav antibody test", "anti-hav test"],
    "7.9":  ["hepatitis b serology", "hbsag test", "hepatitis b surface antigen"],
    "7.10": ["hepatitis c serology", "anti-hcv test", "hepatitis c antibody"],
    "7.11": ["pregnancy test hcg", "beta hcg test", "urine pregnancy test"],
    "7.12": ["crag test", "cryptococcal antigen test", "lateral flow crag"],
    # SECTION 8 — SPECIMEN REFERRALS
    "8.1":  ["cd4 referral specimen", "cd4 sent to reference laboratory"],
    "8.2":  ["viral load specimen referral", "hiv viral load referral"],
    "8.3":  ["early infant diagnosis specimen", "eid dbs referral"],
    "8.4":  ["discordant couple referral"],
    "8.5":  ["tb culture referral", "mycobacterium culture specimen referral"],
    "8.6":  ["virological specimen referral"],
    "8.7":  ["clinical chemistry specimen referral"],
    "8.8":  ["histology cytology specimen referral"],
    "8.9":  ["haematological specimen referral"],
    "8.10": ["parasitological specimen referral"],
    "8.11": ["blood transfusion screening specimen referral"],
}

# ─────────────────────────────────────────────────────────────────────────────
# App lifespan — load model and precompute embeddings once at startup
# ─────────────────────────────────────────────────────────────────────────────
model: Optional[SentenceTransformer] = None
category_embeddings: dict[str, np.ndarray] = {}
lab_test_embeddings: dict[str, np.ndarray] = {}


@asynccontextmanager
async def lifespan(app: FastAPI):
    global model, category_embeddings, lab_test_embeddings
    logger.info("Loading SentenceTransformer model (all-MiniLM-L6-v2)...")
    model = SentenceTransformer("all-MiniLM-L6-v2")

    logger.info("Pre-computing disease category embeddings...")
    for category, phrases in DISEASE_KNOWLEDGE.items():
        embeddings = model.encode(phrases, convert_to_numpy=True, show_progress_bar=False)
        # Use the mean embedding to represent the category
        category_embeddings[category] = embeddings.mean(axis=0)
    logger.info(f"✅  Loaded {len(category_embeddings)} disease categories.")

    logger.info("Pre-computing MOH 706 lab test embeddings...")
    for code, phrases in LAB_TEST_KNOWLEDGE.items():
        embeddings = model.encode(phrases, convert_to_numpy=True, show_progress_bar=False)
        lab_test_embeddings[code] = embeddings.mean(axis=0)
    logger.info(f"✅  Loaded {len(lab_test_embeddings)} MOH 706 lab test codes. Ready.")

    yield
    logger.info("Shutting down AI service.")


app = FastAPI(
    title="HMS Disease Classifier",
    description="Classify free-text diagnosis into MOH disease categories using semantic similarity.",
    version="1.0.0",
    lifespan=lifespan,
)


# ─────────────────────────────────────────────────────────────────────────────
# Request / Response schemas
# ─────────────────────────────────────────────────────────────────────────────
class ClassifyRequest(BaseModel):
    text: str


class ClassifyResponse(BaseModel):
    predicted_category: str
    confidence: float
    text: str


# ─────────────────────────────────────────────────────────────────────────────
# Endpoints
# ─────────────────────────────────────────────────────────────────────────────
@app.get("/", summary="Health check")
def health():
    return {"status": "ok", "service": "HMS Disease Classifier", "version": "1.0.0"}


@app.post("/classify", response_model=ClassifyResponse, summary="Classify diagnosis text")
def classify(request: ClassifyRequest):
    if not model:
        raise HTTPException(status_code=503, detail="Model not loaded yet. Try again shortly.")

    raw_text = request.text.strip()
    if not raw_text:
        raise HTTPException(status_code=422, detail="'text' field must not be empty.")

    # Encode the incoming diagnosis text
    query_embedding = model.encode(raw_text, convert_to_numpy=True, show_progress_bar=False)

    best_category = "other_diseases"
    best_score = -1.0

    for category, cat_embedding in category_embeddings.items():
        # Cosine similarity: dot product of normalized vectors
        score = float(util.cos_sim(query_embedding, cat_embedding).item())
        if score > best_score:
            best_score = score
            best_category = category

    logger.info(
        f"Classified '{raw_text[:60]}' → '{best_category}' (confidence={best_score:.3f})"
    )

    return ClassifyResponse(
        predicted_category=best_category,
        confidence=round(best_score, 4),
        text=raw_text,
    )


# ─────────────────────────────────────────────────────────────────────────────
# MOH 706 Lab Test Classification
# ─────────────────────────────────────────────────────────────────────────────
class LabTestClassifyRequest(BaseModel):
    text: str


class LabTestClassifyResponse(BaseModel):
    predicted_code: str
    confidence: float
    text: str


MIN_LAB_CONFIDENCE = 0.45  # below this threshold → return "unmapped"


@app.post(
    "/classify-lab-test",
    response_model=LabTestClassifyResponse,
    summary="Map a lab test name to its MOH 706 row code",
)
def classify_lab_test(request: LabTestClassifyRequest):
    if not model:
        raise HTTPException(status_code=503, detail="Model not loaded yet. Try again shortly.")

    raw_text = request.text.strip()
    if not raw_text:
        raise HTTPException(status_code=422, detail="'text' field must not be empty.")

    query_embedding = model.encode(raw_text, convert_to_numpy=True, show_progress_bar=False)

    best_code = "unmapped"
    best_score = -1.0

    for code, code_embedding in lab_test_embeddings.items():
        score = float(util.cos_sim(query_embedding, code_embedding).item())
        if score > best_score:
            best_score = score
            best_code = code

    if best_score < MIN_LAB_CONFIDENCE:
        best_code = "unmapped"

    logger.info(
        f"Lab test '{raw_text[:50]}' → '{best_code}' (confidence={best_score:.3f})"
    )

    return LabTestClassifyResponse(
        predicted_code=best_code,
        confidence=round(best_score, 4),
        text=raw_text,
    )
