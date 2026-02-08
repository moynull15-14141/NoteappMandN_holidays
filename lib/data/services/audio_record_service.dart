import 'package:record/record.dart';

class AudioRecordService {
  static final AudioRecordService _instance = AudioRecordService._internal();
  late Record _audioRecord;
  bool _isRecording = false;

  factory AudioRecordService() {
    return _instance;
  }

  AudioRecordService._internal() {
    _audioRecord = Record();
  }

  bool get isRecording => _isRecording;

  Future<bool> hasPermission() async {
    try {
      final hasPermission = await _audioRecord.hasPermission();
      print('Has audio recording permission: $hasPermission');
      return hasPermission;
    } catch (e) {
      print('Error checking permission: $e');
      return false;
    }
  }

  Future<bool> startRecording() async {
    try {
      // Check permission first
      final hasPermission = await this.hasPermission();
      if (!hasPermission) {
        print('No recording permission');
        return false;
      }

      // Start recording to file
      await _audioRecord.start();
      _isRecording = true;
      print('Recording started');
      return true;
    } catch (e) {
      print('Error starting recording: $e');
      _isRecording = false;
      return false;
    }
  }

  Future<bool> stopRecording() async {
    try {
      if (!_isRecording) return false;

      await _audioRecord.stop();
      _isRecording = false;
      print('Recording stopped');
      return true;
    } catch (e) {
      print('Error stopping recording: $e');
      return false;
    }
  }

  Future<void> cancelRecording() async {
    try {
      await _audioRecord.stop();
      _isRecording = false;
      print('Recording cancelled');
    } catch (e) {
      print('Error cancelling: $e');
    }
  }

  Future<void> dispose() async {
    try {
      await _audioRecord.dispose();
    } catch (e) {
      print('Error disposing: $e');
    }
  }
}
