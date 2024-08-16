import 'package:sqflite/sqflite.dart';
import 'package:sync_pro_mobile/db/bd.dart';
import 'package:sync_pro_mobile/Models/Usuario.dart';

class DatabaseHelperUsuario {
  final dbProvider = DatabaseHelper();

  // Nombre de la tabla
  static const String tableUsuario = 'Usuario';

  // Método para obtener el usuario actual

  Future<bool> isUserAdmin() async {
    final db = await dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'Usuario', // Nombre de la tabla
      columns: ['EsAdmin'],
    );

    if (maps.isNotEmpty) {
      return maps.first['EsAdmin'] == 1; // 1 para admin, 0 para no admin
    } else {
      return false;
    }
}


  // Método para insertar un usuario
  Future<int> insertUsuario(Usuario usuario) async {
    final db = await dbProvider.database;
    return await db.insert(
      tableUsuario,
      usuario.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Método para actualizar un usuario
  Future<int> updateUsuario(Usuario usuario) async {
    final db = await dbProvider.database;
    return await db.update(
      tableUsuario,
      usuario.toJson(),
      where: 'id = ?',
      whereArgs: [usuario.id],
    );
  }

  // Método para eliminar un usuario
  Future<int> deleteUsuario() async {
    final db = await dbProvider.database;
    return await db.delete(
      tableUsuario
    );
  }
}
