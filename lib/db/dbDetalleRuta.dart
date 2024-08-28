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

  Future<void> updateIdPedidoDetalleRuta(
      int codCliente, int idPedido, int idRuta) async {
    final db = await dbProvider.database;
    print('cliente ${codCliente} , pedido: ${idPedido}  idruta ${idRuta}');
    await db.update(
      'DetalleRuta',
      {'idPedido': idPedido, 'estado': 'O'},
      where: 'idRuta = ? AND CodCliente = ?',
      whereArgs: [idRuta, codCliente],
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

// Método para verificar la sincronización de la ruta
  Future<int> verificarSincronizacionRuta(int idRuta) async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT COUNT(*) as count FROM Orders WHERE id IN 
    (
      SELECT idPedido FROM DetalleRuta WHERE idRuta=? AND idPedido<>0
    ) AND synced=0
  ''', [idRuta]);

    if (result.isNotEmpty) {
      return result.first['count'] as int;
    } else {
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> getNumeroPedidoReal(int idRuta) async {
    final db = await dbProvider.database;
    return await db.rawQuery('''
    SELECT D.id, D.idRuta, D.codCliente, D.estado, D.observaciones, O.NumPedido AS idPedido,
    D.inicio, D.fin
    FROM DetalleRuta D 
    LEFT JOIN ORDERS O ON D.idPedido = O.id
    WHERE D.idRuta = ?
  ''', [idRuta]);
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
        [idRuta]);
    int count = Sqflite.firstIntValue(result) ?? 0;
    return count;
  }

  Future<int> getDetalleRutaCountAndUpdate(int idRuta) async {
    final db = await dbProvider.database;
    int count = 0;

    await db.transaction((txn) async {
      // Contar las filas
      var result = await txn.rawQuery(
          'SELECT COUNT(*) FROM DETALLERUTA WHERE FIN = \'\' AND INICIO <> \'\' AND idRuta = ?',
          [idRuta]);
      count = Sqflite.firstIntValue(result) ?? 0;

      // Si hay filas que cumplen la condición, actualizar el campo `FIN`
      if (count > 0) {
        await txn.update(
            'DETALLERUTA',
            {
              'FIN': DateTime.now().toIso8601String()
            }, // Aquí puedes usar el valor que desees para el campo `FIN`
            where: 'FIN = \'\' AND INICIO <> \'\' AND idRuta = ?',
            whereArgs: [idRuta]);
      }
    });

    return count;
  }

  Future<List<Map<String, dynamic>>> getDetallesNoFinalizados(
      int idRuta) async {
    final db = await dbProvider.database;
    var result = await db.rawQuery('''SELECT DR.*, C.nombre 
FROM DETALLERUTA DR
JOIN CLIENTES C ON DR.CodCliente = C.codCliente
WHERE DR.FIN =\'\' AND DR.INICIO <> \'\' AND DR.idRuta =  ?''', [idRuta]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getDetalleRealizado(int idRuta) async {
    final db = await dbProvider.database;
    var result = await db.rawQuery(
        '''SELECT CASE WHEN (inicio <> '' AND fin = '') THEN 1 ELSE 0 END AS realizaPedido  FROM DetalleRuta WHERE id = ?''',
        [idRuta]);
    return result;
  }

// Método para obtener el campo 'fin' de la visita actual
  Future<String?> obtenerFinDetalleRuta(int id) async {
    final db = await dbProvider.database;
    var result = await db.query(
      'DetalleRuta',
      columns: ['fin'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      String? fin = result.first['fin'] as String?;
      return (fin != null && fin.isNotEmpty) ? fin : null;
    } else {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getUnsyncedDetalleRuta(int idRuta) async {
    final db = await dbProvider.database;
    return await db
        .query('DetalleRuta', where: 'idRuta = ?', whereArgs: [idRuta]);
  }

  Future<void> deleteAllDetallesRuta() async {
    final db = await dbProvider.database;
    await db.delete('detalleRuta');
  }
}
