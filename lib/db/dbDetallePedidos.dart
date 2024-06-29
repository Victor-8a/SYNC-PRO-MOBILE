import 'package:sqflite/sqflite.dart';

import 'package:sync_pro_mobile/db/bd.dart';

class DatabaseHelperDetallePedidos {
  final dbProvider = DatabaseHelper();

 Future<List<Map<String, dynamic>>> getUnsyncedOrderDetails(idPedido) async {
 final db = await dbProvider.database;
    return await db.query('order_details', where: 'idPedido = ?', whereArgs: [idPedido]);
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
}