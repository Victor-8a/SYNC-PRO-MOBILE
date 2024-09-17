import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sync_pro_mobile/Pedidos/Models/Localidad.dart';
import 'package:sync_pro_mobile/db/dbLocalidad.dart';
import 'package:sync_pro_mobile/Pedidos/services/ApiRoutes.dart'; // Importa tu clase DatabaseHelperRuta

Future<List<Localidad>> fetchRuta() async {
  try {
    // Obtener el token del almacenamiento local
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    
    // Verificar si el token es válido
    if (token == null) {
      throw Exception('Token de autorización no válido');
    }

    // Configurar la URL y los headers para la solicitud HTTP
    var url = ApiRoutes.buildUri('localidad'); // Ajusta la URL según tu endpoint
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // Realizar la solicitud HTTP
    final response = await http.get(url, headers: headers);

    // Verificar si la respuesta es exitosa
    if (response.statusCode == 200) {
      // Decodificar la respuesta JSON
      final List<dynamic> jsonResponse = json.decode(response.body);
      List<Localidad> rutas = jsonResponse.map((data) => Localidad.fromJson(data)).toList();

      // Insertar las rutas en la base de datos local
      DatabaseHelperLocalidad databaseHelperRuta = DatabaseHelperLocalidad();
      for (var ruta in rutas) {
        await databaseHelperRuta.insertLocalidad(ruta.toMap());
      }

      // Imprimir el número de rutas cargadas
      print('Rutas cargadas exitosamente: ${rutas.length}');

      // Devolver la lista de rutas
      return rutas;
    } else {
      // Lanzar una excepción si la solicitud no es exitosa
      throw Exception('Failed to load rutas');
    }
  } catch (error) {
    // Manejar cualquier error que ocurra durante la solicitud
    print('Error al obtener las rutas: $error');
    throw error;
  }
}
 