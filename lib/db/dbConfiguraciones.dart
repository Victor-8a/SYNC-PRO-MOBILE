import 'package:sqflite/sqflite.dart';
import 'package:sync_pro_mobile/db/bd.dart';

class DatabaseHelperConfiguraciones {
  final dbProvider = DatabaseHelper();
  Future<bool> getUsaRuta() async {
    final db = await dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.query('Configuraciones', where: 'id = ?', whereArgs: [1]);
    if (maps.isNotEmpty) {
      return maps.first['usaRuta'] == 1;
    }
    return false; // Valor predeterminado
  }

  Future<void> setUsaRuta(bool value) async {
    final db = await  dbProvider.database;
    await db.insert(
      'Configuraciones',
      {'id': 1, 'usaRuta': value ? 1 : 0},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
