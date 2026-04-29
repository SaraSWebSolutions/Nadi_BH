import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nadi_user_app/core/constants/app_consts.dart';
import 'package:nadi_user_app/l10n/app_localizations.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

class RecordWidget extends StatefulWidget {
  final Function(File?)? onRecordComplete;

  const RecordWidget({super.key, this.onRecordComplete});

  @override
  State<RecordWidget> createState() => _RecordWidgetState();
}

class _RecordWidgetState extends State<RecordWidget> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool isRecording = false;
  bool isPlaying = false;
  String? recordedFilePath;

  @override
  void initState() {
    super.initState();

    /// ✅ Only ONE listener (avoid duplicate bugs)
    _audioPlayer.onPlayerComplete.listen((event) {
      if (!mounted) return;
      setState(() => isPlaying = false);
    });
  }

  /// ✅ Start Recording
  Future<void> startRecording() async {
    try {
      /// ✅ Correct permission handling (DO NOT use permission_handler)
      if (!await _audioRecorder.hasPermission()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Microphone permission denied")),
        );
        return;
      }

      /// ✅ Use temporary directory (important)
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );

      setState(() {
        isRecording = true;
        recordedFilePath = null; // IMPORTANT FIX
      });

      debugPrint("Recording started: $path");
    } catch (e) {
      debugPrint("Start recording error: $e");
    }
  }

  /// ✅ Stop Recording
  Future<void> stopRecording() async {
    try {
      final path = await _audioRecorder.stop();

      setState(() {
        isRecording = false;
        recordedFilePath = path;
        isPlaying = false;
      });

      debugPrint("Recording saved: $path");

      if (widget.onRecordComplete != null && path != null) {
        widget.onRecordComplete!(File(path));
      }
    } catch (e) {
      debugPrint("Stop recording error: $e");
    }
  }

  /// ✅ Play / Pause Voice
  Future<void> playPauseVoice() async {
    if (recordedFilePath == null) return;

    /// ✅ Ensure file exists
    if (!File(recordedFilePath!).existsSync()) {
      debugPrint("File not found");
      return;
    }

    try {
      if (isPlaying) {
        await _audioPlayer.pause();
        setState(() => isPlaying = false);
      } else {
        await _audioPlayer.stop();
        await _audioPlayer.play(DeviceFileSource(recordedFilePath!));
        setState(() => isPlaying = true);
      }
    } catch (e) {
      debugPrint("Playback error: $e");
    }
  }

  /// ✅ Toggle Record
  Future<void> toggleRecord() async {
    if (isRecording) {
      await stopRecording();
    } else {
      await startRecording();
    }
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Column(
      children: [
        /// 🎤 RECORD BUTTON
        GestureDetector(
          onTap: toggleRecord,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: isRecording ? Colors.red : AppColors.app_background_clr,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isRecording ? Icons.stop : Icons.mic, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  isRecording ? loc.recording : loc.recordVoice,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        /// ▶️ PLAYBACK UI
        if (recordedFilePath != null && !isRecording)
          Container(
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    onPressed: playPauseVoice,
                  ),
                  Text(loc.recordedVoice),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        recordedFilePath = null;
                        isPlaying = false;
                      });

                      if (widget.onRecordComplete != null) {
                        widget.onRecordComplete!(null);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
