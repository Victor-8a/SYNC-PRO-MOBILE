import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../Models/Cliente.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'clientes.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE clientes('
          'codCliente INTEGER PRIMARY KEY,'
          'nombre TEXT,'
          'cedula TEXT,'
          'direccion TEXT,'
          'observaciones TEXT,'
          'telefono1 TEXT,'
          'telefono2 TEXT,'
          'celular TEXT,'
          'email TEXT,'
          'credito INTEGER,'
          'limiteCredito REAL,'
          'plazoCredito REAL,'
          'tipoPrecio REAL,'
          'restriccion INTEGER,'
          'codMoneda REAL,'
          'moroso INTEGER,'
          'inHabilitado INTEGER,'
          'fechaIngreso TEXT,'
          'idLocalidad REAL,'
          'idAgente REAL,'
          'permiteDescuento INTEGER,'
          'descuento REAL,'
          'maxDescuento REAL,'
          'exonerar INTEGER,'
          'codigo TEXT,'
          'contacto TEXT,'
          'telContacto TEXT,'
          'dpi REAL,'
          'categoria REAL'
          ')',
        );
        print('Database created and table clientes initialized');
      },
    );
  }

  Future<void> insertCliente(Cliente cliente) async {
    final db = await database;
    await db.insert(
      'clientes',
      cliente.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('Cliente inserted: ${cliente.nombre}');
  }

  Future<List<Cliente>> getClientes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('clientes');
    print('Clientes retrieved: ${maps.length}');
    return List.generate(maps.length, (i) {
      print('Cliente map: ${maps[i]}');
      return Cliente.fromJson(maps[i]);
    });
  }

  Future<void> deleteAllClientes() async {
    final db = await database;
    await db.delete('clientes');
    print('All clientes deleted');
  }
}
