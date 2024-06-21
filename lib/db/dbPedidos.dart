import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

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
    var documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'orders.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
  CREATE TABLE Orders (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    CodCliente INTEGER,
    Fecha TEXT,
    Observaciones TEXT,
    IdUsuario TEXT,
    FechaEntrega TEXT,
    CodMoneda INTEGER,
    TipoCambio REAL,
    Anulado INTEGER,
    idVendedor INTEGER,
    synced INTEGER DEFAULT 0
  )
''');
    print("Tabla Orders creada correctamente.");
  }
  
Future<int> insertOrder(Map<String, dynamic> order) async {
  final db = await database;

  // Convertir valores booleanos a enteros
  order['Anulado'] = order['Anulado'] ? 1 : 0;

  order['synced'] = 0; // Marcar pedido como no sincronizado

  int id = await db.insert(
    'Orders',
    order,
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
  print('Pedido insertado en la base de datos: $order');
  return id;
}

Future<List<Map<String, dynamic>>> getUnsyncedOrders() async {
  final db = await database;
  return await db.query('Orders', where: 'synced =?', whereArgs: [0]);
}

Future<void> markOrderAsSynced(int id) async {
  final db = await database;
  await db.update(
    'Orders',
    {'synced': 1},
    where: 'id = ?',
    whereArgs: [id],
  );
}


  Future<List<Map<String, dynamic>>> getAllOrders() async {
  final db = await database;
  var result = await db.query('Orders');
  if (result.isNotEmpty) {
    print('Todos los pedidos encontrados en la base de datos: $result');
  } else {
    print('No se encontraron pedidos en la base de datos.');
  }
  return result;
}

  Future<void> updateOrder(Map<String, dynamic> order) async {
    final db = await database;
    await db.update(
      'Orders', // Nombre de la tabla en tu base de datos
      order,
      where: 'id = ?',
      whereArgs: [order['id']],
    );
    print('Pedido actualizado en la base de datos: $order');
  }

  insertOrderDetail(Map<String, Object> orderDetailData) {}
}
