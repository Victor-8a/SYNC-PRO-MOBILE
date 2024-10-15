import 'dart:convert';
import 'package:sync_pro_mobile/Pedidos/Models/RangoPrecioProducto.dart';
import 'package:sync_pro_mobile/Pedidos/services/LoginToken.dart';
import 'package:sync_pro_mobile/db/dbRangoPrecioProducto.dart';
import 'package:sync_pro_mobile/Pedidos/services/ApiRoutes.dart';
import 'package:http/http.dart' as http;

Future<void> fetchAndSaveRangoPrecios() async {
  final String? token = await login();

  if (token == null) {
    print('Token no encontrado');
    return;
  }

  final response = await http.get(
    ApiRoutes.buildUri('rango_precio_producto'),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
  );

  if (response.statusCode == 200) {
    List<dynamic> datos = jsonDecode(response.body);
    DatabaseHelperRangoPrecioProducto dbHelper =
        DatabaseHelperRangoPrecioProducto();

    for (var item in datos) {
      RangoPrecioProducto rangoPrecio = RangoPrecioProducto.fromJson(item);
      await dbHelper.insertRangoPrecioProducto(rangoPrecio);
    }
    print('Rangos guardados en la base de datos');
  } else {
    print('Error al obtener datos: ${response.statusCode}');
  }
}
