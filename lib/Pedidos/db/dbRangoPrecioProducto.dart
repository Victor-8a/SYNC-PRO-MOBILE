import 'package:sync_pro_mobile/Pedidos/db/bd.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sync_pro_mobile/Pedidos/Models/RangoPrecioProducto.dart'; // Importa tu modelo

class DatabaseHelperRangoPrecioProducto {
  final dbProvider = DatabaseHelper();

  Future<List<RangoPrecioProducto>> getRangosByProducto(int codigo) async {
    final db = await dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'RangoPrecioProducto', 
      where: 'CodProducto = ?',
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
      );
    });
  }


Future<List<RangoPrecioProducto>> getRangosByProductoBarras(int codigo) async {
  final db = await dbProvider.database;

  final List<Map<String, dynamic>> maps = await db.rawQuery('''
SELECT RangoPrecioProducto.*, productos.barras, productos.descripcion
From RangoPrecioProducto
INNER JOIN productos ON RangoPrecioProducto.CodProducto= productos.codigo
    WHERE RangoPrecioProducto.CodProducto = ?
  ''', [codigo]);

  if (maps.isEmpty) {
    return []; // Retorna una lista vacía si no hay resultados
  }

  // Convierte cada Map en un objeto RangoPrecioProducto y retorna la lista
  return List.generate(maps.length, (i) {
    return RangoPrecioProducto.fromMap(maps[i]);
  });
}

Future<double> getPrecioByProductoYCantidad(int codigoProducto, int cantidad, double precioFinal) async {
  final db = await dbProvider.database;

  final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT IFNULL(
     (SELECT Precio 
      FROM RangoPrecioProducto 
      WHERE CodProducto = ? 
        AND ? BETWEEN CantidadInicio AND CantidadFinal 
      ORDER BY CantidadFinal DESC 
      LIMIT 1), 
     0
   ) AS Precio
 ''', [codigoProducto, cantidad]);

  double precioRango = 0.0;
  if (result.isNotEmpty) {
    precioRango = result.first['Precio'].toDouble();
  }

  // Si no se encuentra un rango, devolver el precioFinal (precio A)
  return precioRango != 0 ? precioRango : precioFinal;
}

Future<int> insertRangoPrecioProducto(RangoPrecioProducto rangoPrecioProducto) async {
  final db = await dbProvider.database; // Asume que tienes una referencia a la base de datos
  return await db.insert(
    'RangoPrecioProducto',
    rangoPrecioProducto.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}



}
