class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  bool _isAvailable = false;
  bool _isListening = false;
  String _recognitionResult = '';

  factory SpeechService() {
    return _instance;
  }

  SpeechService._internal() {
    _isAvailable = false;
  }

  Future<bool> initializeSpeech() async {
    try {
      print('Initializing speech service...');
      // Speech recognition initialization would be done via native code
      // or a third-party service in a real implementation
      _isAvailable = true;
      print('Speech service initialized');
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
      _isListening = true;
      print('Listening started successfully');

      // In a real implementation, this would capture audio and recognize speech
      // For now, it just marks the state as listening
    } catch (e) {
      print('Error starting listening: $e');
      _isListening = false;
      rethrow;
    }
  }

  Future<void> stopListening() async {
    if (_isListening) {
      try {
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
