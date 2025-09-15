import 'package:flutter/material.dart';

class RecordingSection extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final bool isEnabled;

  const RecordingSection({
    super.key,
    required this.isRecording,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isRecording ? Icons.mic : Icons.mic_none,
                  size: 28,
                  color: isRecording ? Colors.red : null,
                ),
                const SizedBox(width: 12),
                Text(
                  'Record Voice',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              isRecording 
                  ? 'Recording in progress... Tap stop when finished.'
                  : 'Record your voice directly using your device microphone.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: isEnabled ? (isRecording ? onStopRecording : onStartRecording) : null,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isRecording 
                            ? Colors.red 
                            : (isEnabled 
                                ? Theme.of(context).colorScheme.primary 
                                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38)),
                        shape: BoxShape.circle,
                        boxShadow: isRecording 
                            ? [
                                BoxShadow(
                                  color: Colors.red.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        isRecording ? Icons.stop : Icons.mic,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isRecording ? 'Stop Recording' : 'Start Recording',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isEnabled 
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38),
                    ),
                  ),
                  if (isRecording) ...[
                    const SizedBox(height: 16),
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}