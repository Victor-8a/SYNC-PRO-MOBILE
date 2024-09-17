import 'package:sqflite/sqflite.dart';
import 'package:sync_pro_mobile/db/bd.dart';
import 'package:sync_pro_mobile/Pedidos/Models/Usuario.dart';

class DatabaseHelperUsuario {
  final dbProvider = DatabaseHelper();

  // Nombre de la tabla
  static const String tableUsuario = 'Usuario';

  // Método para obtener el idVendedor del usuario actual
  Future<int?> getIdVendedor() async {
    final db = await dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableUsuario,
      columns: ['IdVendedor'], // Asegúrate de que esta columna exista en tu tabla
    );

    if (maps.isNotEmpty) {
      return maps.first['IdVendedor'];
    } else {
      return null;
    }
  }

  // Método para verificar si el usuario es admin
  Future<bool> isUserAdmin() async {
    final db = await dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableUsuario, // Nombre de la tabla
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
