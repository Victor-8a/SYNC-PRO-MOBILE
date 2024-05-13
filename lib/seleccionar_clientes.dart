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
  List<Cliente> _filteredClientes = [];

  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchClientes();
    _filteredClientes = _clientes;
    _searchController.addListener(_onSearchChanged);
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
      headers: {'Authorization': 'Bearer $token'},
    ).then((response) {
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        List<Cliente> clientes = [];
        for (var clienteData in jsonResponse) {
          clientes.add(Cliente.fromJson(clienteData));
        }
        setState(() {
          _clientes = clientes;
          _filteredClientes = clientes;
        });
      } else {
        print('Error al cargar clientes: ${response.statusCode}');
      }
    }).catchError((error) {
      print('Error al cargar clientes: $error');
    });
  }

  void _onSearchChanged() {
    String searchTerm = _searchController.text.toLowerCase();
    setState(() {
      _filteredClientes = _clientes.where((cliente) =>
          cliente.nombre.toLowerCase().contains(searchTerm) ||
          cliente.cedula.toLowerCase().contains(searchTerm)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccionar Cliente',      
        style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue, // Cambia el color del AppBar a azul
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _onSearchChanged(),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                labelText: 'Buscar cliente',
                prefixIcon: Icon(Icons.search),
                prefixIconColor: Colors.blue,
              ),
              cursorColor: Colors.blue,
            ),
          ),
          Expanded(
            child: _filteredClientes.isEmpty
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView.builder(
                    itemCount: _filteredClientes.length,
                    itemBuilder: (context, index) {
                      final cliente = _filteredClientes[index];
                      return ListTile(
                        title: Text(cliente.nombre),
                        subtitle: Text(cliente.cedula),
                        onTap: () {
                          Navigator.pop(context, cliente);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
