import 'dart:async';
import 'dart:convert'; // For json.decode

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http; // For HTTP requests
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../Models/Vendedor.dart';

class VendedorDatabaseHelper {
  static final VendedorDatabaseHelper _instance = VendedorDatabaseHelper._internal();
  factory VendedorDatabaseHelper() => _instance;
  static Database? _database;

  VendedorDatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'vendedores.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE vendedores('
          'id INTEGER PRIMARY KEY,' // 'id' as primary key
          'nombre TEXT'
          ')',
        );
        print('Database created and table vendedores initialized');
      },
    );
  }

  Future<void> insertVendedor(Vendedor vendedor) async {
    final db = await database;
    await db.insert(
      'vendedores',
      vendedor.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('Vendedor inserted: ${vendedor.nombre}');
  }

  Future<List<Vendedor>> getVendedores() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('vendedores');
    print('Vendedores retrieved: ${maps.length}');
    return List.generate(maps.length, (i) {
      print('Vendedor map: ${maps[i]}');
      return Vendedor.fromJson(maps[i]);
    });
  }

  Future<void> deleteAllVendedores() async {
    final db = await database;
    await db.delete('vendedores');
    print('All vendedores deleted');
  }

  Future<bool> fetchAndStoreVendedores() async {
    try {
      var connectivityResult = await Connectivity()
          .checkConnectivity()
          .timeout(Duration(seconds: 5));
      if (connectivityResult == ConnectivityResult.none) {
        print('No internet connection, retrieving clients from local database');
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