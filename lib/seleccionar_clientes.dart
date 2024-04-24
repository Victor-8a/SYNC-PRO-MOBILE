import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:http/http.dart' as http;


class Cliente {
   final int codCliente;
   final String nombre;
  final String cedula;
  final String direccion;
  

  Cliente ({
    required this.codCliente,
     required this.nombre,
     required this.cedula,
    required this.direccion,
     
   
  
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente (
      codCliente: json['CodCliente'],
      nombre: json['Nombre'],
      cedula: json['Cedula'],
      direccion: json['Direccion'],
    );
  }
}


class SeleccionarCliente extends StatelessWidget {
  const SeleccionarCliente({Key? key, required List<String> clientes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
     
    // Aquí puedes implementar la lógica para mostrar una lista de clientes
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccionar Cliente'),
        
      ),
     
      body: Center(
        child: Text('Pantalla de Selección de Clientes'), 
      ),
    );
  }
}