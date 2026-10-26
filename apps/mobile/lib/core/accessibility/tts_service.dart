import 'package:flutter_tts/flutter_tts.dart';

/* class TTSService {
  static final TTSService instance = TTSService._init();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;

  TTSService._init() {
    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
    });
  }

  Future<void> speak(String text, {String languageCode = 'hi-IN'}) async {
    if (_isSpeaking) {
      await _flutterTts.stop();
    }
    _isSpeaking = true;
    await _flutterTts.setLanguage("hi-IN"); // Set language to Hindi
    await _flutterTts.setSpeechRate(0.5); // Slower pace for accessibility
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      _isSpeaking = false;
    }
  }
} */

class TTSService {
  static final TTSService instance = TTSService._init();
  TTSService._init();

  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await _flutterTts.setLanguage("hi-IN");
      await _flutterTts
          .setSpeechRate(0.5); // Calm, readable pace for rural users
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      _isInitialized = true;
    }
  }

  Future<void> speak(String text) async {
    await _ensureInitialized();
    await _flutterTts.stop(); // Stop any ongoing speech
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
