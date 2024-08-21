import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sync_pro_mobile/Models/Empresa.dart';
import 'package:sync_pro_mobile/db/dbEmpresa.dart';
import 'package:sync_pro_mobile/services/ApiRoutes.dart';

class ImageModel {
  Uint8List imageData;

  ImageModel({required this.imageData});

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    List<int> imageDataList = List<int>.from(json['Imagen']['data']);
    Uint8List imageData = Uint8List.fromList(imageDataList);
    return ImageModel(imageData: imageData);
  }

  Map<String, dynamic> toJson() {
    return {
      'Imagen': {
        'type': 'Buffer',
        'data': imageData.toList(),
      },
    };
  }
}

Future<Empresa> fetchEmpresa(int id) async {
  try {
    // Obtener el token del almacenamiento local
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    // Verificar si el token es válido
    if (token == null) {
      throw Exception('Token de autorización no válido');
    }

    // Configurar la URL y los headers para la solicitud HTTP
    var url = ApiRoutes.buildUri('empresa/id/1');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // Realizar la solicitud HTTP
    final response = await http.get(url, headers: headers);

    // Verificar si la respuesta es exitosa
    if (response.statusCode == 200) {
      // Decodificar la respuesta JSON
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      Empresa empresa = Empresa.fromJson(jsonResponse);

      // Insertar o actualizar la empresa en la base de datos local
      await DatabaseHelperEmpresa().insertEmpresa(empresa.toMap());

      // Imprimir el nombre de la empresa cargada
      print('Empresa cargada exitosamente: ${empresa.empresa}');

      // Devolver la empresa cargada
      return empresa;
    } else {
      // Lanzar una excepción si la solicitud no es exitosa
      throw Exception('Failed to load empresa');
    }
  } catch (error) {
    // Manejar cualquier error que ocurra durante la solicitud
    print('Error al obtener la empresa: $error');
    throw error;
  }
}

Future<ImageModel> fetchImage() async {
  String? token = await getTokenFromStorage();
  if (token == null) {
    throw Exception('Token not found in SharedPreferences');
  }

  final response = await http.get(
    ApiRoutes.buildUri('empresa/imagen'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse = json.decode(response.body);
    return ImageModel.fromJson(jsonResponse);
  } else {
    throw Exception('Failed to load image');
  }
}

Future<void> saveImageToFile(ImageModel imageModel) async {
  final directory = await getApplicationDocumentsDirectory();
  final imagesDirectory = Directory('${directory.path}/images');
  if (!imagesDirectory.existsSync()) {
    imagesDirectory.createSync(recursive: true);
  }
  final filePath = '${imagesDirectory.path}/logo.png';
  final file = File(filePath);
  await file.writeAsBytes(imageModel.imageData);
  print('Logo saved to $filePath');
}

Future<String?> getTokenFromStorage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}
