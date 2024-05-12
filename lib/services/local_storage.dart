import 'package:shared_preferences/shared_preferences.dart';
class LocalStorage{
  static late SharedPreferences prefs;

  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static configurePrefs() {}

  static Future<void> setString(String name, String value) async {
    await init();
    await prefs.setString(name, value);
  }

   static String? getString(String name) {
    init();
    return prefs.getString(name);
  }

  static Future<void> setInt(String name, int value) async {
    init();
    await prefs.setInt(name, value);
  }

  static int? getInt(String name) {
    init();
    return prefs.getInt(name);
  }

  static Future<void> setBool(String name, bool value) async {
    init();
    await prefs.setBool(name, value);
  }

  static bool? getBool(String name) {
    init();
    return prefs.getBool(name);
  }

  static Future<void> remove(String name) async {
    init();
    await prefs.remove(name);
  }

  static Future<void> clear() async {
    init();
    await prefs.clear();
  }

   static Future<void> setStringList(String name, List<String> value ) async {
    init();
    await prefs.setStringList(name, value);
  }

  static List<String>? getStringList(String name) {
    init();
    return prefs.getStringList(name);
  }
}