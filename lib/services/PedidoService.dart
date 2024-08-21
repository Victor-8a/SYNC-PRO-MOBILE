import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;
import 'package:sync_pro_mobile/PantallasSecundarias/PaginaPedidos.dart';

import 'package:sync_pro_mobile/db/dbPedidos.dart' as dbGuardarPedido;
import 'package:sync_pro_mobile/services/ApiRoutes.dart';

import '../db/dbDetallePedidos.dart' as dbDetallePedidos;


class PedidoService{
  
Future<void> syncOrders() async {
  List<Map<String, dynamic>> unsyncedOrders = await dbGuardarPedido.DatabaseHelperPedidos().getUnsyncedOrders();
  String? token = await getTokenFromStorage();

  // ignore: unnecessary_null_comparison
  if (token == null) {
    token = await login();
    if (token == null) {
      Fluttertoast.showToast(
        msg: 'No se puede obtener un token, no se pueden sincronizar los pedidos.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }
  }

  for (var order in unsyncedOrders) {
    try {
      var url =ApiRoutes.buildUri('pedidos/save');
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      var orderCopy = Map<String, dynamic>.from(order);
      orderCopy.remove('synced');
      orderCopy.remove('id');

      var body = jsonEncode(orderCopy);
      print('Enviando pedido: $body');
      var response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 401) {
        // Token expirado o inválido, intentar iniciar sesión nuevamente
        token = await login();
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

        print('Pedido sincronizado correctamente: $order');

        Fluttertoast.showToast(
          msg: 'Pedido sincronizado correctamente.',
          textColor: Colors.blue,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );

        List<Map<String, dynamic>> unsyncedOrderDetails = await dbDetallePedidos.DatabaseHelperDetallePedidos().getUnsyncedOrderDetails(order['id']);
        print(unsyncedOrderDetails);

        int syncedDetailsCount = 0;

        for (int i = 0; i < unsyncedOrderDetails.length; i++) {
          var detail = unsyncedOrderDetails[i];
          try {
            var detailCopy = Map<String, dynamic>.from(detail);
            detailCopy.remove('Id');
            detailCopy['IdPedido'] = idPedido;
            print(detailCopy);

            var detailUrl = ApiRoutes.buildUri('detalle_pedidos/save');
            var detailBody = jsonEncode(detailCopy);

            print('Enviando detalle del pedido: $detailBody');
            var detailResponse = await http.post(detailUrl, headers: headers, body: detailBody);

            if (detailResponse.statusCode == 401) {
              // Token expirado o inválido, intentar iniciar sesión nuevamente
              token = await login();
              if (token != null) {
                headers['Authorization'] = 'Bearer $token';
                detailResponse = await http.post(detailUrl, headers: headers, body: detailBody);
              } else {
                Fluttertoast.showToast(
                  msg: 'Error al iniciar sesión nuevamente. No se pueden sincronizar los detalles del pedido.',
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                );
                return;
              }
            }

            if (detailResponse.statusCode == 200) {
              syncedDetailsCount++;
              if (syncedDetailsCount == unsyncedOrderDetails.length) {
                print('Todos los detalles del pedido sincronizados correctamente.');
                await dbGuardarPedido.DatabaseHelperPedidos().markOrderAsSynced(order['id'],idPedido);
                Fluttertoast.showToast(
                  msg: 'Pedido y detalles sincronizados correctamente.',
                  textColor: Colors.blue,
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
              }
            } else {
              print('Error al sincronizar detalle del pedido: ${detailResponse.statusCode} - ${detailResponse.body}');
            }
          } catch (error) {
            print('Error al sincronizar detalle del pedido: $error');
          }
        }
      } else {
        print('Error al sincronizar pedido: ${response.statusCode} - ${response.body}');
        Fluttertoast.showToast(
          msg: 'Error al sincronizar pedido: ${response.statusCode}',
          textColor: Colors.red,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (error) {
      print('Error al sincronizar pedido: $error');
      Fluttertoast.showToast(
        msg: 'Error al sincronizar pedido.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }
}

}