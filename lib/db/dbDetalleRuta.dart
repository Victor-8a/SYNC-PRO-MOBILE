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

  Future<List<DetalleRuta>> getDetalleRutaActiva(int idRuta) async {
    final db = await dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT  D.id,
      D.idRuta,
      D.codCliente, 
      C.nombre as nombreCliente,
      CASE D.estado WHEN 'NV' THEN 'No Visitado' WHEN 'V' THEN 'Visitado'
      WHEN 'O' THEN 'Ordeno' WHEN 'A' THEN 'Ausente' ELSE '' END AS estado,
      D.observaciones, 
      D.idPedido, D.inicio, D.fin  FROM DetalleRuta D
      INNER JOIN clientes C  ON D.codCliente= C.codCliente
      WHERE idRuta = $idRuta
    ''');

    return List.generate(maps.length, (i) {
      return DetalleRuta.fromMap(maps[i]);
    });
  }

  Future<void> updateDetalleRuta(DetalleRuta detalleRuta) async {
    final db = await dbProvider.database;
    await db.update(
      'DetalleRuta',
      detalleRuta.toMap(),
      where: 'id = ?',
      whereArgs: [detalleRuta.id],
    );
  }

  Future<void> updateInicioDetalleRuta(int id, String inicio) async {
    final db = await dbProvider.database;
    await db.update(
      'DetalleRuta',
      {'inicio': inicio},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  

  Future<void> updateFinDetalleRuta(int id, String fin) async {
    final db = await dbProvider.database;
    await db.update(
      'DetalleRuta',
      {'fin': fin},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<DetalleRuta>> getClientesDetalle(int idLocalidad) async {
    final db = await dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT  0 AS id,
      0 AS idRuta,
      C.codCliente, 
      C.nombre as nombreCliente,
      'NO VISITADO' AS estado,
      '' AS observaciones, 
      0 AS idPedido, '' AS inicio, '' AS fin  
      FROM clientes C WHERE idLocalidad = $idLocalidad
    ''');

    return List.generate(maps.length, (i) {
      DetalleRuta detalle = DetalleRuta.fromMap(maps[i]);

      return detalle;
    });
  }

  Future<void> updateDetallesRuta(DetalleRuta detalleRutaActualizado) async {
    try {
      final db = await dbProvider.database;

      final Map<String, String> estadoConversion = {
        'Ausente': 'A',
        'Visitado': 'V',
        'No Visitado': 'NV',
        'Ordeno': 'O',
      };

      final nuevoEstado = estadoConversion[detalleRutaActualizado.estado] ??
          detalleRutaActualizado.estado;
      await db.rawUpdate('''
      UPDATE DetalleRuta 
      SET estado = ?, observaciones = ? 
      WHERE id = ?
    ''', [
        nuevoEstado,
        detalleRutaActualizado.observaciones,
        detalleRutaActualizado.id
      ]);

      print("Consulta de actualización de detalles de ruta completada");
    } catch (e) {
      print("Error al actualizar los detalles de la ruta: $e");
    }
  }

Future<int> getDetalleRutaCount(int idRuta) async {
  final db = await dbProvider.database;
  var result = await db.rawQuery(
    'SELECT COUNT(*) FROM DETALLERUTA WHERE FIN = \'\' AND inicio <> \'\' AND idRuta = ?',
    [idRuta]
  );
  int count = Sqflite.firstIntValue(result) ?? 0;
  return count;
}

Future<List<Map<String, dynamic>>> getDetallesNoFinalizados(int idRuta) async {
  final db = await dbProvider.database;
  var result = await db.rawQuery(
    'SELECT * FROM DETALLERUTA WHERE FIN = \'\' AND inicio <> \'\' AND idRuta = ?',
    [idRuta]
  );
  return result;
}


  Future<void> deleteAllDetallesRuta() async {
    final db = await dbProvider.database;
    await db.delete('detalleRuta');
  }
}
