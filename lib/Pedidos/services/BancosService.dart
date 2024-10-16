import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sync_pro_mobile/Pedidos/services/ApiRoutes.dart';
import 'package:sync_pro_mobile/Pedidos/services/LoginToken.dart';

// Método global para obtener los bancos
Future<List<String>> fetchBanks() async {
  String? token = await login();

  // Lógica para asegurar un token válido
  if (token == null) {
    token = await login();
    if (token == null) {
      throw Exception('No token found and unable to login');
    }
  }

  try {
    // Consulta la API para obtener la lista de bancos
    final response = await http.get(
      ApiRoutes.buildUri('bancos'),
      headers: {'Authorization': 'Bearer $token'},
    );

    // Verifica si la respuesta es exitosa
    if (response.statusCode == 200) {
      List<dynamic> bankData = jsonDecode(response.body);
      return bankData
          .where((bank) => bank['inhabilitado'] != true)
          .map<String>((bank) => bank['nombre'] as String)
          .toList();
    } else {
      print('Error al cargar los bancos, StatusCode: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print('Error al intentar cargar los bancos: $e');
    return [];
  }
}
