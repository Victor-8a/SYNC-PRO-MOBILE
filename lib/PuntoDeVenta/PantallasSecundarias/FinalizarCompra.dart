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
  // ignore: unused_field
  int? _selectedSalespersonId;
  DateTime _selectedDate = DateTime.now();

  // Variables para el Dropdown
  String _selectedPaymentType = 'Contado';

  // Variables para FEL
  bool _useFEL = false;
  final TextEditingController _nitController = TextEditingController();
  final TextEditingController _felNameController = TextEditingController();
  final TextEditingController _felAddressController = TextEditingController();

  // Controlador de base de datos
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
        title: Text('Finalizar Compra'),
      ),
      
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              FutureBuilder<Vendedor>(
                future: loadSalesperson(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return SizedBox(height: 1);
                  } else if (snapshot.hasData && snapshot.data != null) {
                    Vendedor _selectedSalesperson = snapshot.data!;
                    _selectedSalespersonId = _selectedSalesperson.value;
                    return Column(
                      children: [
                        Text(
                          'Fecha: ${_selectedDate.toString().substring(0, 10)}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          'Vendedor: ${_selectedSalesperson.nombre}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    );
                  } else {
                    return SizedBox(height: 1);
                  }
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Cliente: ' + _selectedClient.nombre,
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  _navigateToSeleccionarCliente(context);
                },
                child: Text(
                  'Seleccionar Cliente',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _buttonColor,
                ),
              ),
              SizedBox(height: 10.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
              ),
              CheckboxListTile(
                title: Text("FEL"),
                value: _useFEL,
                onChanged: (bool? value) {
                  setState(() {
                    _useFEL = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              if (_useFEL) ...[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _nitController,
                    decoration: InputDecoration(
                      labelText: 'NIT',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _felNameController,
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _felAddressController,
                    decoration: InputDecoration(
                      labelText: 'Dirección',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
              SizedBox(height: 20.0),
              Text(
                'Venta',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              _cartItems.isEmpty
                  ? Text("No hay productos en el carrito.")
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _cartItems.length,
                      itemBuilder: (context, index) {
                        final product = Product.fromMap(_cartItems[index]);
                        return ListTile(
                          title: Text(product.descripcion),
                          subtitle: Text(
                              'Cantidad: ${_cartItems[index]['Cantidad']} - Precio: Q${product.precioFinal.toStringAsFixed(2)}'),
                        );
                      },
                    ),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: FutureBuilder<double>(
                        future: DatabaseHelperCarrito().getTotalCarrito(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: SizedBox());
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (snapshot.hasData) {
                            double total = snapshot.data!.toDouble();
                            return Wrap(
                              direction: Axis.vertical,
                              children: [
                                Text(
                                  'Total: Q${total.toStringAsFixed(2)}',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue),
                                ),
                              ],
                            );
                          } else {
                            return Text('Carrito vacío');
                          }
                        },
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
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
}
