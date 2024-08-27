import 'package:sqflite/sqflite.dart';
import 'package:sync_pro_mobile/Models/Cliente.dart';

import 'package:sync_pro_mobile/db/dbUsuario.dart';
import 'bd.dart';

class DatabaseHelperCliente {
  final dbProvider = DatabaseHelper();
  final bool clientesFiltrados; // Parámetro para aplicar filtro

  DatabaseHelperCliente({this.clientesFiltrados = false});

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
    final List<Map<String, dynamic>> maps;
    
    if (clientesFiltrados) {
      // Aplicar el filtro basado en la configuración
      int? idVendedor = await _getIdVendedor(); // Asegúrate de definir este método si es necesario
      maps = await db.query('clientes', where: 'idVendedor = ?', whereArgs: [idVendedor]);
    } else {
      maps = await db.query('clientes');
    }

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
    final List<Map<String, dynamic>> maps;

    if (clientesFiltrados) {
      int? idVendedor = await _getIdVendedor(); // Aplicar el filtro basado en la configuración
      maps = await db.query('clientes', where: 'idLocalidad = ? AND idVendedor = ?', whereArgs: [idLocalidad, idVendedor]);
    } else {
      maps = await db.query('clientes', where: 'idLocalidad = ?', whereArgs: [idLocalidad]);
    }

    return List.generate(maps.length, (i) {
      return Cliente.fromJson(maps[i]);
    });
  }

  Future<void> deleteAllClientes() async {
    final db = await dbProvider.database;
    await db.delete('clientes');
  }

  Future<String?> getClienteNombre(int codCliente) async {
    final db = await dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'clientes',
      columns: ['nombre'],
      where: 'codCliente = ?',
      whereArgs: [codCliente],
    );
    if (maps.isNotEmpty) {
      return maps.first['nombre'] as String?;
    }
    return null;
  }

  // Método para obtener el id del vendedor si es necesario
  Future<int?> _getIdVendedor() async {
    final dbHelperUsuario = DatabaseHelperUsuario();
    return await dbHelperUsuario.getIdVendedor();
  }
}
