import 'package:sqflite/sqflite.dart';
import 'package:sync_pro_mobile/db/bd.dart';
import 'package:sync_pro_mobile/Models/Usuario.dart';

class DatabaseHelperUsuario {
  final dbProvider = DatabaseHelper();

  // Nombre de la tabla
  static const String tableUsuario = 'Usuario';

  // Método para insertar un usuario
  Future<int> insertUsuario(Usuario usuario) async {
    final db = await dbProvider.database;
    return await db.insert(
      tableUsuario,
      usuario.toJson(), // Convertir Usuario a Map<String, dynamic>
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
