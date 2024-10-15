import 'dart:convert';
import 'package:sync_pro_mobile/db/dbPedidos.dart' as dbGuardarPedido;
import 'package:http/http.dart' as http;

import 'LocalStorage.dart';

Future<int?> saveOrder(int selectedClient, String observations,
    int _selectedSalespersonId, DateTime selectedDate) async {
  String? token = await getTokenFromStorage();
  String userId = await getIdFromStorage();

  // ignore: unnecessary_null_comparison
  if (token == null) {
    return null;
  }

  Map<String, dynamic> dataPedido =
      {}; // Declarar dataPedido fuera del bloque try-catch

  try {
    var url = Uri.parse('/');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    print('Guardando pedido...');

    dataPedido = {
      "CodCliente": selectedClient,
      "Fecha": DateTime.now().toIso8601String(),
      "Observaciones": observations,
      "IdUsuario": userId,
      "FechaEntrega": selectedDate.toIso8601String(),
      "CodMoneda": 1,
      "TipoCambio": 1,
      "Anulado": false, // Usar 0 en lugar de false
      "idVendedor": _selectedSalespersonId,
    };
    var body = jsonEncode(dataPedido);
    print('Guardando pedido: $body');
    var response = await http.post(url, headers: headers, body: body);
    print(
        'Server responded with status code ${response.statusCode} and body: ${response.body}');

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      int idPedido = jsonResponse['savedOrder']['id'];

      // Guardar en SQLite
      dbGuardarPedido.DatabaseHelperPedidos db =
          dbGuardarPedido.DatabaseHelperPedidos();
      await db.insertOrder(dataPedido);
      print('Pedido guardado en SQLite: $dataPedido');

      // Verificar si se guardó en SQLite
      var savedOrder = await db.getAllOrders();
      // ignore: unnecessary_null_comparison
      if (savedOrder != null) {
        print('Pedido verificado en SQLite: $savedOrder');
      }

      return idPedido;
    } else {
      print(
          'Server responded with status code ${response.statusCode} and body: ${response.body}');
      throw Exception('Failed to save order: ${response.statusCode}');
    }
  } catch (error) {
    print('Error saving order: $error');

    // Guardar en SQLite en caso de error
    dbGuardarPedido.DatabaseHelperPedidos db =
        dbGuardarPedido.DatabaseHelperPedidos();

    print('Pedido guardado en SQLite después del error: $dataPedido');

    return await db.insertOrder(dataPedido);
  }
}
