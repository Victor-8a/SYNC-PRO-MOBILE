import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sync_pro_mobile/Pedidos/services/ApiRoutes.dart';
import 'package:sync_pro_mobile/Pedidos/services/LoginToken.dart';
import 'package:http/http.dart' as http;

Future<dynamic> getAperturaCajaActiva() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  String? userId = prefs.getString('userId');

  if (token == null) {
    token = await login();
    if (token == null) {
      throw Exception('No token found and unable to login.');
    }
    await prefs.setString('token', token);
  }

  if (userId == null) {
    throw Exception('No userId found in preferences.');
  }

  try {
    final response = await http.get(
      ApiRoutes.buildUri('apertura/activa/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);

      // Verifica si la respuesta es una lista o un mapa
      if (body is List) {
        return body.map((apertura) {
          if (apertura['unicaja'] == true) {
            return 0;
          } else if (apertura['apertura'] == true) {
            return apertura['id']; // Devuelve idapertura
          } else {
            return -1;
          }
        }).toList();
      } else if (body is Map) {
        if (body['unicaja'] == true) {
          return 0;
        } else if (body['tieneApertura'] == true) {
          return body['idApertura'];
        } else {
          return -1;
        }
      } else {
        throw Exception('Unexpected response format');
      }
    } else {
      throw Exception('Failed to load apertura Activa for userId: $userId');
    }
  } catch (e) {
    throw Exception('Failed to fetch apertura Activa: $e');
  }
}
