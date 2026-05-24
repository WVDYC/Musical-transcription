import 'dart:io';
import 'package:record/record.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

class AudioService {
  final AudioRecorder _audioRecorder = AudioRecorder();

  Future<bool> checkPermissions() async {
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }

  Future<String?> startRecording() async {
    try {
      if (await checkPermissions()) {
        final dir = await getApplicationDocumentsDirectory();
        final path = '${dir.path}/recording.wav';

        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav,
            sampleRate: 44100,
            numChannels: 1,
          ),
          path: path,
        );
        return path;
      }
    } catch (e) {
      print('Error starting recording: $e');
    }
    return null;
  }

  Future<String?> stopRecording() async {
    try {
      return await _audioRecorder.stop();
    } catch (e) {
      print('Error stopping recording: $e');
      return null;
    }
  }

  Future<String?> pickAudioFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );

      if (result != null && result.files.single.path != null) {
        return result.files.single.path;
      }
    } catch (e) {
      print('Error picking file: $e');
    }
    return null;
  }

  void dispose() {
    _audioRecorder.dispose();
  }
}
