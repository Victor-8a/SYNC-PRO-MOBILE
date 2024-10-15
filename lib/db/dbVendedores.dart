import 'dart:async';
import 'dart:convert'; // For json.decode

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http; // For HTTP requests
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sync_pro_mobile/Pedidos/services/ApiRoutes.dart';
import 'package:sync_pro_mobile/Pedidos/services/LoginToken.dart';
import 'bd.dart';
import 'package:sqflite/sqflite.dart';
import '../Pedidos/Models/Vendedor.dart';

class DatabaseHelperVendedor {
  final dbProvider = DatabaseHelper();
  Future<void> insertVendedor(Vendedor vendedor) async {
    final db = await dbProvider.database;
    await db.insert(
      'vendedores',
      vendedor.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Vendedor> loadSalesperson() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idVendedor = prefs.getString('idVendedor');
    String? vendedorName = prefs.getString('vendedorName');

    return Vendedor(value: int.parse(idVendedor!), nombre: vendedorName!);
  }

  Future<void> saveVendedorToLocalDatabase(Vendedor vendedor) async {
    try {
      DatabaseHelperVendedor dbHelper = DatabaseHelperVendedor();
      await dbHelper.insertVendedor(vendedor);
    } catch (error) {
      print('Error saving vendedor to local database: $error');
      throw Exception('Failed to save vendedor to local database: $error');
    }
  }

  Future<List<Vendedor>> getVendedores() async {
    final db = await dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.query('vendedores');
    return List.generate(maps.length, (i) {
      return Vendedor.fromJson(maps[i]);
    });
  }

  Future<void> deleteAllVendedores() async {
    final db = await dbProvider.database;
    await db.delete('vendedores');
  }

  Future<bool> fetchAndStoreVendedores() async {
    try {
      // Verificar la conectividad
      var connectivityResult = await Connectivity()
          .checkConnectivity()
          .timeout(Duration(seconds: 5));
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // Obtener el token de autorización
      String? token = await login();
      if (token == null) {
        throw Exception('Token de autorización no válido');
      }

      // Definir las cabeceras de la solicitud HTTP
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // Realizar la petición HTTP a la API de vendedores
      final url = ApiRoutes.buildUri('vendedor'); // Asignar el valor de la URL
      final response =
          await http.get(url, headers: headers).timeout(Duration(seconds: 5));

      // Verificar si la respuesta fue exitosa
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);

        // Convertir la respuesta JSON en una lista de objetos Vendedor
        List<Vendedor> vendedores =
            jsonResponse.map((data) => Vendedor.fromJson(data)).toList();

        // Insertar cada vendedor en la base de datos local
        for (var vendedor in vendedores) {
          await insertVendedor(vendedor);
        }

        return true; // Retornar true si todo salió bien
      } else {
        throw Exception(
            'Error al cargar los vendedores: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en fetchAndStoreVendedores: $e');
      return false; // En caso de cualquier error, retornar false
    }
  }

  static initializeDatabase() {}
}
