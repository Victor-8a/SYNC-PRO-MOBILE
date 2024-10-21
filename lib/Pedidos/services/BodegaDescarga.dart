import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sync_pro_mobile/Pedidos/services/ApiRoutes.dart';
import 'package:sync_pro_mobile/Pedidos/services/LoginToken.dart';

Future<List<Map<String, dynamic>>> fetchBodegaDescarga() async {
  String? token = await login();

  if (token == null) {
    token = await login();
    if (token == null) {
      throw Exception('No token found and unable to Login');
    }
  }

  try {
    final response = await http.get(
      ApiRoutes.buildUri('bodegas'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> bodegasJson = jsonDecode(response.body);

      // Convertimos los datos en una lista de mapas
      List<Map<String, dynamic>> bodegas = bodegasJson.map((bodega) {
        return {
          'id': bodega['id'],
          'nombre': bodega['nombre'],
          'observaciones': bodega['observaciones'],
          'principal': bodega['principal'] ==
              1, // Si es bit en SQL, puede llegar como 1 o 0
        };
      }).toList();

      return bodegas;
    } else {
      throw Exception('Failed to load Bodega');
    }
  } catch (e) {
    throw e;
  }
}
