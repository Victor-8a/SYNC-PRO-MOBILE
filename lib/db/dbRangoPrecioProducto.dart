import 'package:sync_pro_mobile/db/bd.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelperRangoPrecioProducto {
  final dbProvider = DatabaseHelper();  // Asegúrate de que `DatabaseHelper` esté correctamente configurado

  // Método para insertar datos predeterminados usando raw queries
  Future<void> insertDefaultData() async {
    final Database db = await dbProvider.database;  // Obtén la instancia de la base de datos

    // Ejecuta las consultas SQL para insertar los datos
    await db.rawInsert(
      'INSERT INTO RangoPrecioProducto (id, codProducto, precioMin, precioMax, descuento, valorAdicional) VALUES (?, ?, ?, ?, ?, ?)',
      [1, 3839, 6, 12, 25, 0]
    );
    await db.rawInsert(
      'INSERT INTO RangoPrecioProducto (id, codProducto, precioMin, precioMax, descuento, valorAdicional) VALUES (?, ?, ?, ?, ?, ?)',
      [2, 3839, 12, 24, 20, 0]
    );
    await db.rawInsert(
      'INSERT INTO RangoPrecioProducto (id, codProducto, precioMin, precioMax, descuento, valorAdicional) VALUES (?, ?, ?, ?, ?, ?)',
      [3, 3839, 25, 60, 18, 0]
    );
    await db.rawInsert(
      'INSERT INTO RangoPrecioProducto (id, codProducto, precioMin, precioMax, descuento, valorAdicional) VALUES (?, ?, ?, ?, ?, ?)',
      [4, 3839, 60, 100, 16, 0]
    );
    await db.rawInsert(
      'INSERT INTO RangoPrecioProducto (id, codProducto, precioMin, precioMax, descuento, valorAdicional) VALUES (?, ?, ?, ?, ?, ?)',
      [5, 3839, 100, 100000, 15, 0]
    );
  }
}
