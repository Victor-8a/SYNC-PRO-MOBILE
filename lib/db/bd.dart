import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
    final path = join(dbPath, 'sync_pro_mobile.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createVendedoresTable(db);
        await _createClientesTable(db);
        await _createProductosTable(db);
        await _createOrdersTable(db);
        await _createOrderDetailsTable(db);

        print('Database created and tables initialized');
      },
    );
  }

  Future<void> _createClientesTable(Database db) async {
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
      'categoria REAL,'
     'FOREIGN KEY (idAgente) REFERENCES vendedores (value)'
     ')',
    );
  }

  Future<void> _createOrderDetailsTable(Database db) async {
    await db.execute('''
      CREATE TABLE order_details (
        Id INTEGER PRIMARY KEY AUTOINCREMENT,
        IdPedido INTEGER,
        CodArticulo TEXT,
        Descripcion TEXT,
        Cantidad INTEGER,
        PrecioVenta REAL,
        PorcDescuento REAL,
        Total REAL,
        FOREIGN KEY (IdPedido) REFERENCES Orders (id),
        FOREIGN KEY (CodArticulo) REFERENCES productos(codigo)
      )
    ''');
  }

  Future<void> _createOrdersTable(Database db) async {
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
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (CodCliente) REFERENCES clientes(codCliente),
        FOREIGN KEY (idVendedor) REFERENCES vendedores (value)
      )
    ''');
  }

  Future<void> _createProductosTable(Database db) async {
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
  }

  Future<void> _createVendedoresTable(Database db) async {
    await db.execute(
      'CREATE TABLE vendedores('
      'value INTEGER PRIMARY KEY,'
      'nombre TEXT'
      ')',
    );
  }

  Future<void> deleteAllTables() async {
    final db = await database;
    await db.execute('DROP TABLE IF EXISTS clientes');
    await db.execute('DROP TABLE IF EXISTS order_details');
    await db.execute('DROP TABLE IF EXISTS Orders');
    await db.execute('DROP TABLE IF EXISTS productos');
    await db.execute('DROP TABLE IF EXISTS vendedores');
    print('All tables deleted');
  }

  Future<void> closeDatabase() async {
    final db = await database;
    db.close();
    _database = null; // Limpiar referencia de base de datos al cerrar
    print('Database closed');
  }
}
