import 'package:sqflite/sqflite.dart';
import 'package:sync_pro_mobile/Models/Localidad.dart';
import 'bd.dart';

class DatabaseHelperLocalidad {
  final dbProvider = DatabaseHelper();

  // Método para insertar una ruta en la base de datos
  Future<void> insertLocalidad(Map<String, dynamic> localidad) async {
    final db = await dbProvider.database;
    try {
      await db.insert(
        'localidad',
        localidad,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      print('Localidad inserted: $localidad');
    } catch (e) {
      print('Error inserting localidad: $e');
    }
  }

  // Método para obtener todas las rutas de la base de datos
  Future<List<Localidad>> getLocalidades() async {
    final db = await dbProvider.database;
    try {
      final List<Map<String, dynamic>> maps = await db.query('localidad');
      return maps.map((map) {
        print(Localidad.fromJson(map));
        return Localidad.fromJson(map);
      }).toList();
    } catch (e, stackTrace) {
      print('Error retrieving rutas: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  // Método para eliminar todas las rutas de la base de datos
  Future<void> deleteAllLocalidades() async {
    final db = await dbProvider.database;
    try {
      await db.delete('localidad');
      print('All rutas deleted');
    } catch (e) {
      print('Error deleting rutas: $e');
    }
  }
}