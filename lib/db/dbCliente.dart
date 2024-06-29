import 'package:sync_pro_mobile/Models/Cliente.dart';
import 'package:sync_pro_mobile/Models/Vendedor.dart';

import 'bd.dart';
class DatabaseHelperCliente {
  
final dbProvider = DatabaseHelper();

  Future<void> insertCliente(Cliente cliente) async {
  final db = await dbProvider.database;
    await db.insert(
      'clientes',
      cliente.toJson(),

    );
    print('Cliente inserted: ${cliente.nombre}');
  }

  Future<List<Cliente>> getClientes() async {
  final db = await dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.query('clientes');
    print('Clientes retrieved: ${maps.length}');
    return List.generate(maps.length, (i) {
      print('Cliente map: ${maps[i]}');
      return Cliente.fromJson(maps[i]);
    });
  }

  Future<void> deleteAllClientes() async {
  final db = await dbProvider.database;
    await db.delete('clientes');
    print('All clientes deleted');
  }

  insertVendedor(Vendedor vendedor) {}

}