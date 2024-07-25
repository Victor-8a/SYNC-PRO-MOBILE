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
      print(maps[i]['nombreCliente']);
      print(maps[i]['idRuta']);
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
    print('+++++');
    print(idRuta);
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT  D.id,
      D.idRuta,
      D.codCliente, 
      C.nombre as nombreCliente,
      CASE D.estado WHEN 'NV' THEN 'NO VISITADO' WHEN 'V' THEN 'VISITADO'
      WHEN 'O' THEN 'ORDENO' WHEN 'A' THEN 'AUSENTE' ELSE '' END AS estado,
      D.observaciones, 
      D.idPedido, D.inicio, D.fin  FROM DetalleRuta D
      INNER JOIN clientes C  ON D.codCliente= C.codCliente
      WHERE idRuta = $idRuta
    ''');
    print("CONSULTA DETALLE RUTA");
    return List.generate(maps.length, (i) {
      print(maps[i]['nombreCliente']);
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
    print("CONSULTA DETALLE CLIENTES RUTA");
    return List.generate(maps.length, (i) {
      print(maps[i]['nombreCliente']);
      DetalleRuta detalle = DetalleRuta.fromMap(maps[i]);
      print(detalle.codCliente);
      print(detalle.nombreCliente);

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

  
    final nuevoEstado = estadoConversion[detalleRutaActualizado.estado] ?? detalleRutaActualizado.estado;
    await db.rawUpdate('''
      UPDATE DetalleRuta 
      SET estado = ?, observaciones = ? 
      WHERE id = ?
    ''', [nuevoEstado, detalleRutaActualizado.observaciones, detalleRutaActualizado.id]);

    print("Consulta de actualización de detalles de ruta completada");
  } catch (e) {
    print("Error al actualizar los detalles de la ruta: $e");
  }
}

  Future<void> deleteAllDetallesRuta() async {
    final db = await dbProvider.database;
    await db.delete('detalleRuta');
  }
}
