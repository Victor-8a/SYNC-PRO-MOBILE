import 'package:sqflite/sqflite.dart';
import 'package:sync_pro_mobile/Pedidos/Models/Producto.dart';
import 'package:sync_pro_mobile/db/bd.dart';

class DatabaseHelperCarrito {
  final dbProvider = DatabaseHelper();

  Future<List<Map<String, dynamic>>> getCarritoItems() async {
    final db = await dbProvider.database;
    return await db.rawQuery('''
    SELECT carrito.*, productos.* 
    FROM carrito 
    INNER JOIN productos ON carrito.idProducto = productos.codigo
  ''');
  }

  Future<double> getTotalCarrito() async {
    final db = await dbProvider.database;
    final result = await db.rawQuery('''
    SELECT SUM(Cantidad * Precio) as Total
    FROM Carrito
  ''');

    // Verificamos si hay un resultado y lo convertimos a int
    if (result.isNotEmpty && result.first['Total'] != null) {
      return (result.first['Total'] as num).toDouble();
    } else {
      return 0; // Si no hay resultado, devolvemos 0
    }
  }

  Future<void> updateCarritoItem(int productId, int quantity) async {
    final db = await dbProvider.database;
    await db.update(
      'Carrito',
      {'Cantidad': quantity},
      where: 'idProducto = ?',
      whereArgs: [productId],
    );
  }

  Future<void> removeCarritoItem(int productId) async {
    final db = await dbProvider.database;
    await db.delete(
      'Carrito',
      where: 'idProducto = ?',
      whereArgs: [productId],
    );
  }

// Método para contar productos en el carrito
  Future<int> getProductCount() async {
    final db = await dbProvider.database;
    final count = await db.rawQuery('SELECT COUNT(*) as count FROM Carrito');
    return Sqflite.firstIntValue(count) ?? 0;
  }

  Future<void> updateCarritoPrice(int codigo, double price) async {
    final db = await dbProvider.database;
    await db.update(
      'Carrito',
      {
        'Precio': price
      }, // Asegúrate de que el nombre de la columna sea correcto
      where: 'idProducto = ?',
      whereArgs: [codigo],
    );
  }

  Future<void> insertCarrito(Product product, int cantidad) async {
    final db = await dbProvider.database;

    // Verificamos si el producto ya existe en el carrito
    final List<Map<String, dynamic>> existingProduct = await db.query(
      'Carrito',
      where: 'idProducto = ?',
      whereArgs: [product.codigo],
    );

    if (existingProduct.isNotEmpty) {
      // Si el producto ya existe, actualizamos la cantidad sumando la nueva cantidad
      final currentCantidad = existingProduct.first['Cantidad'] as int;
      final newCantidad = currentCantidad + cantidad;

      await db.update(
        'Carrito',
        {
          'Cantidad': newCantidad,
          'Precio': product
              .precioFinal, // Puedes actualizar el precio si es necesario
        },
        where: 'idProducto = ?',
        whereArgs: [product.codigo],
      );
    } else {
      // Si el producto no existe, lo insertamos
      await db.insert(
        'Carrito',
        {
          'idProducto': product.codigo,
          'Cantidad': cantidad,
          'Precio': product.precioFinal,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}
