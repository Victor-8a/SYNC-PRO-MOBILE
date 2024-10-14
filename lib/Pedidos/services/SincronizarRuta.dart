import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:sync_pro_mobile/Pedidos/PantallasSecundarias/PaginaPedidos.dart';
import 'package:sync_pro_mobile/db/dbDetalleRuta.dart';
import 'package:sync_pro_mobile/db/dbRuta.dart';
import 'package:sync_pro_mobile/Pedidos/services/ApiRoutes.dart';

Future<void> syncRutas() async {
  List<Map<String, dynamic>> unsyncedRutas =
      await DatabaseHelperRuta().getUnsyncedRutas();
  String? token = await login();

  for (var ruta in unsyncedRutas) {
    try {
      // Verificar si el campo 'fechaFin' está vacío o nulo antes de intentar sincronizar
      if (ruta['fechaFin'] == null || ruta['fechaFin'].isEmpty) {
        Fluttertoast.showToast(
          msg: 'No se puede sincronizar la ruta sin fecha de finalización.',
          textColor: Colors.red,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
        print('Ruta sin fecha de finalización. No se puede sincronizar.');
        continue; // Saltar esta ruta y pasar a la siguiente
      }

      var rutaCopy = Map<String, dynamic>.from(ruta);
      rutaCopy.remove('sincronizado');
      rutaCopy.remove('id');

      // Método para eliminar la 'T' de la fecha y dejar solo 3 dígitos en los milisegundos
      String modificarFecha(String fechaOriginal) {
        String sinT = fechaOriginal.replaceAll('T', ' ');
        int puntoIndex = sinT.lastIndexOf('.');

        if (puntoIndex != -1 && sinT.length > puntoIndex + 4) {
          return sinT.substring(0, puntoIndex + 4);
        } else {
          return sinT;
        }
      }

      // Modificar fechaInicio
      if (rutaCopy.containsKey('fechaInicio')) {
        String fechaOriginal = rutaCopy['fechaInicio'];
        String fechaModificada = modificarFecha(fechaOriginal);
        rutaCopy['fechaInicio'] = fechaModificada;
        print('Fecha Inicio Modificada: $fechaModificada');
      }

      // Modificar fechaFin
      if (rutaCopy.containsKey('fechaFin')) {
        String fechaOriginal = rutaCopy['fechaFin'];
        String fechaModificada = modificarFecha(fechaOriginal);
        rutaCopy['fechaFin'] = fechaModificada;
        print('Fecha Fin Modificada: $fechaModificada');
      }

      var body = jsonEncode(rutaCopy);
      var url = ApiRoutes.buildUri('ruta');
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      print('Enviando ruta: $body');
      var response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 401) {
        headers['Authorization'] = 'Bearer $token';
        response = await http.post(url, headers: headers, body: body);
      }

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        print(
            'Respuesta de la API: $jsonResponse'); // Imprimir la respuesta completa para depurar

        if (jsonResponse != null && jsonResponse.containsKey('savedRoute')) {
          var savedRoute = jsonResponse['savedRoute'];
          if (savedRoute.containsKey('Id')) {
            int idRuta = savedRoute['Id'];
            print('Ruta sincronizada correctamente: $ruta');
            Fluttertoast.showToast(
              msg: 'Ruta sincronizada correctamente.',
              textColor: Colors.blue,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
            );

            List<Map<String, dynamic>> unsyncedDetalleRuta =
                await DatabaseHelperDetalleRuta()
                    .getNumeroPedidoReal(ruta['id']);
            print(unsyncedDetalleRuta);

            int syncedDetailsCount = 0;
            for (var detail in unsyncedDetalleRuta) {
              try {
                var detailCopy = Map<String, dynamic>.from(detail);
                if (detailCopy.containsKey('inicio')) {
                  String fechaOriginal = detailCopy['inicio'];
                  String fechaModificada;

                  // ignore: unnecessary_null_comparison
                  if (fechaOriginal == null || fechaOriginal.isEmpty) {
                    fechaModificada = modificarFecha(DateTime.now()
                        .toIso8601String()); // Usar la fecha actual en formato ISO 8601
                  } else {
                    fechaModificada = modificarFecha(fechaOriginal);
                  }

                  detailCopy['inicio'] = fechaModificada;
                  print('Inicio Modificado: $fechaModificada');
                }

                if (detailCopy.containsKey('fin')) {
                  String fechaOriginal = detailCopy['fin'];
                  String fechaModificada;

                  // ignore: unnecessary_null_comparison
                  if (fechaOriginal == null || fechaOriginal.isEmpty) {
                    fechaModificada = modificarFecha(DateTime.now()
                        .toIso8601String()); // Usar la fecha actual en formato ISO 8601
                  } else {
                    fechaModificada = modificarFecha(fechaOriginal);
                  }

                  detailCopy['fin'] = fechaModificada;
                  print('Fin Modificado: $fechaModificada');
                }

                // Verificar si idPedido es 0 y establecerlo como cadena vacía
                if (detailCopy.containsKey('idPedido') &&
                    detailCopy['idPedido'] == 0) {
                  detailCopy['idPedido'] =
                      ""; // Establecer el valor como cadena vacía
                }

                detailCopy.remove('id');
                detailCopy['idRuta'] = idRuta;
                print(detailCopy);
                print('detalle de la ruta');

                var detailUrl = ApiRoutes.buildUri('detalle_ruta');
                var detailBody = jsonEncode(detailCopy);

                print('Enviando detalle de la ruta: $detailBody');
                var detailResponse = await http.post(detailUrl,
                    headers: headers, body: detailBody);

                if (detailResponse.statusCode == 200) {
                  syncedDetailsCount++;
                  if (syncedDetailsCount == unsyncedDetalleRuta.length) {
                    print(
                        'Todos los detalles de la ruta sincronizados correctamente.');
                    await DatabaseHelperRuta()
                        .markRutaAsSynced(ruta['id'], idRuta);
                    Fluttertoast.showToast(
                      msg: 'Ruta y detalles sincronizados correctamente.',
                      textColor: Colors.blue,
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                  }
                } else {
                  print(
                      'Error al sincronizar detalle de la ruta: ${detailResponse.statusCode} - ${detailResponse.body}');
                  Fluttertoast.showToast(
                    msg:
                        'Error. No se pueden sincronizar los detalles de la ruta.',
                    textColor: Colors.red,
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                }
              } catch (error) {
                print('Error al sincronizar detalle de la ruta: $error');
                Fluttertoast.showToast(
                  msg: 'Error al sincronizar detalle de la ruta.',
                  toastLength: Toast.LENGTH_LONG,
                  gravity: ToastGravity.BOTTOM,
                );
              }
            }
          } else {
            print(
                'Error: la respuesta de la API no contiene el campo esperado.');
            Fluttertoast.showToast(
              msg: 'Error al sincronizar ruta: campo esperado no encontrado.',
              textColor: Colors.red,
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
            );
          }
        } else {
          print('Error: la respuesta de la API no contiene el campo esperado.');
          Fluttertoast.showToast(
            msg: 'Error al sincronizar ruta: campo esperado no encontrado.',
            textColor: Colors.red,
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
          );
        }
      } else {
        print(
            'Error al sincronizar ruta: ${response.statusCode} - ${response.body}');
        Fluttertoast.showToast(
          msg: 'Error al sincronizar ruta: ${response.statusCode}',
          textColor: Colors.red,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (error) {
      print('Error al sincronizar ruta: $error');
      Fluttertoast.showToast(
        msg: 'Error al sincronizar ruta.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }
}
