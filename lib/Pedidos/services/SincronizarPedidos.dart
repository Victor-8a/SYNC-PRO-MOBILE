import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sync_pro_mobile/Pedidos/services/ApiRoutes.dart';
import 'package:http/http.dart' as http;
import 'package:sync_pro_mobile/Pedidos/services/LoginToken.dart';
import '../../db/dbDetallePedidos.dart' as dbDetallePedidos;
import '../../db/dbPedidos.dart' as dbGuardarPedido;

Future<void> syncOrders() async {
  List<Map<String, dynamic>> unsyncedOrders =
      await dbGuardarPedido.DatabaseHelperPedidos().getUnsyncedOrders();
  String? token = await login();

  if (token == null) {
    token = await login();
    if (token == null) {
      Fluttertoast.showToast(
        msg:
            'No se puede obtener un token, no se pueden sincronizar los pedidos.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }
  }

  // Mostrar el Toast por 5 segundos al inicio de la sincronización
  Fluttertoast.showToast(
    msg: 'Iniciando la sincronización de pedidos.',
    toastLength: Toast.LENGTH_LONG, // 4 segundos
    gravity: ToastGravity.BOTTOM,
  );

  // Esperar 1 segundo adicional para cumplir 5 segundos
  await Future.delayed(Duration(seconds: 1));

  for (var order in unsyncedOrders) {
    try {
      var url = ApiRoutes.buildUri('pedidos');
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      var orderCopy = Map<String, dynamic>.from(order);
      orderCopy.remove('synced');
      orderCopy.remove('id');
      orderCopy.remove('NumPedido');

      var body = jsonEncode(orderCopy);

      var response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 401) {
        // Token expirado o inválido, intentar iniciar sesión nuevamente
        // ignore: unnecessary_null_comparison
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
          response = await http.post(url, headers: headers, body: body);
        } else {
          Fluttertoast.showToast(
            msg: 'Error de Servidor 401',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
          );
          return;
        }
      }

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        int idPedido = jsonResponse['savedOrder']['id'];

        List<Map<String, dynamic>> unsyncedOrderDetails =
            await dbDetallePedidos.DatabaseHelperDetallePedidos()
                .getUnsyncedOrderDetails(order['id']);

        int syncedDetailsCount = 0;

        for (int i = 0; i < unsyncedOrderDetails.length; i++) {
          var detail = unsyncedOrderDetails[i];
          try {
            var detailCopy = Map<String, dynamic>.from(detail);
            detailCopy.remove('Id');
            detailCopy['IdPedido'] = idPedido;

            var detailUrl = ApiRoutes.buildUri('detalle_pedidos');
            var detailBody = jsonEncode(detailCopy);

            var detailResponse =
                await http.post(detailUrl, headers: headers, body: detailBody);

            if (detailResponse.statusCode == 201) {
              syncedDetailsCount++;
              if (syncedDetailsCount == unsyncedOrderDetails.length) {
                await dbGuardarPedido.DatabaseHelperPedidos()
                    .markOrderAsSynced(order['id'], idPedido);
              }
            } else {
              Fluttertoast.showToast(
                msg: 'Error. No se pueden sincronizar los detalles del pedido.',
                textColor: Colors.red,
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            }
          } catch (error) {
            print('Error al sincronizar detalle del pedido: $error');
          }
        }
      } else {
        Fluttertoast.showToast(
          msg: 'Error al sincronizar pedido: ${response.statusCode}',
          textColor: Colors.red,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (error) {
      Fluttertoast.showToast(
        msg: 'Error al sincronizar pedido.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      print('error aqui');
      print(error);
    }
  }

  // Mostrar el Toast por 5 segundos al finalizar la sincronización
  Fluttertoast.showToast(
    msg: 'Sincronización de pedidos completada.',
    toastLength: Toast.LENGTH_LONG, // 4 segundos
    gravity: ToastGravity.BOTTOM,
  );

  // Esperar 1 segundo adicional para cumplir los 5 segundos
  await Future.delayed(Duration(seconds: 1));
}
