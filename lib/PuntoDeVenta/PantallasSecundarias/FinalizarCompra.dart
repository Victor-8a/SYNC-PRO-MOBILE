import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sync_pro_mobile/Pedidos/Models/Cliente.dart';
import 'package:sync_pro_mobile/Pedidos/Models/Vendedor.dart';
import 'package:sync_pro_mobile/Pedidos/Models/Producto.dart';
import 'package:sync_pro_mobile/PuntoDeVenta/Servicios/AperturaCajaActiva.dart';
import 'package:sync_pro_mobile/PuntoDeVenta/Servicios/FEL.dart';
import 'package:sync_pro_mobile/PuntoDeVenta/Servicios/MetodoPago.dart';
// import 'package:sync_pro_mobile/PuntoDeVenta/Servicios/UniCaja.dart';
import 'package:sync_pro_mobile/db/dbCarrito.dart';
import 'package:sync_pro_mobile/Pedidos/PantallasSecundarias/SeleccionarClientes.dart';

class FinalizarCompra extends StatefulWidget {
  const FinalizarCompra({Key? key, required Cliente selectedClient})
      : super(key: key);

  @override
  _FinalizarCompraState createState() => _FinalizarCompraState();
}

class _FinalizarCompraState extends State<FinalizarCompra> {
  Cliente _selectedClient = Cliente(
    codCliente: 0,
    nombre: 'CONSUMIDOR FINAL',
    cedula: '',
    direccion: 'CIUDAD',
    credito: false,
  );

  Color _buttonColor = Colors.blue;
  DateTime _selectedDate = DateTime.now();
  String _selectedPaymentType = 'Contado'; // Valor predeterminado
  bool _useFEL = false;
  final TextEditingController _nitController = TextEditingController();
  final DatabaseHelperCarrito _databaseHelper = DatabaseHelperCarrito();
  List<Map<String, dynamic>> _cartItems = [];
  double? _lastTotal;
  Future<double>?
      _totalFuture; // Variable para mantener el último valor del total

  @override
  void initState() {
    super.initState();

    _totalFuture = _getTotalCarrito();

    _loadCartFromDatabase();

    _nitController.addListener(() {
      setState(() {});
    });

    setState(() {
      _selectedClient = _selectedClient;
    });
  }

  Future<double> _getTotalCarrito() async {
    await Future.delayed(Duration(seconds: 2));
    return _databaseHelper.getTotalCarrito();
  }

  Future<void> _loadCartFromDatabase() async {
    final cartItems = await _databaseHelper.getCarritoItems();
    setState(() {
      _cartItems = cartItems;
    });
  }

  void _onClientChanged(Cliente newClient) {
    setState(() {
      _selectedClient =
          newClient; // Si el cliente no tiene crédito, forzamos el valor de _selectedPaymentType a "Contado"
      if (!_selectedClient.credito) {
        _selectedPaymentType = 'Contado'; // Aseguramos un valor válido
      } else if (_selectedPaymentType == 'Crédito') {
        _selectedPaymentType =
            'Contado'; // Cambiar a Contado si estaba en Crédito
      }
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
            _buildFixedSection(),
            Divider(thickness: 2),
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
                                'Cantidad: ${_cartItems[index]['Cantidad']} - Precio: Q${_cartItems[index]['Precio']} '),
                          ),
                        );
                      },
                    ),
            ),
            Divider(thickness: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTotalSection(),
                SizedBox(width: 30),
                _selectedPaymentType == 'Contado'
                    ? ElevatedButton(
                        onPressed: () async {
                          double total =
                              await DatabaseHelperCarrito().getTotalCarrito();
                          showPaymentOptionsModal(
                            context,
                            total,
                            (String selectedPaymentMethod) {
                              print(
                                  'Método de pago seleccionado: $selectedPaymentMethod');
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.blue, // Cambiar el color de fondo a azul
                          iconColor: Colors
                              .white, // Cambiar el color del icono (opcional)
                        ),
                        child: Text(
                          'Método de Pago',
                          style: TextStyle(
                            color: Colors
                                .white, // Asegúrate de que el texto sea legible
                          ),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () {
                          print('Registrando la venta a crédito...');
                          _registerSale(); // Aquí puedes implementar la función que realiza el registro de la venta.
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Colors.green, // Cambiar el color de fondo a verde
                          iconColor: Colors
                              .white, // Cambiar el color del icono (opcional)
                        ),
                        child: Text(
                          'Registrar Venta',
                          style: TextStyle(
                            color: Colors
                                .white, // Asegúrate de que el texto sea legible
                          ),
                        ),
                      ),
              ],
            ),
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
                _selectedClient.nombre.isNotEmpty
                    ? 'Cliente: ' + _selectedClient.nombre
                    : 'Cliente: CONSUMIDOR FINAL',
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
              items: _selectedClient.credito
                  ? <String>['Contado', 'Crédito']
                      .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList()
                  : <String>['Contado']
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: CheckboxListTile(
                title: Column(
                  children: [
                    if (_nitController.text.isNotEmpty)
                      Text(
                        "NIT: ${_nitController.text}",
                        style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
                value: _useFEL,
                onChanged: (bool? value) {
                  setState(() {
                    _useFEL = value!;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_useFEL) {
                  showFELDialog(context, _nitController, _selectedClient)
                      .then((clienteResponse) {
                    if (clienteResponse != null) {
                      _onClientChanged(clienteResponse);
                    }
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content:
                        Text('Debes habilitar el acceso a FEL para continuar.'),
                  ));
                }
              },
              child: Text('Datos FEL'),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildTotalSection() {
    return FutureBuilder<double>(
      future: _totalFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            _lastTotal != null) {
          return Text(
            'Total: Q${_lastTotal!.toStringAsFixed(2)} (Actualizando...)', // Muestra el valor previo con un texto indicativo
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          double total = snapshot.data!;
          return Text(
            'Total: Q${total.toStringAsFixed(2)}', // Actualiza el valor cuando llega el nuevo total
            style: TextStyle(
              fontSize: 15,
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
        _onClientChanged(selectedClient); // Actualizar cliente aquí
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

  void _registerSale() {
    print("Venta registrada con éxito.");
    // fetchUniCaja();
    getAperturaCajaActiva();
  }
}
