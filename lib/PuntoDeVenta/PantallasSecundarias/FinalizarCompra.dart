import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sync_pro_mobile/Pedidos/Models/Cliente.dart';
import 'package:sync_pro_mobile/Pedidos/Models/Vendedor.dart';
import 'package:sync_pro_mobile/Pedidos/Models/Producto.dart';
import 'package:sync_pro_mobile/db/dbCarrito.dart';
import 'package:sync_pro_mobile/Pedidos/PantallasSecundarias/SeleccionarClientes.dart';

class FinalizarCompra extends StatefulWidget {
  const FinalizarCompra({Key? key}) : super(key: key);

  @override
  _FinalizarCompraState createState() => _FinalizarCompraState();
}

class _FinalizarCompraState extends State<FinalizarCompra> {
  Cliente _selectedClient =
      Cliente(codCliente: 0, nombre: '', cedula: '', direccion: '');
  Color _buttonColor = Colors.blue;
  DateTime _selectedDate = DateTime.now();
  String _selectedPaymentType = 'Contado';
  bool _useFEL = false;
  final TextEditingController _nitController = TextEditingController();
  final TextEditingController _felNameController = TextEditingController();
  final TextEditingController _felAddressController = TextEditingController();
  final DatabaseHelperCarrito _databaseHelper = DatabaseHelperCarrito();
  List<Map<String, dynamic>> _cartItems = [];

  @override
  void initState() {
    super.initState();
    _loadCartFromDatabase();
  }

  Future<void> _loadCartFromDatabase() async {
    final cartItems = await _databaseHelper.getCarritoItems();
    setState(() {
      _cartItems = cartItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              Text('Finalizar Compra', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blue),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Sección fija
            _buildFixedSection(),

            // Separador
            Divider(thickness: 2),

            // Sección desplazable
            Expanded(
              child: _cartItems.isEmpty
                  ? Center(child: Text("No hay productos en el carrito."))
                  : ListView.builder(
                      itemCount: _cartItems.length,
                      itemBuilder: (context, index) {
                        final product = Product.fromMap(_cartItems[index]);
                        return Card(
                          elevation: 4,
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            title: Text(product.descripcion),
                            subtitle: Text(
                                'Cantidad: ${_cartItems[index]['Cantidad']} - Precio: Q${product.precioFinal.toStringAsFixed(2)}'),
                          ),
                        );
                      },
                    ),
            ),
            _buildTotalSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<Vendedor>(
          future: loadSalesperson(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return SizedBox(height: 1);
            } else if (snapshot.hasData && snapshot.data != null) {
              Vendedor _selectedSalesperson = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fecha: ${_selectedDate.toString().substring(0, 10)}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'Vendedor: ${_selectedSalesperson.nombre}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              );
            } else {
              return SizedBox(height: 1);
            }
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Cliente: ' + _selectedClient.nombre,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              onPressed: () {
                _navigateToSeleccionarCliente(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _buttonColor,
              ),
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Tipo de Pago: ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 10),
            DropdownButton<String>(
              value: _selectedPaymentType,
              items: <String>['Contado', 'Crédito']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPaymentType = newValue!;
                });
              },
            ),
          ],
        ),
        CheckboxListTile(
          title: Row(
            children: [
              Text("FEL"),
              SizedBox(width: 10),
              if (_nitController.text.isNotEmpty)
                Text(
                  "NIT: ${_nitController.text}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
            ],
          ),
          value: _useFEL,
          onChanged: (bool? value) {
            _useFEL = value!;
            if (_useFEL = true) {
              setState(() {
                _showFELDialog(value);
              });
            }
          },
          controlAffinity: ListTileControlAffinity.leading,
        ),
      ],
    );
  }

  Widget _buildTotalSection() {
    return FutureBuilder<double>(
      future: _databaseHelper.getTotalCarrito(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          double total = snapshot.data!;
          return Text(
            'Total: Q${total.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          );
        } else {
          return Text('Carrito vacío');
        }
      },
    );
  }

  void _navigateToSeleccionarCliente(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SeleccionarCliente(clientes: [])),
    ).then((selectedClient) {
      if (selectedClient != null) {
        _saveSelectedClient(selectedClient);
        setState(() {
          _selectedClient = selectedClient;
        });
      }
    });
  }

  Future<Vendedor> loadSalesperson() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idVendedor = prefs.getString('idVendedor');
    String? vendedorName = prefs.getString('vendedorName');
    return Vendedor(value: int.parse(idVendedor!), nombre: vendedorName!);
  }

  Future<void> _saveSelectedClient(Cliente cliente) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> clientData = cliente.toJson();
    List<String> selectedClientJson = clientData.entries.map((entry) {
      return '${entry.key}: ${entry.value.toString()}';
    }).toList();
    await prefs.setStringList('selectedClient', selectedClientJson);
  }

  void _showFELDialog(bool) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Datos FEL'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nitController,
                decoration: InputDecoration(
                  labelText: 'NIT',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _felNameController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _felAddressController,
                decoration: InputDecoration(
                  labelText: 'Dirección',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                // Guardar datos FEL (si es necesario)
                Navigator.of(context).pop();
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}
