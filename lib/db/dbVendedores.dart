import 'dart:async';
import 'dart:convert'; // For json.decode

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http; // For HTTP requests
import 'bd.dart';
import 'package:sqflite/sqflite.dart';
import '../Models/Vendedor.dart';

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
    print('All vendedores deleted');
  }

  Future<bool> fetchAndStoreVendedores() async {
    try {
      var connectivityResult = await Connectivity()
          .checkConnectivity()
          .timeout(Duration(seconds: 5));
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }
      final response = await http.get(Uri.parse('http://192.168.1.212:3000/vendedor')).timeout(Duration(seconds: 5)); 
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        List<Vendedor> vendedores = jsonResponse.map((data) => Vendedor.fromJson(data)).toList();

        // Delete all existing vendedores in the database
        // await deleteAllVendedores();

        // Insert the new vendedores
        for (var vendedor in vendedores) {
          print(vendedor.nombre);
          await insertVendedor(vendedor);
        }
        print('Vendedores fetched and stored');
        return true;
      } else {
        throw Exception('Failed to load vendedores');
      }
    } catch (e) {
      print('Error fetching and storing vendedores: $e');
    }
    return false;
  }
    static initializeDatabase() {}
}