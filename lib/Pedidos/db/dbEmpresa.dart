import 'package:sqflite/sqflite.dart';
import 'package:sync_pro_mobile/Pedidos/db/bd.dart';

class DatabaseHelperEmpresa {
 final dbProvider = DatabaseHelper();

  Future<void> insertEmpresa(Map<String, dynamic> empresa) async {
    final db = await dbProvider.database;
    await db.insert(
      'empresa',
      empresa,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, dynamic>?> getEmpresa() async {
    final db = await dbProvider.database;
    List<Map<String, dynamic>> results = await db.query('empresa');
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> updateEmpresa(Map<String, dynamic> empresa) async {
    final db = await dbProvider.database;
    await db.update(
      'empresa',
      empresa,
      where: 'id = ?',
      whereArgs: [empresa['id']],
    );
  }

  Future<void> deleteEmpresa() async {
    final db = await dbProvider.database;
    await db.delete('empresa');
  }
}
