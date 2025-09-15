import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class KeywordService {
  static const String _keywordsKey = 'saved_keywords';
  
  // Default keywords for demo purposes
  static const List<String> _defaultKeywords = [
    'urgent',
    'help',
    'emergency',
    'security',
    'alert',
    'warning',
    'important',
    'critical',
    'password',
    'confidential',
    'private',
    'secure',
  ];

  static Future<List<String>> getKeywords() async {
    final prefs = await SharedPreferences.getInstance();
    final keywordsJson = prefs.getString(_keywordsKey);
    
    if (keywordsJson != null) {
      final List<dynamic> keywordsList = json.decode(keywordsJson);
      return keywordsList.cast<String>();
    }
    
    // Return default keywords if none saved
    await saveKeywords(_defaultKeywords);
    return _defaultKeywords;
  }

  static Future<void> saveKeywords(List<String> keywords) async {
    final prefs = await SharedPreferences.getInstance();
    final keywordsJson = json.encode(keywords);
    await prefs.setString(_keywordsKey, keywordsJson);
  }

  static Future<void> addKeyword(String keyword) async {
    final keywords = await getKeywords();
    if (!keywords.contains(keyword.toLowerCase())) {
      keywords.add(keyword.toLowerCase());
      await saveKeywords(keywords);
    }
  }

  static Future<void> removeKeyword(String keyword) async {
    final keywords = await getKeywords();
    keywords.remove(keyword.toLowerCase());
    await saveKeywords(keywords);
  }

  static List<String> detectKeywords(String transcript, List<String> keywords) {
    final transcriptLower = transcript.toLowerCase();
    final detectedKeywords = <String>[];
    
    for (final keyword in keywords) {
      if (transcriptLower.contains(keyword.toLowerCase())) {
        detectedKeywords.add(keyword);
      }
    }
    
    return detectedKeywords;
  }
}