import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sync_pro_mobile/Models/Pedido.dart';
import 'package:sync_pro_mobile/db/dbPedidos.dart';
import 'package:sync_pro_mobile/services/ApiRoutes.dart'; // Importa tu clase DatabaseHelperRuta

Future<List<Pedido>> fetchPedido() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    
    if (token == null) {
      throw Exception('Token de autorización no válido');
    }

    var url = ApiRoutes.buildUri('localidad'); // Ajusta la URL según tu endpoint
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      List<Pedido> pedidos = jsonResponse.map((data) => Pedido.fromJson(data)).toList();

      DatabaseHelperPedidos databaseHelperPedidos = DatabaseHelperPedidos();
      for (var pedido in pedidos) {
        await databaseHelperPedidos.insertPedido(pedido);  // Usar el nuevo método
      }

      print('Pedidos cargados exitosamente: ${pedidos.length}');

      return pedidos;
    } else {
      throw Exception('Failed to load pedidos');
    }
  } catch (error) {
    print('Error al obtener los pedidos: $error');
    throw error;
  }
}
