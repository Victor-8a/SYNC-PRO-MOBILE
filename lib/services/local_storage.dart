import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static late SharedPreferences prefs;

  static Future<void> configurePrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setString(String name, String value) async {
    await prefs.setString(name, value);
  }

  static String? getString(String name) {
    return prefs.getString(name);
  }

  static Future<void> setInt(String name, int value) async {
    await prefs.setInt(name, value);
  }

  static int? getInt(String name) {
    return prefs.getInt(name);
  }

  static Future<void> setBool(String name, bool value) async {
    await prefs.setBool(name, value);
  }

  static bool? getBool(String name) {
    return prefs.getBool(name);
  }

  static Future<void> remove(String name) async {
    await prefs.remove(name);
  }

  static Future<void> clear() async {
    await prefs.clear();
  }

  static Future<void> setStringList(String name, List<String> value) async {
    await prefs.setStringList(name, value);
  }

  static List<String>? getStringList(String name) {
    return prefs.getStringList(name);
  }
}
