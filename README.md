EchoSense — Voice Check & Keyword Detection (Proof of Concept)

EchoSense is a simple, browser-friendly Flutter application that lets you upload or record audio, perform a voice authenticity check, transcribe speech, and detect predefined keywords in the transcript.

Features:
- Upload an audio file or record voice directly in the browser
- Voice authenticity check (Real / Not Real)
- Speech-to-Text transcription
- Keyword detection against a customizable list managed in-app
- Simple results screen showing authenticity, transcription, and detected keywords
   
Backend / Integrations:
- No backend is connected by default.
  
Where to change things (quick pointers):
- UI screens: lib/screens/ (home_screen.dart, results_screen.dart, keywords_screen.dart)
- Audio/analysis UI components: lib/widgets/
- Business logic: lib/services/ (voice_analysis_service.dart, keyword_service.dart)
- Model: lib/models/analysis_result.dart
  
Notes:
- This is a Proof of Concept app.
- The voice-auth check is a simulated/stubbed implementation; for production, replace it with a real ML or backend service.
- Keywords can be edited from the "Keywords" screen in the app.
