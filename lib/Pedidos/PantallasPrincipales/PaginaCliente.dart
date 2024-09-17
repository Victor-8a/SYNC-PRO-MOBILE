import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:sync_pro_mobile/Pedidos/PantallasSecundarias/CrearCliente.dart';
import 'package:sync_pro_mobile/Pedidos/Models/Cliente.dart';
import 'package:sync_pro_mobile/Pedidos/PantallasSecundarias/PaginaPedidos.dart';
import 'package:sync_pro_mobile/db/dbCliente.dart';
import 'package:sync_pro_mobile/db/dbConfiguraciones.dart';
import 'package:sync_pro_mobile/db/dbRuta.dart';
import 'package:sync_pro_mobile/db/dbUsuario.dart';
import 'package:sync_pro_mobile/Pedidos/services/ApiRoutes.dart';
import 'package:sync_pro_mobile/Pedidos/services/LocalidadService.dart';

class PaginaCliente extends StatefulWidget {
  const PaginaCliente({Key? key}) : super(key: key);

  @override
  _PaginaClienteState createState() => _PaginaClienteState();
}

class _PaginaClienteState extends State<PaginaCliente> {
  List<Cliente> _clientes = [];
  List<Cliente> _filteredClientes = [];
  TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  bool _isMounted = false;
  // ignore: unused_field
  bool _localidadCargada =
      false; // Variable para verificar si la localidad está cargada

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _searchController.addListener(_onSearchChanged);
    retrieveClientesFromLocalDatabase();
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

Future<void> fetchClientes() async {
  // Verificar si hay una ruta iniciada
  int rutaIniciada = await DatabaseHelperRuta().isRutaIniciada();
  
  if (rutaIniciada > 0) {
    print('No se puede completar el método. Hay una ruta iniciada.');

       Fluttertoast.showToast(
                    msg: "No se puede cargar los clientes. Hay una ruta iniciada.",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                  );

    return; // Salir del método si hay una ruta iniciada
  }

  setState(() {
    _isLoading = true; // Mostrar el indicador de carga
  });

  try {
    DatabaseHelperUsuario dbHelperUsuario = DatabaseHelperUsuario();
    int? idVendedor = await dbHelperUsuario.getIdVendedor();

    if (idVendedor == null) {
      throw Exception('No se pudo obtener el id del vendedor');
    }

    bool clientesFiltrados =
        await DatabaseHelperConfiguraciones().getClientesFiltrados();

    Uri url;
    if (clientesFiltrados) {
      url = ApiRoutes.buildUri('cliente/id-vendedor/$idVendedor');
    } else {
      url = ApiRoutes.buildUri('cliente');
    }

    var connectivityResult = await Connectivity()
        .checkConnectivity()
        .timeout(Duration(seconds: 5));

    if (connectivityResult == ConnectivityResult.none) {
      print(
          'No hay conexión a Internet, recuperando clientes de la base de datos local');
      return await retrieveClientesFromLocalDatabase();
    }

    await fetchRuta();

    String? token = await login();
    if (token == null) {
      throw Exception('No se encontró el token');
    }

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    ).timeout(Duration(seconds: 5));

    if (response.statusCode == 200) {
      DatabaseHelperCliente().deleteAllClientes();
      print('Se elimino correctamente');
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
    setState(() {
      _isLoading = true;
    });
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
        title: const Text('Clientes',
            style: TextStyle(
              color: Colors.white,
            )),
        backgroundColor: Colors.blue,
      ),
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
                        MaterialPageRoute(
                            builder: (context) => CrearCliente())).then((_) {
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