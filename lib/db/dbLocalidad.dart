import 'package:sqflite/sqflite.dart';
import 'package:sync_pro_mobile/Models/Localidad.dart';
import 'bd.dart';

class DatabaseHelperRuta {
  final dbProvider = DatabaseHelper();

  // Método para insertar una ruta en la base de datos
  Future<void> insertRuta(Map<String, dynamic> ruta) async {
    final db = await dbProvider.database;
    await db.insert(
      'localidad',
      ruta,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

  }

  // Método para obtener todas las rutas de la base de datos
  Future<List<Ruta>> getRutas() async {
    final db = await dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.query('localidad');
    print('Rutas retrieved: ${maps.length}');
    return List.generate(maps.length, (i) {
      print('Ruta map: ${maps[i]}');
      return Ruta.fromJson(maps[i]);
    });
  }

  // Método para eliminar todas las rutas de la base de datos
  Future<void> deleteAllRutas() async {
    final db = await dbProvider.database;
    await db.delete('localidad');
    print('All rutas deleted');
  }
}
