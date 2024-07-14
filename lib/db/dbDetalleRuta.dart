import 'package:sqflite/sqflite.dart';
import 'package:sync_pro_mobile/Models/DetalleRuta.dart';
import 'bd.dart';

class DatabaseHelperDetalleRuta {
  final dbProvider = DatabaseHelper();

  Future<void> insertDetalleRuta(DetalleRuta detalleRuta) async {
    final db = await dbProvider.database;
    await db.insert(
      'detalleRuta',
      detalleRuta.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DetalleRuta>> getDetallesRuta() async {
    final db = await dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.query('detalleRuta');
    return List.generate(maps.length, (i) {
      return DetalleRuta.fromMap(maps[i]);
    });
  }

  Future<List<DetalleRuta>> getDetallesRutaPorRuta(int idRuta) async {
    final db = await dbProvider.database;
    final List<Map<String, dynamic>> maps =
        await db.query('detalleRuta', where: 'idRuta = ?', whereArgs: [idRuta]);
    return List.generate(maps.length, (i) {
      return DetalleRuta.fromMap(maps[i]);
    });
  }

  Future<void> deleteAllDetallesRuta() async {
    final db = await dbProvider.database;
    await db.delete('detalleRuta');
  }
}
