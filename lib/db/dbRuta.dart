import 'package:sqflite/sqflite.dart';
import 'package:sync_pro_mobile/Models/Ruta.dart';
import 'bd.dart';

class DatabaseHelperRuta {
  final dbProvider = DatabaseHelper();

  Future<void> insertRuta(Ruta ruta) async {
    final db = await dbProvider.database;
    await db.insert(
      'ruta',
      ruta.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Ruta>> getRutas() async {
    final db = await dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.query('ruta');
    return List.generate(maps.length, (i) {
      return Ruta.fromMap(maps[i]);
    });
  }

  Future<List<Ruta>> getRutasPorVendedor(int idVendedor) async {
    final db = await dbProvider.database;
    final List<Map<String, dynamic>> maps =
        await db.query('ruta', where: 'idVendedor = ?', whereArgs: [idVendedor]);
    return List.generate(maps.length, (i) {
      return Ruta.fromMap(maps[i]);
    });
  }

  Future<void> deleteAllRutas() async {
    final db = await dbProvider.database;
    await db.delete('ruta');
  }
}
