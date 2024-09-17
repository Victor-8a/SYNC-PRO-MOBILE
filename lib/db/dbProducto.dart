import 'dart:async';
import 'bd.dart';
import 'package:sqflite/sqflite.dart';
import '../Pedidos/Models/Producto.dart';

class DatabaseHelperProducto {
final dbProvider = DatabaseHelper();


  Future<void> insertProduct(Product product) async {
final db = await dbProvider.database;

    await db.insert(
      'productos',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  

  Future <List<Map<String, dynamic>>> getExisteProducto() async {
  final db = await dbProvider.database;
  final result = await db.rawQuery('''select count(*) from productos
''');

return result;
}



  Future<List<Product>> getProducts() async {
final db = await dbProvider.database;

    final List<Map<String, dynamic>> maps = await db.query('productos');
    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  Future<void> deleteAllProducts() async {
  final db = await dbProvider.database;

    await db.delete('productos');
  }
}