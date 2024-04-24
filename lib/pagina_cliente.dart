import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;



class PaginaCliente extends StatelessWidget {
  const PaginaCliente({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Cliente'),
    );
  }


  
  
}
Future<void> obtenerCliente() async {
  String url = 'http://192.168.1.212:3000/cliente';
  String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MywiaWF0IjoxNzEzOTcxNTUzLCJleHAiOjE3MTQwMDc1NTN9.KVtEbyufugXJQSsVE3HzLiASkY7atH4U8qN8XgVtENw'; // Reemplaza esto con tu token

  var response = await http.get(
    Uri.parse(url),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    },
  );

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body);
    print(data);
  } else {
    print('Error con el status code: ${response.statusCode}.');
  }
}