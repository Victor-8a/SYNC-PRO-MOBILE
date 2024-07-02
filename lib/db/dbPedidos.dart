
import 'bd.dart';
class DatabaseHelperPedidos {

final dbProvider = DatabaseHelper();

  
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
  print('Pedido insertado en la base de datos: $order');
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
    print(result);
    return result;
  }
Future<List<Map<String, dynamic>>> getUnsyncedOrders() async {
  final db = await dbProvider.database;
  return await db.query('Orders', where: 'synced =?', whereArgs: [0]);
}

Future<void> markOrderAsSynced(int id, int numPedido) async {
  final db = await dbProvider.database;
  await db.update(
    'Orders',
    {'synced': 1,
     'NumPedido':numPedido},
    where: 'id = ?',
    whereArgs: [id],
  );
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
}