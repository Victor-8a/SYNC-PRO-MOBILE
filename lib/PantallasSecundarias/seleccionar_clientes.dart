import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sync_pro_mobile/services/localidad_service.dart';
import '../Models/Cliente.dart'; // Asegúrate de importar el modelo Ruta
import '../db/dbCliente.dart';

class SeleccionarCliente extends StatefulWidget {
  const SeleccionarCliente({Key? key, required List clientes}) : super(key: key);

  @override
  _SeleccionarClienteState createState() => _SeleccionarClienteState();
}

class _SeleccionarClienteState extends State<SeleccionarCliente> {
  List<Cliente> _clientes = [];
  List<Cliente> _filteredClientes = [];
  TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  bool _isMounted = false;
  // ignore: unused_field
  bool _localidadCargada = false; // Variable para verificar si la localidad está cargada

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _searchController.addListener(_onSearchChanged);
    fetchClientes(); // Llama a un método que obtenga primero la localidad y luego los clientes
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  // Future<void> fetchRutaAndClientes() async {
  //   try {
  //     await fetchRuta(); // Llama a tu método para obtener la localidad (ajusta el ID según tu necesidad)
  //     _localidadCargada = true; // Marca que la localidad está cargada correctamente
  //     if (_isMounted) {
  //       await fetchClientes(); // Llama a tu método para obtener los clientes si la localidad está cargada
  //     }
  //   } catch (error) {
  //     print('Error fetching ruta and clientes: $error');
  //   }
  // }

  Future<void> fetchClientes() async {
    try {
      var connectivityResult = await Connectivity()
          .checkConnectivity()
          .timeout(Duration(seconds: 5));
      if (connectivityResult == ConnectivityResult.none) {
        print('No hay conexión a Internet, recuperando clientes de la base de datos local');
        return await retrieveClientesFromLocalDatabase();
      }
      await fetchRuta();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('No se encontró el token');
      }

      final response = await http.get(
        Uri.parse('http://192.168.1.212:3000/cliente'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        final clientes = jsonResponse.map((json) => Cliente.fromJson(json)).toList();
        if (_isMounted) {
          setState(() {
            _clientes = clientes;
            _filteredClientes = clientes;
            saveClientesToLocalDatabase(clientes);
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Fallo al cargar clientes');
      }
    } catch (error) {
      print('Error al obtener clientes: $error');
      if (_isMounted) {
        await retrieveClientesFromLocalDatabase();
      }
    }
  }

  Future<void> saveClientesToLocalDatabase(List<Cliente> clientes) async {
    try {
      DatabaseHelperCliente databaseHelper = DatabaseHelperCliente();
      await databaseHelper.deleteAllClientes();
      for (var cliente in clientes) {
        await databaseHelper.insertCliente(cliente);
    
      }
    } catch (error) {
      print('Error al guardar clientes en la base de datos local: $error');
    }
  }

  Future<void> retrieveClientesFromLocalDatabase() async {
    try {
      DatabaseHelperCliente databaseHelper = DatabaseHelperCliente();
      List<Cliente> clientes = await databaseHelper.getClientes();
      setState(() {
        _clientes = clientes;
        _filteredClientes = clientes;
        _isLoading = false;
      });
    } catch (error) {
      print('Error al recuperar clientes de la base de datos local: $error');
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
