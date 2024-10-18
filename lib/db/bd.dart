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
      version: 5, // Incrementa la versión de la base de datos
      onCreate: (db, version) async {
        await _createVendedoresTable(db);
        await _createLocalidadTable(db);
        await _createClientesTable(db);
        await _createProductosTable(db);
        await _createOrdersTable(db);
        await _createOrderDetailsTable(db);
        await _createEmpresaTable(db);
        await _createRutaTable(db);
        await _createDetalleRutaTable(db);
        await _createConfiguracionTable(db);
        await _createRangoPrecioProductoTable(db);
        await _createUsuarioTable(db);
        await _createCarritoTable(db);
        print('Database created and tables initialized');
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 4) {
          // Si la versión anterior es menor a 3, agrega el nuevo campo a la tabla Configuraciones
          await db.execute('''
      ALTER TABLE Configuraciones ADD COLUMN clientesFiltrados INTEGER DEFAULT 0

    ''');
          print(
              'Database upgraded to version 5: "clientesFiltrados" column added to Configuraciones');
        }

        if (oldVersion < 5) {
          // Si la versión anterior es menor a 4, crea la tabla Carrito
          await _createCarritoTable(db);
          print('Database upgraded to version 5: "Carrito" table created');
        }

        if (oldVersion < 6) {
          await db.execute('''
      ALTER TABLE Carrito ADD COLUMN PorcDesc INTEGER
          ''');
        }
      },
    );
  }

  Future<void> _createClientesTable(Database db) async {
    await db.execute('''
      CREATE TABLE clientes(
        codCliente INTEGER PRIMARY KEY,
        nombre TEXT,
        cedula TEXT,
        direccion TEXT,
        observaciones TEXT,
        telefono1 TEXT,
        telefono2 TEXT,
        celular TEXT,
        email TEXT,
        credito INTEGER,
        limiteCredito REAL,
        plazoCredito REAL,
        tipoPrecio REAL,
        restriccion INTEGER,
        codMoneda REAL,
        moroso INTEGER,
        inHabilitado INTEGER,
        fechaIngreso TEXT,
        idLocalidad INTEGER,
        idAgente INTEGER,
        permiteDescuento INTEGER,
        descuento REAL,
        maxDescuento REAL,
        exonerar INTEGER,
        codigo TEXT,
        contacto TEXT,
        telContacto TEXT,
        dpi REAL,
        categoria REAL,
        FOREIGN KEY (idAgente) REFERENCES vendedores (value),
        FOREIGN KEY (idLocalidad) REFERENCES localidad (id)
      )
    ''');
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
        NumPedido INTEGER DEFAULT 0,
        CodCliente INTEGER,
        Fecha TEXT,
        Observaciones TEXT,
        IdUsuario INTEGER,
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
    await db.execute('''
      CREATE TABLE productos(
        codigo INTEGER PRIMARY KEY,
        barras TEXT,
        descripcion TEXT,
        existencia INTEGER,
        costo REAL,
        precioFinal REAL,
        precioB REAL,
        precioC REAL,
        precioD REAL,
        marcas TEXT,
        categoriaSubCategoria TEXT,
        observaciones TEXT
      )
    ''');
  }

  Future<void> _createVendedoresTable(Database db) async {
    await db.execute('''
      CREATE TABLE vendedores(
        value INTEGER PRIMARY KEY,
        nombre TEXT
      )
    ''');
  }

  Future<void> _createEmpresaTable(Database db) async {
    await db.execute('''
      CREATE TABLE empresa(
        Id INTEGER PRIMARY KEY,
        Cedula TEXT,
        Empresa TEXT,
        NombreComercial TEXT,
        Telefono01 TEXT,
        Telefono02 TEXT,
        Fax01 TEXT,
        Fax02 TEXT,
        Direccion TEXT,
        Frase TEXT,
        Email TEXT,
        Web TEXT,
        Facebook TEXT,
        Info TEXT,
        FEL INTEGER,
        FELCliente TEXT,
        FELPassword TEXT,
        EstablecimientoFEL INTEGER,
        ServidorFEL TEXT,
        RegimenFEL TEXT,
        FELPasswordNIT TEXT,
        codigo INTEGER DEFAULT 0
      )
    ''');
  }

  Future<void> _createLocalidadTable(Database db) async {
    await db.execute('''
      CREATE TABLE localidad(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        Nombre TEXT
      )
    ''');
  }

  Future<void> _createRutaTable(Database db) async {
    await db.execute('''
    CREATE TABLE Ruta (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      numRuta INTEGER DEFAULT 0,
      idVendedor INTEGER,
      idLocalidad INTEGER,
      fechaInicio TEXT,
      fechaFin TEXT,
      anulado INTEGER DEFAULT 0,
      sincronizado INTEGER DEFAULT 0,
      FOREIGN KEY (idVendedor) REFERENCES vendedores(value),
      FOREIGN KEY (idLocalidad) REFERENCES localidad(id)
    )
  ''');
  }

  Future<void> _createDetalleRutaTable(Database db) async {
    await db.execute('''
    CREATE TABLE DetalleRuta (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      idRuta INTEGER,
      CodCliente INTEGER,
      estado TEXT,
      observaciones TEXT,
      idPedido INTEGER,
      inicio TEXT,
      fin TEXT,
      FOREIGN KEY (idRuta) REFERENCES Ruta(id),
      FOREIGN KEY (CodCliente) REFERENCES clientes(codCliente),
      FOREIGN KEY (idPedido) REFERENCES Orders(id)
    )
  ''');
  }

  Future<void> _createConfiguracionTable(Database db) async {
    await db.execute('''
    CREATE TABLE Configuraciones(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      usaRuta INTEGER DEFAULT 0,
      clientesFiltrados INTEGER DEFAULT 0,
      usaApertura INTEGER DEFAULT 0
    )
    ''');
  }

  // Future<void> deleteAllTables() async {
  //   final db = await database;
  //   await db.execute('DROP TABLE IF EXISTS clientes');
  //   await db.execute('DROP TABLE IF EXISTS order_details');
  //   await db.execute('DROP TABLE IF EXISTS Orders');
  //   await db.execute('DROP TABLE IF EXISTS productos');
  //   await db.execute('DROP TABLE IF EXISTS vendedores');
  //   await db.execute('DROP TABLE IF EXISTS empresa');
  //   await db.execute('DROP TABLE IF EXISTS localidad');
  //   print('All tables deleted');
  // }

  Future<void> closeDatabase() async {
    final db = await database;
    db.close();
    _database = null; // Limpiar referencia de base de datos al cerrar
    print('Database closed');
  }

  Future<void> _createRangoPrecioProductoTable(Database db) async {
    await db.execute('''
    CREATE TABLE RangoPrecioProducto(
      Id INTEGER PRIMARY KEY AUTOINCREMENT,
      CodProducto INTEGER,
      CantidadInicio REAL,
      CantidadFinal REAL,
      Precio REAL,
      FOREIGN KEY (CodProducto) REFERENCES productos(codigo)
    )
  ''');
  }

  Future<void> _createCarritoTable(Database db) async {
    await db.execute('''
      CREATE TABLE Carrito(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idProducto INTEGER,
        Cantidad INTEGER,
        Precio REAL,
        PorcDescuento INTEGER,
        FOREIGN KEY (idProducto) REFERENCES productos(codigo)
      )
    ''');
  }

  // Método para crear la tabla
  Future<void> _createUsuarioTable(Database db) async {
    await db.execute('''
      CREATE TABLE Usuario (
        id INTEGER PRIMARY KEY,
        Nombre TEXT,
        ClaveEntrada TEXT,
        ClaveInterna TEXT,
        CambiarPrecio INTEGER,
        PorcPrecio REAL,
        AplicarDesc INTEGER,
        PorcDesc REAL,
        ExistNegativa INTEGER,
        Anulado INTEGER,
        Tema TEXT,
        IdVendedor INTEGER,
        VerTodo INTEGER,
        PermitirAbrirVentanas INTEGER,
        VentasFechaAnterior INTEGER,
        EsAdmin INTEGER,
        DiasFacturacion INTEGER,
        EsEncargado INTEGER,
        IdEncargado INTEGER,
        pass_user TEXT
      )
    ''');
  }
}
