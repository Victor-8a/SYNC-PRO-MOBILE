import 'package:sync_pro_mobile/db/bd.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sync_pro_mobile/Models/RangoPrecioProducto.dart'; // Importa tu modelo

class DatabaseHelperRangoPrecioProducto {
  final dbProvider = DatabaseHelper();

  Future<void> insertDefaultData() async {
    final Database db = await dbProvider.database;

    await db.rawInsert(
      'INSERT INTO RangoPrecioProducto (CodProducto, CantidadInicio, CantidadFinal, Precio, Inhabilitado) VALUES (?, ?, ?, ?, ?)',
      [3839, 6, 12, 25, 0],
    );
    // Resto de las inserciones...
  }

 Future<List<RangoPrecioProducto>> getRangosByProducto(int codigo) async {
  final db = await dbProvider.database;
  final List<Map<String, dynamic>> maps = await db.query(
    'RangoPrecioProducto',
    where: 'codProducto = ?',
    whereArgs: [codigo],
  );

  if (maps.isEmpty) {
    return []; // Retorna una lista vacía si no hay resultados
  }

  // Aquí mapeamos los resultados
  return List.generate(maps.length, (i) {
    return RangoPrecioProducto(
 codProducto: maps[i]['CodProducto'],
        cantidadInicio: maps[i]['CantidadInicio'],
        cantidadFinal: maps[i]['CantidadFinal'],
        precio: maps[i]['Precio'],
        inhabilitado: maps[i]['Inhabilitado'],
    );
  });
}
}