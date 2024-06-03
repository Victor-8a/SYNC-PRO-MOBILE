import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'Models/Producto.dart';

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
    final path = join(dbPath, 'productos.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE productos('
          'codigo INTEGER PRIMARY KEY,'
          'barras TEXT,'
          'descripcion TEXT,'
          'existencia INTEGER,'
          'costo REAL,'
          'precioFinal REAL,'
          'precioB REAL,'
          'precioC REAL,'
          'precioD REAL,'
          'marcas TEXT,'
          'categoriaSubCategoria TEXT,'
          'observaciones TEXT'
          ')',
        );
      },
    );
  }

  Future<void> insertProduct(Product product) async {
    final db = await database;
    await db.insert(
      'productos',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('productos');
    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  Future<void> deleteAllProducts() async {
    final db = await database;
    await db.delete('productos');
  }
}
