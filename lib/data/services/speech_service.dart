import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  late stt.SpeechToText _speechToText;
  bool _isAvailable = false;
  bool _isListening = false;
  String _recognitionResult = '';

  factory SpeechService() {
    return _instance;
  }

  SpeechService._internal() {
    _speechToText = stt.SpeechToText();
  }

  Future<bool> initializeSpeech() async {
    try {
      print('Initializing speech to text...');

      _isAvailable = await _speechToText.initialize(
        onError: (error) {
          print('Speech Error: $error');
        },
        onStatus: (status) {
          print('Speech Status: $status');
        },
      );

      print('Speech Initialization: $_isAvailable');
      return _isAvailable;
    } catch (e) {
      print('Error initializing speech: $e');
      _isAvailable = false;
      return false;
    }
  }

  bool get isAvailable => _isAvailable;
  bool get isListening => _isListening;
  String get recognitionResult => _recognitionResult;

  Future<void> startListening({required Function(String) onResult}) async {
    try {
      if (!_isAvailable) {
        print('Speech service not available, trying to reinitialize...');
        final initialized = await initializeSpeech();
        if (!initialized) {
          throw Exception('Failed to initialize speech recognition');
        }
      }

      if (_isListening) {
        print('Already listening');
        return;
      }

      _recognitionResult = '';

      print('Starting to listen...');

      _speechToText.listen(
        onResult: (result) {
          print('Recognition result: ${result.recognizedWords}');
          _recognitionResult = result.recognizedWords;
          onResult(_recognitionResult);

          if (result.finalResult) {
            print('Final result received');
          }
        },
        localeId: 'en_US',
      );

      _isListening = true;
      print('Listening started successfully');
    } catch (e) {
      print('Error starting listening: $e');
      _isListening = false;
      rethrow;
    }
  }

  Future<void> stopListening() async {
    if (_isListening) {
      try {
        await _speechToText.stop();
        _isListening = false;
        print('Stopped listening');
      } catch (e) {
        print('Error stopping listening: $e');
      }
    }
  }

  Future<void> cancelListening() async {
    if (_isListening) {
      try {
        await _speechToText.cancel();
        _isListening = false;
        print('Cancelled listening');
      } catch (e) {
        print('Error cancelling listening: $e');
      }
    }
  }

  String getLastResult() {
    return _recognitionResult;
  }
}
