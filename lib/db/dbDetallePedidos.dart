import 'package:sqflite/sqflite.dart';

import 'package:sync_pro_mobile/db/bd.dart';

class DatabaseHelperDetallePedidos {
  final dbProvider = DatabaseHelper();

 Future<List<Map<String, dynamic>>> getUnsyncedOrderDetails(idPedido) async {
 final db = await dbProvider.database;
    return await db.query('order_details', where: 'idPedido = ?', whereArgs: [idPedido]);
  }

  Future<List<Map<String, dynamic>>> getOrderDetailsWithProductos(idPedido) async {
  final db = await dbProvider.database;


  final result = await db.rawQuery('''
    SELECT order_details.*, productos.barras, productos.marcas
    FROM order_details
    INNER JOIN productos ON order_details.CodArticulo = productos.codigo
    WHERE order_details.idPedido = ?

  ''', [idPedido]);

  return result;
}



  Future<void> insertOrderDetail(Map<String, dynamic> orderDetail) async {
    final db = await dbProvider.database;
    await db.insert(
      'order_details',
      orderDetail,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteOrderDetailsTable() async {
   final db = await dbProvider.database;
    await db.execute('DROP TABLE IF EXISTS order_details');
  }

  Future<List<Map<String, dynamic>>> getOrderDetails() async {
 final db = await dbProvider.database;
    return await db.query('order_details');
  }

  Future<void> markOrderDetailAsSynced(int orderId) async {
 final db = await dbProvider.database;
    await db.update(
      'order_details',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }


Future<int> deleteAllOrderDetails() async {
  final db = await dbProvider.database;
  return await db.delete('order_details');
}
  

  // En DatabaseHelperDetallePedidos
Future<int> getOrderDetailCount() async {
  final db = await dbProvider.database;
  return Sqflite.firstIntValue(await db.rawQuery('''
SELECT COUNT(*) FROM order_details''')) ?? 0;
}


Future<void> deleteOrderDetails(int orderId) async {
  final db = await dbProvider.database;
  await db.delete(
    'order_details', // Cambia esto por el nombre real de tu tabla de detalles de pedido
    where: 'idPedido = ?',
    whereArgs: [orderId],
  );
}


}