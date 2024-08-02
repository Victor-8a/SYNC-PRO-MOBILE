import 'package:sqflite/sqflite.dart';
import 'package:sync_pro_mobile/Models/Ruta.dart';
import 'bd.dart';

class DatabaseHelperRuta {
  final dbProvider = DatabaseHelper();

  Future<Ruta> insertRuta(Map<String, dynamic> ruta) async {
    final db = await dbProvider.database;
    int id = await db.insert(
      'ruta',
      ruta,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Recuperar el registro insertado
    List<Map<String, dynamic>> result = await db.query(
      'ruta',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return Ruta.fromMap(result.first);
    } else {
      throw Exception('Error al recuperar la ruta insertada');
    }
  }

  Future<List<Ruta>> getRutas() async {
    final db = await dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.query('ruta');
    return List.generate(maps.length, (i) {
      return Ruta.fromMap(maps[i]);
    });
  }

  Future<Ruta> getRutaActiva() async {
    final db = await dbProvider.database;
    final result = await db.rawQuery('''
      SELECT  * FROM Ruta WHERE fechaFin ='' ORDER BY id  LIMIT 1;
    ''');

    return Ruta.fromMap(result.first);
  }

  Future<List<Ruta>> getRutasPorVendedor(int idVendedor) async {
    final db = await dbProvider.database;
    final List<Map<String, dynamic>> maps = await db
        .query('ruta', where: 'idVendedor = ?', whereArgs: [idVendedor]);
    return List.generate(maps.length, (i) {
      return Ruta.fromMap(maps[i]);
    });
  }

  Future<void> updateFechaFinRuta(int id, String fechaFin) async {
    final db = await dbProvider.database;
    await db.rawUpdate(
      'UPDATE Ruta SET fechaFin = ? WHERE id = ?',
      [fechaFin, id],
    );
  }

  

  Future<void> deleteAllRutas() async {
    final db = await dbProvider.database;
    await db.delete('ruta');
  }


    Future<List<Map<String, dynamic>>> getUnsyncedRutas() async {
    final db = await dbProvider.database;
    return await db.query('Ruta', where: 'sincronizado = ?', whereArgs: [0]);
  }

  Future<void> markRutaAsSynced(int localId, int remoteId) async {
    final db = await dbProvider.database;
    await db.update(
      'Ruta',
      {'sincronizado': 1, 'id': remoteId},
      where: 'id = ?',
      whereArgs: [localId],
    );
  }
}

  
