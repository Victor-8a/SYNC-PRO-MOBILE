import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:sync_pro_mobile/Pedidos/services/ApiRoutes.dart';
import 'package:sync_pro_mobile/main.dart';
import 'package:http/http.dart' as http;

Future<String?> login() async {
  String? username = await getUsernameFromStorage();
  String? password = await getPasswordFromStorage();

  if (username == null || password == null) {
    Fluttertoast.showToast(
      msg: 'Credenciales no disponibles, no se puede iniciar sesión.',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
    );
    return null;
  }

  final response = await http.post(
    ApiRoutes.buildUri('auth/login'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'Nombre': username,
      'password': password,
    }),
  );

  if (response.statusCode == 200) {
    String token = jsonDecode(response.body)['token'];
    await saveTokenToStorage(token);
    return token;
  } else {
    Fluttertoast.showToast(
      msg: 'Error al iniciar sesión: ${response.statusCode}',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
    );
    return null;
  }
}
