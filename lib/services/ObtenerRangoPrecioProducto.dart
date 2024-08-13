import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sync_pro_mobile/Models/RangoPrecioProducto.dart';
import 'package:sync_pro_mobile/db/dbRangoPrecioProducto.dart';
import 'package:sync_pro_mobile/services/ApiRoutes.dart';
import 'package:http/http.dart' as http;


Future<String?> _getToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}

Future<void> fetchAndSaveRangoPrecios() async {
  final String? token = await _getToken();

  if (token == null) {
    print('Token no encontrado');
    return;
  }

  final response = await http.get(
    ApiRoutes.buildUri('rango-precio-producto/get'), // Ajusta la URL según sea necesario
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
  );

  if (response.statusCode == 200) {
    List<dynamic> datos = jsonDecode(response.body);
    DatabaseHelperRangoPrecioProducto dbHelper = DatabaseHelperRangoPrecioProducto();

    for (var item in datos) {
      RangoPrecioProducto rangoPrecio = RangoPrecioProducto.fromJson(item);
      await dbHelper.insertRangoPrecioProducto(rangoPrecio);
    }
    print('Datos guardados exitosamente en la base de datos');
  } else {
    print('Error al obtener datos: ${response.statusCode}');
  }
}
