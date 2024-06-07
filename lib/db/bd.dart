import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String documentsDirectory = (await getApplicationDocumentsDirectory()).path;
  String path = join(documentsDirectory, 'my_database.db');
  // ignore: unused_local_variable
  Database database = await openDatabase(path, version: 1,
    onCreate: (Database db, int version) async {
      // Código para crear las tablas de la base de datos
    });
}
