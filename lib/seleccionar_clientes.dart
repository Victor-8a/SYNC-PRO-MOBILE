import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'Models/Cliente.dart';

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

  Future<String> _getTokenFromStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? "";
    return token;
  }

  void _fetchClientes() async {
    final String token = await _getTokenFromStorage();

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
