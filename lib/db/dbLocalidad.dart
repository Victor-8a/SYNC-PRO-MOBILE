import 'package:sqflite/sqflite.dart';
import 'package:sync_pro_mobile/Models/Localidad.dart';
import 'bd.dart';

class DatabaseHelperRuta {
  final dbProvider = DatabaseHelper();

  // Método para insertar una ruta en la base de datos
  Future<void> insertRuta(Map<String, dynamic> ruta) async {
    final db = await dbProvider.database;
    try {
      await db.insert(
        'localidad',
        ruta,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Ruta inserted: $ruta');
    } catch (e) {
      print('Error inserting ruta: $e');
    }
  }

  // Método para obtener todas las rutas de la base de datos
  Future<List<Ruta>> getRutas() async {
    final db = await dbProvider.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query('localidad');
      return maps.map((map) {
        return Ruta.fromJson(map);
      }).toList();
    } catch (e, stackTrace) {
      print('Error retrieving rutas: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  // Método para eliminar todas las rutas de la base de datos
  Future<void> deleteAllRutas() async {
    final db = await dbProvider.database;
    try {
      await db.delete('localidad');
      print('All rutas deleted');
    } catch (e) {
      print('Error deleting rutas: $e');
    }
  }
}
