import 'dart:io';
import 'package:path_provider/path_provider.dart';

class AudioRecordService {
  static final AudioRecordService _instance = AudioRecordService._internal();
  bool _isRecording = false;
  String? _recordingPath;

  factory AudioRecordService() {
    return _instance;
  }

  AudioRecordService._internal();

  bool get isRecording => _isRecording;
  String? get recordingPath => _recordingPath;

  Future<bool> hasPermission() async {
    try {
      // On Windows, we don't need explicit permission
      // On Android/iOS, this would check microphone permissions
      print('Checking audio recording permission');
      return true;
    } catch (e) {
      print('Error checking permission: $e');
      return false;
    }
  }

  Future<bool> requestPermission() async {
    try {
      final hasPermission = await this.hasPermission();
      if (!hasPermission) {
        print('Permission not granted for audio recording');
        return false;
      }
      return true;
    } catch (e) {
      print('Error requesting permission: $e');
      return false;
    }
  }

  Future<String?> _getRecordingPath() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/audio_$timestamp.m4a';
      return filePath;
    } catch (e) {
      print('Error getting recording path: $e');
      return null;
    }
  }

  Future<bool> startRecording() async {
    try {
      // Request permission first
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        print('No recording permission');
        return false;
      }

      // Get file path
      _recordingPath = await _getRecordingPath();
      if (_recordingPath == null) {
        print('Could not get recording path');
        return false;
      }

      // Mark as recording (actual recording would be handled by native code)
      _isRecording = true;
      print('Recording started: $_recordingPath');
      return true;
    } catch (e) {
      print('Error starting recording: $e');
      _isRecording = false;
      _recordingPath = null;
      return false;
    }
  }

  Future<String?> stopRecording() async {
    try {
      if (!_isRecording) {
        print('Recording not in progress');
        return null;
      }

      _isRecording = false;
      print('Recording stopped: $_recordingPath');
      return _recordingPath;
    } catch (e) {
      print('Error stopping recording: $e');
      _isRecording = false;
      return null;
    }
  }

  Future<void> cancelRecording() async {
    try {
      if (_recordingPath != null) {
        final file = File(_recordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
      _isRecording = false;
      _recordingPath = null;
      print('Recording cancelled and deleted');
    } catch (e) {
      print('Error cancelling: $e');
    }
  }

  Future<void> dispose() async {
    try {
      _isRecording = false;
      _recordingPath = null;
    } catch (e) {
      print('Error disposing: $e');
    }
  }
}
