class AnalysisResult {
  final bool isRealVoice;
  final String transcript;
  final List<String> detectedKeywords;
  final double confidence;
  final String audioFilePath;
  final DateTime timestamp;

  const AnalysisResult({
    required this.isRealVoice,
    required this.transcript,
    required this.detectedKeywords,
    required this.confidence,
    required this.audioFilePath,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'isRealVoice': isRealVoice,
    'transcript': transcript,
    'detectedKeywords': detectedKeywords,
    'confidence': confidence,
    'audioFilePath': audioFilePath,
    'timestamp': timestamp.toIso8601String(),
  };

  factory AnalysisResult.fromJson(Map<String, dynamic> json) => AnalysisResult(
    isRealVoice: json['isRealVoice'] as bool,
    transcript: json['transcript'] as String,
    detectedKeywords: List<String>.from(json['detectedKeywords']),
    confidence: (json['confidence'] as num).toDouble(),
    audioFilePath: json['audioFilePath'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
  );
}