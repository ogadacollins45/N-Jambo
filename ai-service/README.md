# HMS AI Disease Classifier

A lightweight FastAPI microservice that uses the **`all-MiniLM-L6-v2`** Sentence-Transformers model to semantically classify free-text clinical diagnoses into the 73 official MOH disease categories.

---

## Setup

### Prerequisites
- Python 3.9+
- pip

### 1. Create a virtual environment

```bash
cd ai-service
python -m venv venv

# Windows
venv\Scripts\activate

# macOS/Linux
source venv/bin/activate
```

### 2. Install dependencies

```bash
pip install -r requirements.txt
```

> ⚠️ First install downloads the ML model (~90 MB). Subsequent starts load from local cache.

### 3. Run the service

```bash
uvicorn app:app --reload --host 127.0.0.1 --port 8001
```

The service starts at **http://localhost:8001**

---

## API Endpoints

### `GET /`
Health check.

```json
{ "status": "ok", "service": "HMS Disease Classifier", "version": "1.0.0" }
```

### `POST /classify`
Classify a diagnosis string.

**Request:**
```json
{ "text": "malaria positive rdt" }
```

**Response:**
```json
{
  "predicted_category": "confirmed_malaria",
  "confidence": 0.8234,
  "text": "malaria positive rdt"
}
```

---

## Configuration (in Laravel `.env`)

| Variable | Default | Description |
|---|---|---|
| `AI_DISEASE_CLASSIFIER_URL` | `http://localhost:8001/classify` | URL of this service |
| `AI_DISEASE_CLASSIFIER_CONFIDENCE_THRESHOLD` | `0.50` | Min confidence to accept AI result |
| `AI_DISEASE_CLASSIFIER_TIMEOUT` | `5` | HTTP timeout in seconds |

---

## How it works

1. On startup, the service pre-computes **mean embeddings** for each of the 73 MOH disease categories using rich phrase lists per category.
2. For each incoming diagnosis, it encodes the text and computes **cosine similarity** against all category embeddings.
3. The highest-scoring category is returned with its confidence score.

The Laravel `DiseaseMapper` service accepts this result if confidence ≥ threshold, otherwise falls back to its existing keyword/subcategory/category matching logic — **gracefully and transparently**.

---

## Production deployment

This service can be deployed separately on **Railway**, **Render**, or **fly.io**. Just update `AI_DISEASE_CLASSIFIER_URL` in your Laravel `.env` to the production URL.
