import 'dart:convert';
import 'package:flutter/material.dart'; // Asegúrate de importar este paquete para utilizar Colors.
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sync_pro_mobile/Models/Pedido.dart';
import 'package:sync_pro_mobile/Models/DetallePedido.dart'; 
import 'package:sync_pro_mobile/db/dbPedidos.dart';
import 'package:sync_pro_mobile/db/dbDetallePedidos.dart';
import 'package:sync_pro_mobile/db/dbProducto.dart'; 
import 'package:sync_pro_mobile/db/dbUsuario.dart';
import 'package:sync_pro_mobile/services/ApiRoutes.dart';
import 'package:sync_pro_mobile/services/LocalidadService.dart';
import 'package:sqflite/sqflite.dart'; // Asegúrate de importar este paquete para utilizar Sqflite.

Future<List<Pedido>> fetchPedido() async {
  try {
    final dbHelperProductos = DatabaseHelperProducto(); 

    // Verificar si existen productos en la base de datos
    final result = await dbHelperProductos.getExisteProducto();
    int count = Sqflite.firstIntValue(result) ?? 0;

    if (count == 0) {
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

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    
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

      DatabaseHelperPedidos databaseHelperPedidos = DatabaseHelperPedidos();
      DatabaseHelperDetallePedidos databaseHelperDetallePedidos = DatabaseHelperDetallePedidos();

      for (var pedido in pedidos) {
        // Verificar si el pedido ya existe
        Map<String, dynamic>? existingPedido = await databaseHelperPedidos.getOrderById(pedido.id!);

        if (existingPedido != null) {
          // Si existe, reemplazar (actualizar)
          await databaseHelperPedidos.getOrderById(pedido.id!);
        } else {
          // Si no existe, insertar nuevo
          await databaseHelperPedidos.insertPedido(pedido);
        }

        // Obtener el detalle del pedido
        List<DetallePedido> detalles = await fetchDetallePedido(pedido.id!, token);
        
        // Insertar los nuevos detalles
        for (var detalle in detalles) {
          await databaseHelperDetallePedidos.insertOrderDetail(detalle.toJson());
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
      msg: "Error al descargar los productos: $error",
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
