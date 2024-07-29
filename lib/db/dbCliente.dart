import 'package:sqflite/sqflite.dart';
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
conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Cliente>> getClientes() async {
  final db = await dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.query('clientes');
    return List.generate(maps.length, (i) {
      return Cliente.fromJson(maps[i]);
    });
  }

  Future<Cliente> getClientesById(int id) async {
  final db = await dbProvider.database;
    final result = await db.query('clientes', where: 'codCliente = ?', whereArgs: [id]);
    return Cliente.fromJson(result.first);
  }

Future<List<Cliente>> getClientesLocalidad(int idLocalidad) async {
  final db = await dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.query('clientes', where: 'idLocalidad = ?', whereArgs: [idLocalidad]);
    return List.generate(maps.length, (i) {
      return Cliente.fromJson(maps[i]);
    });
  }


  
  Future<void> deleteAllClientes() async {
  final db = await dbProvider.database;
    await db.delete('clientes');
  }

  insertVendedor(Vendedor vendedor) {}

}