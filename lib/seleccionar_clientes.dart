import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Cliente {
  final int codCliente;
  final String nombre;
  final String cedula;
  final String direccion;

  Cliente({
    required this.codCliente,
    required this.nombre,
    required this.cedula,
    required this.direccion,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      codCliente: json['CodCliente'],
      nombre: json['Nombre'],
      cedula: json['Cedula'],
      direccion: json['Direccion'],
    );
  }
}

class SeleccionarCliente extends StatefulWidget {
  const SeleccionarCliente({Key? key, required List clientes}) : super(key: key);

  @override
  _SeleccionarClienteState createState() => _SeleccionarClienteState();
}

class _SeleccionarClienteState extends State<SeleccionarCliente> {
  List<Cliente> _clientes = [];

  @override
  void initState() {
    super.initState();
    _fetchClientes(); // Llama al método para obtener los clientes al iniciar la pantalla
  }

  void _fetchClientes() {
    final String token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6NSwiaWF0IjoxNzE0NDk0NDgxLCJleHAiOjE3MTQ1MDg4ODF9.hcfVD-6alB-H0SZMXMY0HVDM0g5cpfFuLYCeAnLqIJI'; // Reemplaza 'tu_token_aqui' con tu token real

    http.get(
      Uri.parse('http://192.168.1.212:3000/cliente'),
      headers: {'Authorization': 'Bearer $token'}, // Agrega el encabezado Authorization con el token
    ).then((response) {
      if (response.statusCode == 200) {
        // La respuesta fue exitosa, procesa los datos aquí
        List<dynamic> jsonResponse = json.decode(response.body);
        List<Cliente> clientes = [];
        for (var clienteData in jsonResponse) {
          clientes.add(Cliente.fromJson(clienteData));
        }
        setState(() {
          _clientes = clientes;
        });
      } else {
        // Hubo un error al hacer la solicitud
        print('Error al cargar clientes: ${response.statusCode}');
      }
    }).catchError((error) {
      // Error al realizar la solicitud
      print('Error al cargar clientes: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccionar Cliente'),
      ),
      body: _clientes.isEmpty
          ? Center(
              child: CircularProgressIndicator(), // Muestra un indicador de carga si la lista de clientes está vacía
            )
          : ListView.builder(
              itemCount: _clientes.length,
              itemBuilder: (context, index) {
                final cliente = _clientes[index];
                return ListTile(
                  title: Text(cliente.nombre),
                  subtitle: Text(cliente.cedula),
                  onTap: () {
                    // Aquí puedes manejar la selección del cliente, por ejemplo, puedes devolver el cliente seleccionado
                    Navigator.pop(context, cliente);
                  },
                );
              },
            ),
    );
  }
}
