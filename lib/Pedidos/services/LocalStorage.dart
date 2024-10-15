import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sync_pro_mobile/Pedidos/Models/Vendedor.dart';

class LocalStorage {
  static late SharedPreferences prefs;

  static Future<void> configurePrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setString(String name, String value) async {
    await prefs.setString(name, value);
  }

  static Future<String?> getString(String name) async {
    await configurePrefs();
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

Future<String> getTokenFromStorage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString('token') ??
      ""; // Si el token no existe, devuelve una cadena vacía
  return token;
}

Future<String?> getUsernameFromStorage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? username = prefs.getString('username');
  return username;
}

Future<String?> getPasswordFromStorage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? password = prefs.getString('password');
  return password;
}

Future<String> getIdFromStorage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userId = prefs.getString('userId') ??
      ""; // Si el id no existe, devuelve una cadena vacía
  return userId;
}

Future<Vendedor?> getSalesperson() async {
  String? salespersonJson = await LocalStorage.getString('salesperson');
  if (salespersonJson != null) {
    return Vendedor.fromJson(jsonDecode(salespersonJson));
  } else {
    return null;
  }
}
