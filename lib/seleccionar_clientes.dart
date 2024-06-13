import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Models/Cliente.dart';
import 'db/dbCliente.dart';


class SeleccionarCliente extends StatefulWidget {
  const SeleccionarCliente({Key? key, required List clientes})
      : super(key: key);

  @override
  _SeleccionarClienteState createState() => _SeleccionarClienteState();
}

class _SeleccionarClienteState extends State<SeleccionarCliente> {
  List<Cliente> _clientes = [];
  List<Cliente> _filteredClientes = [];
  TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    fetchClientes();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  Future<void> fetchClientes() async {
    try {
      var connectivityResult = await Connectivity()
          .checkConnectivity()
          .timeout(Duration(seconds: 5));
      if (connectivityResult == ConnectivityResult.none) {
        print('No internet connection, retrieving clients from local database');
        return await retrieveClientesFromLocalDatabase();
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.get(
        Uri.parse('http://192.168.1.212:3000/cliente'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(Duration(seconds: 5)); 

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        final clientes =
            jsonResponse.map((json) => Cliente.fromJson(json)).toList();
        if (_isMounted) {
          setState(() {
            _clientes = clientes;
            _filteredClientes = clientes;
            saveClientesToLocalDatabase(clientes);
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load clientes');
      }
    } catch (error) {
      print('Error fetching clientes: $error');
      if (_isMounted) {
        await retrieveClientesFromLocalDatabase();
      }
    }
  }

  Future<void> saveClientesToLocalDatabase(List<Cliente> clientes) async {
    try {
      DatabaseHelper databaseHelper = DatabaseHelper();
      await databaseHelper.deleteAllClientes();
      for (var cliente in clientes) {
        await databaseHelper.insertCliente(cliente);
        print('Cliente ${cliente.nombre} inserted into local database');
      }
    } catch (error) {
      print('Error saving clientes to local database: $error');
    }
  }

  Future<void> retrieveClientesFromLocalDatabase() async {
    try {
      DatabaseHelper databaseHelper = DatabaseHelper();
      List<Cliente> clientes = await databaseHelper.getClientes();
      setState(() {
        _clientes = clientes;
        _filteredClientes = clientes;
        _isLoading = false;
      });
    } catch (error) {
      print('Error retrieving clientes from local database: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    String searchTerm = _searchController.text.toLowerCase();
    setState(() {
      _filteredClientes = _clientes
          .where((cliente) =>
              cliente.nombre.toLowerCase().contains(searchTerm) ||
              cliente.cedula.toLowerCase().contains(searchTerm))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Seleccionar Cliente',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
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
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredClientes.isEmpty
                    ? Center(child: Text('No se encontraron clientes'))
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
