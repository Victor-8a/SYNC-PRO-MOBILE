import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
    String path = join(await getDatabasesPath(), 'detallePedido.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE order_details (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            idPedido INTEGER,
            codArticulo TEXT,
            descripcion TEXT,
            cantidad INTEGER,
            precioVenta REAL,
            porcDescuento REAL,
            total REAL
          )
        ''');
      },
    );
  }

  Future<void> insertOrderDetail(Map<String, dynamic> orderDetail) async {
    final db = await database;
    await db.insert(
      'order_details',
      orderDetail,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteOrderDetailsTable() async {
    final db = await database;
    await db.execute('DROP TABLE IF EXISTS order_details');
  }

  Future<List<Map<String, dynamic>>> getOrderDetails() async {
    final db = await database;
    return await db.query('order_details');
  }
}
