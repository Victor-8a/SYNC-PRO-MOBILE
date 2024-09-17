import 'dart:convert';
import 'package:flutter/material.dart'; // Asegúrate de importar este paquete para utilizar Colors.
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:sync_pro_mobile/Pedidos/Models/Pedido.dart';
import 'package:sync_pro_mobile/Pedidos/Models/DetallePedido.dart';
import 'package:sync_pro_mobile/Pedidos/PantallasSecundarias/PaginaPedidos.dart'; 
import 'package:sync_pro_mobile/db/dbPedidos.dart';
import 'package:sync_pro_mobile/db/dbDetallePedidos.dart';
import 'package:sync_pro_mobile/db/dbProducto.dart'; 
import 'package:sync_pro_mobile/db/dbUsuario.dart';
import 'package:sync_pro_mobile/Pedidos/services/ApiRoutes.dart';
import 'package:sync_pro_mobile/Pedidos/services/LocalidadService.dart';
import 'package:sqflite/sqflite.dart'; // Asegúrate de importar este paquete para utilizar Sqflite.

Future<List<Pedido>> fetchPedido() async {
  try {
    final dbHelperProductos = DatabaseHelperProducto(); 
    final dbHelperPedidos = DatabaseHelperPedidos(); 
    final dbHelperDetallePedidos = DatabaseHelperDetallePedidos(); // Instancia para la tabla de detalles

    // Verificar si hay pedidos no sincronizados
    List<Map<String, dynamic>> unsyncedOrders = await dbHelperPedidos.getUnsyncedOrders();

    if (unsyncedOrders.isNotEmpty) {
      // Mostrar una notificación si hay pedidos no sincronizados
      Fluttertoast.showToast(
        msg: "Tiene pedidos sin sincronizar. Por favor, sincronice primero.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
      return []; // Detener la función si hay pedidos no sincronizados
    }

    // Verificar si existen productos en la base de datos
    final result = await dbHelperProductos.getExisteProducto();
    int countProductos = Sqflite.firstIntValue(result) ?? 0;

    if (countProductos == 0) {
      // Mostrar una notificación si no hay productos
      Fluttertoast.showToast(
        msg: "No hay productos en la base de datos. Cargue su inventario primero.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return []; // Detener la función si no hay productos
    }

    // Verificar si existen pedidos en la base de datos antes de intentar limpiar las tablas
    final countPedidos = await dbHelperPedidos.getOrderCount();
    final countDetallePedidos = await dbHelperDetallePedidos.getOrderDetailCount();

    if (countPedidos > 0) {
      await dbHelperPedidos.deleteAllOrders();
    }

    if (countDetallePedidos > 0) {
      await dbHelperDetallePedidos.deleteAllOrderDetails();
    }

    // Mostrar toast de inicio de descarga
    Fluttertoast.showToast(
      msg: "Descargando pedidos...",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 5,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    
    String? token =  await login();
    
    if (token == null) {
      throw Exception('Token de autorización no válido');
    }

    DatabaseHelperUsuario dbHelperUsuario = DatabaseHelperUsuario();
    int? idVendedor = await dbHelperUsuario.getIdVendedor();
    
    if (idVendedor == null) {
      throw Exception('No se pudo obtener el id del vendedor');
    }

    var url = ApiRoutes.buildUri('pedidos/listV2/seller/$idVendedor');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      await fetchRuta();
      final List<dynamic> jsonResponse = json.decode(response.body);
      print('Pedidos obtenidos exitosamente: ${jsonResponse}');
      List<Pedido> pedidos = jsonResponse.map((data) => Pedido.fromJson(data)).toList();

      for (var pedido in pedidos) {
        // Insertar nuevo pedido
        await dbHelperPedidos.insertPedido(pedido);

        // Obtener el detalle del pedido
        List<DetallePedido> detalles = await fetchDetallePedido(pedido.id!, token);
        
        // Insertar los nuevos detalles
        for (var detalle in detalles) {
          await dbHelperDetallePedidos.insertOrderDetail(detalle.toJson());
        }
      }

      // Mostrar toast de éxito
      Fluttertoast.showToast(
        msg: "Pedidos descargados correctamente",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      print('Pedidos y detalles cargados exitosamente: ${pedidos.length}');

      return pedidos;
    } else {
      throw Exception('Failed to load pedidos');
    }
  } catch (error) {
    // Mostrar toast de error
    Fluttertoast.showToast(
      msg: "Error al descargar los pedidos: $error",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 5,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );

    print('Error al obtener los pedidos: $error');
    throw error;
  }
}

Future<List<DetallePedido>> fetchDetallePedido(int pedidoId, String token) async {
  try {
    var url = ApiRoutes.buildUri('detalle_pedidos/listV2/$pedidoId');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = json.decode(response.body);
      print('Detalles del pedido obtenidos exitosamente: ${jsonResponse}');
      return jsonResponse.map((data) => DetallePedido.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load detalles for pedido $pedidoId');
    }
  } catch (error) {
    print('Error al obtener los detalles del pedido $pedidoId: $error');
    throw error;
  }
}
