import 'package:flutter/material.dart';
import 'package:sync_pro_mobile/PantallasSecundarias/crear_cliente.dart';
import 'package:sync_pro_mobile/db/dbCliente.dart';
import 'package:sync_pro_mobile/Models/Cliente.dart';

class PaginaCliente extends StatefulWidget {
  const PaginaCliente({Key? key}) : super(key: key);

  @override
  _PaginaClienteState createState() => _PaginaClienteState();
}

class _PaginaClienteState extends State<PaginaCliente> {
  List<Cliente> _clientes = [];
  List<Cliente> _filteredClientes = [];
  bool _isLoading = true;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchClientes();
    _searchController.addListener(_filterClientes);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterClientes);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchClientes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      DatabaseHelperCliente databaseHelper = DatabaseHelperCliente();
      List<Cliente> clientes = await databaseHelper.getClientes();
      if (mounted) {
        setState(() {
          _clientes = clientes;
          _filteredClientes = clientes;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterClientes() {
    final query = _searchController.text.toLowerCase();
    if (mounted) {
      setState(() {
        _filteredClientes = _clientes.where((cliente) {
          return cliente.nombre.toLowerCase().contains(query) ||
                 cliente.cedula.toLowerCase().contains(query);
        }).toList();
      });
    }
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
                  _fetchClientes(); // Llama a la función para recargar los clientes
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
                    _fetchClientes(); // Refresh the list of clients when returning from the "CrearCliente" page
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
