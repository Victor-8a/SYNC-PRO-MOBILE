import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sync_pro_mobile/PantallasSecundarias/CrearCliente.dart';
import 'package:sync_pro_mobile/Models/Cliente.dart';
import 'package:sync_pro_mobile/db/dbCliente.dart';
import 'package:sync_pro_mobile/db/dbUsuario.dart';
import 'package:sync_pro_mobile/services/ApiRoutes.dart';
import 'package:sync_pro_mobile/services/LocalidadService.dart';

class PaginaCliente extends StatefulWidget {
  const PaginaCliente({Key? key}) : super(key: key);

  @override
  _PaginaClienteState createState() => _PaginaClienteState();
}

class _PaginaClienteState extends State<PaginaCliente> {
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


  Future<void> fetchClientes() async {
    try {

       DatabaseHelperUsuario dbHelperUsuario = DatabaseHelperUsuario();
    int? idVendedor = await dbHelperUsuario.getIdVendedor();
    
    if (idVendedor == null) {
      throw Exception('No se pudo obtener el id del vendedor');
    }

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
       ApiRoutes.buildUri('cliente/id-vendedor/$idVendedor'),
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
    body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Buscar',
                     prefixIcon: Icon(Icons.search),
                    prefixIconColor: Colors.blue,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  fetchClientes(); // Llama a la función para recargar los clientes
                },
              ),
            ],
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
                        );
                      },
                    ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 5,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CrearCliente())
                  ).then((_) {
                    fetchClientes(); // Refresh the list of clients when returning from the "CrearCliente" page
                  });
                },
                child: Row(
                  children: [
                    Icon(Icons.add, color: Colors.white),


                    ],
                  ),
                  
                ),
              ],
            ),
          ),
        ],
   
      ),
    );
  }
}