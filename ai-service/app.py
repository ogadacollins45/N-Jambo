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
# App lifespan — load model and precompute embeddings once at startup
# ─────────────────────────────────────────────────────────────────────────────
model: Optional[SentenceTransformer] = None
category_embeddings: dict[str, np.ndarray] = {}


@asynccontextmanager
async def lifespan(app: FastAPI):
    global model, category_embeddings
    logger.info("Loading SentenceTransformer model (all-MiniLM-L6-v2)...")
    model = SentenceTransformer("all-MiniLM-L6-v2")

    logger.info("Pre-computing category embeddings...")
    for category, phrases in DISEASE_KNOWLEDGE.items():
        embeddings = model.encode(phrases, convert_to_numpy=True, show_progress_bar=False)
        # Use the mean embedding to represent the category
        category_embeddings[category] = embeddings.mean(axis=0)

    logger.info(f"✅  Loaded {len(category_embeddings)} disease categories. Ready.")
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
