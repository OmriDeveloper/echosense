import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:echosense/models/analysis_result.dart';
import 'package:echosense/services/voice_analysis_service.dart';
import 'package:echosense/screens/results_screen.dart';
import 'package:echosense/screens/keywords_screen.dart';
import 'package:echosense/widgets/upload_section.dart';
import 'package:echosense/widgets/recording_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  bool _isAnalyzing = false;
  String? _recordingPath;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.microphone,
      Permission.storage,
    ].request();
  }

  Future<void> _pickAudioFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        await _analyzeAudio(result.files.single.path!);
      }
    } catch (e) {
      _showError('Error picking file: $e');
    }
  }

  Future<void> _startRecording() async {
    try {
      final hasPermission = await Permission.microphone.isGranted;
      if (!hasPermission) {
        final permission = await Permission.microphone.request();
        if (!permission.isGranted) {
          _showError('Microphone permission is required');
          return;
        }
      }

      if (await _audioRecorder.hasPermission()) {
        final path = '/tmp/recording_${DateTime.now().millisecondsSinceEpoch}.wav';
        await _audioRecorder.start(const RecordConfig(), path: path);
        
        setState(() {
          _isRecording = true;
          _recordingPath = path;
        });
      }
    } catch (e) {
      _showError('Error starting recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
      });

      if (_recordingPath != null) {
        await _analyzeAudio(_recordingPath!);
      }
    } catch (e) {
      _showError('Error stopping recording: $e');
    }
  }

  Future<void> _analyzeAudio(String audioPath) async {
    setState(() {
      _isAnalyzing = true;
    });

    try {
      final result = await VoiceAnalysisService.analyzeAudioFile(audioPath);
      
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultsScreen(result: result),
          ),
        );
      }
    } catch (e) {
      _showError('Error analyzing audio: $e');
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EchoSense'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const KeywordsScreen()),
            ),
            icon: const Icon(Icons.settings),
            tooltip: 'Manage Keywords',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Voice Analysis & Keyword Detection',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Upload an audio file or record your voice to analyze authenticity and detect keywords.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 32),
            
            UploadSection(
              onUpload: _pickAudioFile,
              isEnabled: !_isAnalyzing && !_isRecording,
            ),
            
            const SizedBox(height: 24),
            
            const Divider(),
            
            const SizedBox(height: 24),
            
            RecordingSection(
              isRecording: _isRecording,
              onStartRecording: _startRecording,
              onStopRecording: _stopRecording,
              isEnabled: !_isAnalyzing,
            ),
            
            if (_isAnalyzing) ...[
              const SizedBox(height: 32),
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Analyzing audio...'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }
}