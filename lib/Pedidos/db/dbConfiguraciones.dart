import 'package:sqflite/sqflite.dart';
import 'package:sync_pro_mobile/Pedidos/db/bd.dart';

class DatabaseHelperConfiguraciones {

  final dbProvider = DatabaseHelper();

  Future<bool> getUsaRuta() async {
    final db = await dbProvider.database;
    final List<Map<String, dynamic>> maps = await db.query('Configuraciones', where: 'id = ?', whereArgs: [1]);
    if (maps.isNotEmpty) {
      return maps.first['usaRuta'] == 1;
    }
    return false; 
  }
Future<bool> getClientesFiltrados() async {
  final db = await dbProvider.database;
  final List<Map<String, dynamic>> maps = await db.query('Configuraciones', where: 'id = ?', whereArgs: [1]);
  
  if (maps.isNotEmpty) {
    print('Valor en base de datos: ${maps.first['clientesFiltrados']}');
    return maps.first['clientesFiltrados'] == 1;
  }
  
  print('No se encontró configuración, devolviendo false por defecto');
  return false;
}


Future<void> setConfiguracion(bool usaRuta, bool clientesFiltrados) async {
  final db = await dbProvider.database;
  await db.insert(
    'Configuraciones',
    {
      'id': 1,
      'usaRuta': usaRuta ? 1 : 0,
      'clientesFiltrados': clientesFiltrados ? 1 : 0,
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<void> insertConfiguracion() async {
  final db = await dbProvider.database;
  await db.insert(
    'Configuraciones',
    {
      'id': 1,
      'usaRuta': 0,
      'clientesFiltrados': 0,
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );

}


Future<void> insertConfiguracionSiEstaVacia() async {
  final db = await dbProvider.database;

  // Consulta para verificar si la tabla Configuraciones está vacía
  final List<Map<String, dynamic>> configuraciones = await db.query('Configuraciones');

  if (configuraciones.isEmpty) {
    // Si la tabla está vacía, realiza la inserción
    await db.insert(
      'Configuraciones',
      {
        'id': 1,
        'usaRuta': 0,
        'clientesFiltrados': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('Configuración insertada.');
  } else {
    print('La tabla Configuraciones ya tiene datos. No se realizó ninguna inserción.');
  }
}


}