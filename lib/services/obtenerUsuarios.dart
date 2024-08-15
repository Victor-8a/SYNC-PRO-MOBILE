import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sync_pro_mobile/Models/Usuario.dart';
import 'package:sync_pro_mobile/db/dbUsuario.dart';
import 'package:sync_pro_mobile/services/ApiRoutes.dart';

Future<String?> _getToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}

Future<void> fetchAndSaveUsuarios() async {
  final String? token = await _getToken();
  if (token == null) {
    print('Token no encontrado');
    return;
  }

  final response = await http.get(
    ApiRoutes.buildUri('auth/signInV2'), // Ajusta la URL según sea necesario
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
  );

  if (response.statusCode == 200) {
    List<dynamic> datos = jsonDecode(response.body);
    DatabaseHelperUsuario dbHelper = DatabaseHelperUsuario();

    for (var item in datos) {
      // Suponiendo que tienes una clase Usuario con un método fromJson
      Usuario usuario = Usuario.fromJson(item);
      await dbHelper.insertUsuario(usuario);
    }
    print('Usuarios guardados en la base de datos');
  } else {
    print('Error al obtener datos: ${response.statusCode}');
  }
}
