import 'package:flutter/material.dart';
import 'package:sync_pro_mobile/db/dbConfiguraciones.dart';
import '../Models/Cliente.dart';
import '../Models/Ruta.dart';
import '../db/dbCliente.dart';
import '../db/dbRuta.dart';

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
  bool usarRuta = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _searchController.addListener(_onSearchChanged);
    _fetchConfiguracionYClientes();
  }

  @override
  void dispose() {
    _isMounted = false;
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchConfiguracionYClientes() async {
    try {
      usarRuta = await DatabaseHelperConfiguraciones().getUsaRuta();
      await fetchClientes();
    } catch (error) {
      print('Error al obtener configuración: $error');
      if (_isMounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> fetchClientes() async {
    try {
      if (usarRuta) {
        await retrieveClientesByRuta();
      } else {
        await retrieveAllClientes();
      }
    } catch (error) {
      print('Error al obtener clientes: $error');
      if (_isMounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> retrieveClientesByRuta() async {
    try {
      DatabaseHelperRuta databaseHelperRuta = DatabaseHelperRuta();
      Ruta? rutaActiva = await databaseHelperRuta.getRutaActiva();
      // ignore: unnecessary_null_comparison
      if (rutaActiva != null) {
     List<Cliente> clientes = await DatabaseHelperCliente().getClientesLocalidad(rutaActiva.idLocalidad);
        if (_isMounted) {
          setState(() {
            _clientes = clientes;
            _filteredClientes = clientes;
            _isLoading = false;
          });
        }
      } else {
        if (_isMounted) {
          setState(() {
            _clientes = [];
            _filteredClientes = [];
            _isLoading = false;
          });
        }
      }
    } catch (error) {
      print('Error al recuperar clientes de la base de datos local: $error');
      if (_isMounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> retrieveAllClientes() async {
    try {
      DatabaseHelperCliente databaseHelper = DatabaseHelperCliente();
      List<Cliente> clientes = await databaseHelper.getClientes();
      if (_isMounted) {
        setState(() {
          _clientes = clientes;
          _filteredClientes = clientes;
          _isLoading = false;
        });
      }
    } catch (error) {
      print('Error al recuperar clientes de la base de datos local: $error');
      if (_isMounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
