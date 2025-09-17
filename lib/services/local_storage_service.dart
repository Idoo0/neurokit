// lib/services/local_storage_service.dart

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  // Keys for storing data. Using constants is a good practice to avoid typos.
  static const String _nameKey = 'userName';
  static const String _classKey = 'userClass';
  static const String _universityKey = 'userUniversity';
  static const String _majorKey = 'userMajor';

  // Method to save all user onboarding data
  Future<void> saveUserData({
    required String name,
    required String userClass,
    required String university,
    required String major,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
    await prefs.setString(_classKey, userClass);
    await prefs.setString(_universityKey, university);
    await prefs.setString(_majorKey, major);
  }

  // Method to retrieve all user data
  Future<Map<String, String>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_nameKey) ?? '',
      'class': prefs.getString(_classKey) ?? '',
      'university': prefs.getString(_universityKey) ?? '',
      'major': prefs.getString(_majorKey) ?? '',
    };
  }
}