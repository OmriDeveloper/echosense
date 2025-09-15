Voice Check & Keyword Detection (PoC)
A simple Proof of Concept (PoC) web application that analyzes audio files or recorded voice.
Features
- Voice Check → returns “Real” or “Not Real”.
- Speech-to-Text (STT) using Whisper (open-source).
- Keyword Detection → checks transcript against an editable list of keywords.
Tech Stack
- Backend: Python + FastAPI
- STT: Whisper (faster-whisper)
- Frontend: Simple HTML + JS
Usage
1. Upload or record an audio file.
2. Get results: voice authenticity, full transcription, and detected keywords.
Installation & Run
```bash
pip install -r requirements.txt
uvicorn app:app --reload --port 8000
```

Then open `frontend/index.html` in your browser.
Notes
- This is a simple PoC demo.
- Keyword list is editable in `keywords.json`.
