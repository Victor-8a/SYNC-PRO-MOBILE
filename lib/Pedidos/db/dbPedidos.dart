import 'package:sqflite/sqflite.dart';
import 'package:sync_pro_mobile/Pedidos/Models/Pedido.dart';
import 'package:sync_pro_mobile/Pedidos/db/dbDetallePedidos.dart';

import 'bd.dart';

class DatabaseHelperPedidos {
  final dbProvider = DatabaseHelper();

  Future<int> getOrderCount() async {
    final db = await dbProvider.database;
    return Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM Orders')) ??
        0;
  }

  Future<int> insertOrder(Map<String, dynamic> order) async {
    final db = await dbProvider.database;

    // Convertir valores booleanos a enteros
    order['Anulado'] = order['Anulado'] ? 1 : 0;

    order['synced'] = 0; // Marcar pedido como no sincronizado
    order['NumPedido'] = 0;
    int id = await db.insert(
      'Orders',
      order,
    );
    return id;
  }

  Future<int> insertPedido(Pedido pedido) async {
    final db = await dbProvider.database;

    // Convertir a un mapa los datos del Pedido
    Map<String, dynamic> pedidoMap = pedido.toMap();

    // Insertar el pedido en la base de datos
    int id = await db.insert(
      'Orders',
      pedidoMap,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return id;
  }

  Future<List<Map<String, dynamic>>> getOrdersWithClientAndSeller() async {
    final db = await dbProvider.database;
    final result = await db.rawQuery('''
      SELECT 
       Orders.id,
        Orders.FechaEntrega, 
        clientes.nombre AS nombreCliente, 
        vendedores.nombre AS nombreVendedor,
        Orders.Observaciones,
        Orders.synced,
        Orders.NumPedido
      FROM 
        Orders
      JOIN 
        clientes ON Orders.CodCliente = clientes.codCliente
      JOIN 
        vendedores ON Orders.idVendedor = vendedores.value
      WHERE Orders.Anulado = 0
    ''');

    return result;
  }

  Future<Map<String, dynamic>?> getOrderById(int id) async {
    final db = await dbProvider.database;
    List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT 
       Orders.id,
        Orders.FechaEntrega, 
        clientes.nombre AS nombreCliente, 
        vendedores.nombre AS nombreVendedor,
        Orders.Observaciones,
        Orders.synced,
        Orders.NumPedido
      FROM 
        Orders
      JOIN 
        clientes ON Orders.CodCliente = clientes.codCliente
      JOIN 
        vendedores ON Orders.idVendedor = vendedores.value
      WHERE Orders.Anulado = 0
      AND Orders.id = $id
    ''');
    if (result.isNotEmpty) {
      return result
          .first; // Devuelve el primer elemento de la lista, que es un mapa
    } else {
      return null; // Devuelve null si no se encontró ningún resultado
    }
  }

  Future<List<Map<String, dynamic>>> getUnsyncedOrders() async {
    final db = await dbProvider.database;
    return await db.query('Orders', where: 'synced =?', whereArgs: [0]);
  }

  Future<void> markOrderAsSynced(int id, int numPedido) async {
    final db = await dbProvider.database;
    await db.update(
      'Orders',
      {'synced': 1, 'NumPedido': numPedido},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteOrderById(int orderId) async {
    final db =
        await dbProvider.database; // Accede a la instancia de la base de datos
    await db.delete(
      'Orders',
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  Future<void> deleteOrder(int orderId) async {
    final db = await dbProvider.database;
    await db.delete(
      'Orders',
      where: 'id = ?',
      whereArgs: [orderId],
    );
    await DatabaseHelperDetallePedidos().deleteOrderDetails(orderId);
  }

  Future<List<Map<String, dynamic>>> getAllOrders() async {
    final db = await dbProvider.database;
    var result = await db.query('Orders');
    if (result.isNotEmpty) {
      print('Todos los pedidos encontrados en la base de datos: $result');
    } else {
      print('No se encontraron pedidos en la base de datos.');
    }
    return result;
  }

  Future<void> updateOrder(Map<String, dynamic> order) async {
    final db = await dbProvider.database;
    await db.update(
      'Orders', // Nombre de la tabla en tu base de datos
      order,
      where: 'id = ?',
      whereArgs: [order['id']],
    );
    print('Pedido actualizado en la base de datos: $order');
  }

  insertOrderDetail(Map<String, Object> orderDetailData) {}

  Future<int> deleteAllOrders() async {
    final db = await dbProvider.database;
    return await db.delete('Orders');
  }
}
