import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sync_pro_mobile/Pedidos/Models/Cliente.dart';
import 'package:sync_pro_mobile/Pedidos/Models/Ruta.dart';
import 'package:sync_pro_mobile/Pedidos/PantallasSecundarias/SeleccionarProducto.dart';
import 'package:sync_pro_mobile/Pedidos/services/GuardarDetallePedidos.dart';
import 'package:sync_pro_mobile/Pedidos/services/GuardarPedido.dart';
import 'package:sync_pro_mobile/db/dbConfiguraciones.dart';
import 'package:sync_pro_mobile/db/dbProducto.dart';
import 'package:sync_pro_mobile/db/dbRangoPrecioProducto.dart';
import 'package:sync_pro_mobile/db/dbVendedores.dart';
import 'package:sync_pro_mobile/Pedidos/PantallasSecundarias/SeleccionarClientes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sync_pro_mobile/main.dart';
import '../Models/Producto.dart';
import '../Models/Vendedor.dart';
import '../../db/dbDetalleRuta.dart' as dbDetalleRuta;
import '../../db/dbRuta.dart';

class PaginaPedidos extends StatefulWidget {
  final Cliente cliente;
  const PaginaPedidos({Key? key, required this.cliente}) : super(key: key);

  @override
  _PaginaPedidosState createState() => _PaginaPedidosState();
}

class _PaginaPedidosState extends State<PaginaPedidos> {
  final DatabaseHelperConfiguraciones dbHelper =
      DatabaseHelperConfiguraciones();
  final DatabaseHelperRuta dbHelperRuta = DatabaseHelperRuta();

  bool usarRuta = false;
  Ruta? miRuta;
  void _loadSelectedClientName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? selectedClientJson = prefs.getStringList('selectedClient');
    if (selectedClientJson != null) {
      Map<String, String> clientData = {};
      selectedClientJson.forEach((item) {
        var parts = item.split(': ');
        if (parts.length == 2) {
          clientData[parts[0]] = parts[1];
        }
      });
      _selectedClient = Cliente(
          codCliente: int.parse(clientData['codCliente']!),
          nombre: clientData['nombre']!,
          cedula: clientData['cedula']!,
          direccion: clientData['direccion']!);
    }
  }

  Vendedor vendedor = Vendedor(value: 1, nombre: 'Vendedor 1');
  int? _selectedSalespersonId; // ID del vendedor seleccionado
  // ignore: unused_field
  List<Vendedor> _vendedores = [];
  Cliente _selectedClient =
      Cliente(codCliente: 0, nombre: '', cedula: '', direccion: '');
  DateTime _selectedDate = DateTime.now();
  List<Product> _selectedProducts = [];
  Map<Product, int> _selectedProductQuantities = {};

  Map<Product, double> _discounts =
      {}; // Mapa que guarda el descuento asociado con cada producto
  Map<Product, double> _selectedProductPrices = {};
  String _observations = '';
  Color _buttonColor = Colors.blue; // Color para los botones
  double _calculateTotal() {
    double total = 0;
    for (var product in _selectedProducts) {
      int quantity = _selectedProductQuantities[product]!;
      double unitPrice = _selectedProductPrices[product] ?? product.precioFinal;
      total += unitPrice * quantity;
    }
    return total;
  }

  Map<Product, TextEditingController> _quantityControllers = {};
  Map<Product, TextEditingController> _discountControllers = {};

  double _calculateTotalWithDiscount() {
    double total = 0.0;
    _selectedProducts.forEach((product) {
      int quantity = _selectedProductQuantities[product] ?? 0;
      double unitPrice = _selectedProductPrices[product] ?? product.precioFinal;
      double discount = _discounts[product] ?? 0;
      double subtotal = unitPrice * quantity * (1 - (discount / 100));

      total += subtotal;
    });
    return total;
  }

  @override
  void initState() {
    super.initState();
    _selectedClient = widget.cliente;
    loadSalesperson().then((vendedor) {
      if (mounted) {
        setState(() {
          vendedor = vendedor;
        });
      }
    }).catchError((error) {});
    if (widget.cliente.codCliente == 0) _loadSelectedClientName();

    _selectedProducts.forEach((product) {
      _selectedProductPrices[product] = product.precioFinal;
    }); // Agregar esta línea para cargar los productos seleccionados guardados
    _fetchAndLoadVendedores();
  }

  Future<void> _fetchAndLoadVendedores() async {
    bool fetchSuccess = await _tryFetchAndStoreVendedores();

    // If fetching from server fails, load from local database
    if (!fetchSuccess) {
      print('Failed to fetch from server, loading from local database');
      final vendedores = await DatabaseHelperVendedor().getVendedores();

      if (mounted) {
        setState(() {
          _vendedores = vendedores;
        });
      }
    } else {
      fetchVendedores();
    }
  }

  Future<bool> _tryFetchAndStoreVendedores() async {
    try {
      return await DatabaseHelperVendedor().fetchAndStoreVendedores();
    } catch (e) {
      print('Error fetching and storing vendedores: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          bool confirm = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('¿Está seguro?'),
              content:
                  Text('Puede perder los datos de su pedido si retrocede.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // Envía true si confirma
                  },
                  child: Text('Sí'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('No'),
                ),
              ],
            ),
          );

          return confirm;
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text(
                'Pedidos',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.blue,
            ),
            body: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FutureBuilder<Vendedor>(
                      future: loadSalesperson(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return SizedBox(
                              height:
                                  1); // Si hay un error, no se muestra nada.
                        } else if (snapshot.hasData && snapshot.data != null) {
                          Vendedor _selectedSalesperson = snapshot.data!;
                          _selectedSalespersonId = _selectedSalesperson.value;
                          return Column(
                            children: [
                              Text(
                                'Vendedor: ${_selectedSalesperson.nombre}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          );
                        } else {
                          return SizedBox(height: 1); // Espacio mínimo.
                        }
                      },
                    ),
                    SizedBox(height: 20.0),
                    Column(
                      children: [
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
                        SizedBox(height: 10.0),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons
                              .calendar_today, // Aquí puedes cambiar el icono por el que desees
                          color: Colors.blue, // Color del icono
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          'Fecha de Entrega: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 8.0),
                        InkWell(
                          onTap: () {
                            _selectDate(context);
                          },
                          child: Text(
                            '${_selectedDate.year}/${_selectedDate.month}/${_selectedDate.day}',
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () {
                        navigateToSeleccionarProducto(context);
                      },
                      child: Text(
                        'Seleccionar Producto',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _buttonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        'Productos seleccionados:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _selectedProducts.reversed.map((product) {
                        double unitPrice = _selectedProductPrices[product] ??
                            product.precioFinal;
                        int quantity = _selectedProductQuantities[product] ?? 0;
                        double discount = _discounts[product] ?? 0;
                        if (!_quantityControllers.containsKey(product)) {
                          _quantityControllers[product] =
                              TextEditingController(text: quantity.toString());
                        }
                        if (!_discountControllers.containsKey(product)) {
                          _discountControllers[product] =
                              TextEditingController(text: discount.toString());
                        }
                        double subtotalBeforeDiscount = unitPrice * quantity;
                        double discountAmount =
                            subtotalBeforeDiscount * (discount / 100);
                        double subtotal =
                            subtotalBeforeDiscount - discountAmount;
                        List<double> availablePrices = [
                          product.precioFinal,
                          product.precioB,
                          product.precioC,
                          product.precioD,
                        ].where((price) => price > 0).toList();

                        return Container(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          decoration: BoxDecoration(
                            border:
                                Border(bottom: BorderSide(color: Colors.grey)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                title: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${product.descripcion}',
                                        overflow: TextOverflow.clip,
                                      ),
                                    ),
                                    DropdownButton<double>(
                                      value: availablePrices.contains(unitPrice)
                                          ? unitPrice
                                          : product.precioFinal,
                                      items:
                                          availablePrices.toSet().map((price) {
                                        return DropdownMenuItem(
                                          value: price,
                                          child: Text(
                                              'Q${price.toStringAsFixed(2)}'),
                                        );
                                      }).toList(),
                                      onChanged: (newPrice) async {
                                        int? cantidad =
                                            _selectedProductQuantities[product];

                                        if (cantidad != null) {
                                          double newUnitPrice =
                                              await getRangosByProducto(
                                                  product.codigo,
                                                  cantidad,
                                                  product.precioFinal);

                                          if (newUnitPrice != 0) {
                                            _showConfirmQuantityRangeDialog(
                                                context, cantidad);
                                            unitPrice = newUnitPrice;
                                          }
                                        }
                                        setState(() {
                                          _selectedProductPrices[product] =
                                              newPrice!;
                                          subtotalBeforeDiscount =
                                              unitPrice * quantity;
                                          discountAmount =
                                              subtotalBeforeDiscount *
                                                  (discount / 100);
                                          subtotal = subtotalBeforeDiscount -
                                              discountAmount;
                                        });
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.close_sharp,
                                          color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          _selectedProducts.remove(product);
                                          _selectedProductPrices
                                              .remove(product);
                                          _selectedProductQuantities
                                              .remove(product);
                                          _discounts.remove(product);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 16.0),
                                      child: TextField(
                                        key: Key(
                                            'quantity_${product.codigo}'), // Asignar una clave única
                                        controller:
                                            _quantityControllers[product],
                                        keyboardType: TextInputType.number,
                                        onChanged: (newValue) async {
                                          int newQuantity = int.tryParse(
                                                  newValue == ''
                                                      ? '1'
                                                      : newValue) ??
                                              1;
                                          if (newQuantity > 0) {
                                            double newUnitPrice =
                                                await getRangosByProducto(
                                                    product.codigo,
                                                    newQuantity,
                                                    product.precioFinal);

                                            setState(() {
                                              _selectedProductQuantities[
                                                  product] = newQuantity;
                                              if (newUnitPrice != 0) {
                                                _selectedProductPrices[
                                                    product] = newUnitPrice;
                                                unitPrice = newUnitPrice;
                                              }
                                              subtotalBeforeDiscount =
                                                  unitPrice * newQuantity;
                                              discountAmount =
                                                  subtotalBeforeDiscount *
                                                      (discount / 100);
                                              subtotal =
                                                  subtotalBeforeDiscount -
                                                      discountAmount;
                                            });
                                          }
                                        },
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 10),
                                          hintText: '1',
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: TextField(
                                        key: Key(
                                            'discount_${product.codigo}'), // Asignar una clave única
                                        controller:
                                            _discountControllers[product],
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^\d{1,2}$')),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            _discounts[product] =
                                                double.tryParse(value) ?? 0;
                                            discount = _discounts[product]!;
                                            subtotalBeforeDiscount =
                                                unitPrice * quantity;
                                            discountAmount =
                                                subtotalBeforeDiscount *
                                                    (discount / 100);
                                            subtotal = subtotalBeforeDiscount -
                                                discountAmount;
                                          });
                                        },
                                        decoration: InputDecoration(
                                          labelText: '% Desc',
                                          floatingLabelStyle:
                                              TextStyle(color: Colors.blue),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                              vertical: 5.0, horizontal: 10.0),
                                          isDense: true,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 16.0),
                                  Text('Q${subtotal.toStringAsFixed(2)}'),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20.0),
                    TextField(
                      onChanged: (value) {
                        _observations = value;
                      },
                      decoration: InputDecoration(
                        suffixText: 'Opcional',
                        labelText: 'Observaciones',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Subtotal: \Q${(_calculateTotal()).toStringAsFixed(2)}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15.0),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      'Descuento: \Q${(_calculateTotal() - _calculateTotalWithDiscount()).toStringAsFixed(2)}', // Diferencia entre el subtotal y el total con descuento
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15.0),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      'Total: \Q${(_calculateTotalWithDiscount()).toStringAsFixed(2)}', // Precio total con descuento
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18.0),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 10.0,
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          // ignore: unnecessary_null_comparison
                          if (_selectedClient == null ||
                              _selectedSalespersonId == null ||
                              // ignore: unnecessary_null_comparison
                              _selectedDate == null ||
                              _selectedProducts.isEmpty) {
                            // Mostrar mensaje de error si falta algún campo obligatorio
                            Fluttertoast.showToast(
                              msg:
                                  'Por favor complete todos los campos obligatorios.',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                            return; // Detener la ejecución del método
                          }
                          bool confirm = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('¿Está seguro?'),
                              content: Text('¿Desea agregar el pedido?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                  child: Text('Sí'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  child: Text('No'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            int? idPedido = await saveOrder(
                              _selectedClient.codCliente,
                              _observations,
                              _selectedSalespersonId ?? 0,
                              _selectedDate,
                            );

                            if (idPedido != null) {
                              saveOrderDetail(
                                idPedido,
                                _selectedProducts,
                                _selectedProductQuantities,
                                _selectedProductPrices,
                                _discounts,
                              );

                              Fluttertoast.showToast(
                                msg: 'Pedido guardado exitosamente.',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.blue,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                              bool usaConfigRuta = await dbHelper.getUsaRuta();
                              if (usaConfigRuta)
                                miRuta = await dbHelperRuta.getRutaActiva();
                              if (usaConfigRuta && miRuta != null)
                                await dbDetalleRuta.DatabaseHelperDetalleRuta()
                                    .updateIdPedidoDetalleRuta(
                                        _selectedClient.codCliente,
                                        idPedido,
                                        miRuta!.id);
                              _resetState();
                            } else {
                              Fluttertoast.showToast(
                                msg: 'Error al guardar el pedido.',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            }
                          }
                        },
                        child: Text(
                          'Agregar Pedido',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _buttonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          minimumSize: Size(double.infinity, 50),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10.0, // Agrega espacio entre los botones
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          bool confirm = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('¿Está seguro?'),
                              content: Text('¿Desea cancelar el pedido?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop(
                                        true); // Cerrar el cuadro de diálogo y devolver true
                                  },
                                  child: Text('Sí'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(
                                      false), // Cerrar el cuadro de diálogo y devolver false
                                  child: Text('No'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            _resetState();
                            _resetInfo();
                          }
                        },
                        child: Text(
                          'Cancelar Pedido',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          minimumSize: Size(double.infinity, 50),
                          fixedSize: Size(100, 50),
                        ),
                      ),
                    ),
                  ],
                ))));
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> fetchVendedores() async {
    final vendedores = await DatabaseHelperVendedor().getVendedores();
    setState(() {
      _vendedores = vendedores;
    });
  }

  void _navigateToSeleccionarCliente(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SeleccionarCliente(clientes: [])),
    ).then((selectedClient) {
      if (selectedClient != null) {
        _saveSelectedClient(
            selectedClient); // Guardar el nombre del cliente seleccionado
        setState(() {
          _selectedClient =
              selectedClient; // Actualizar el nombre del cliente seleccionado
        });
      }
    });
  }

  Future<void> _saveSelectedClient(Cliente cliente) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> clientData = cliente.toJson();
    List<String> selectedClientJson = clientData.entries.map((entry) {
      return '${entry.key}: ${entry.value.toString()}';
    }).toList();
    await prefs.setStringList('selectedClient',
        selectedClientJson); // Guardar el nombre del cliente en SharedPreferences
  }

  void navigateToSeleccionarProducto(BuildContext context) async {
    try {
      List<Product> products = [];
      DatabaseHelperProducto dbHelper = DatabaseHelperProducto();
      List<Product> productsFromDB = await dbHelper.getProducts();
      if (productsFromDB.isNotEmpty) {
        products = productsFromDB;
      } else {
        Fluttertoast.showToast(
            msg: 'No se encontraron productos, cargue su inventarioio primero.',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.yellow,
            textColor: Colors.black,
            fontSize: 16.0);

        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SeleccionarProducto(productos: products),
        ),
      ).then((selectedProduct) {
        if (selectedProduct != null) {
          setState(() {
            _selectedProducts.add(selectedProduct);
            if (_selectedProductQuantities.containsKey(selectedProduct)) {
              _selectedProductQuantities[selectedProduct] =
                  _selectedProductQuantities[selectedProduct]! + 1;
            } else {
              _selectedProductQuantities[selectedProduct] = 1;
            }
          });
        }
      });
    } catch (error) {
      print('Error al cargar los productos: $error');
    }
  }

  void _resetState() {
    if (mounted)
      setState(() {
        _selectedClient = Cliente(
            codCliente: 0,
            nombre: 'CONSUMIDOR FINAL ',
            cedula: 'CF',
            direccion: 'CIUDAD');
        _selectedSalespersonId = null;
        _selectedDate = DateTime.now();
        _selectedProducts = [];
        _selectedProductQuantities = {};
      });
    _resetInfo();
  }

  void _resetInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _saveSelectedClient(Cliente(
        codCliente: 0,
        nombre: 'CONSUMIDOR FINAL ',
        cedula: 'CF',
        direccion: 'CIUDAD'));
    await prefs.remove('selectedProducts');
    List<String>? selectedProductsJson = [];
    await prefs.setStringList('selectedProducts', selectedProductsJson);
  }

  Future<double> getRangosByProducto(
      int codigo, int quantity, double precioFinal) async {
    DatabaseHelperRangoPrecioProducto dbHelper =
        DatabaseHelperRangoPrecioProducto();
    final rangoPrecioProducto = await dbHelper.getPrecioByProductoYCantidad(
        codigo, quantity, precioFinal);

    return rangoPrecioProducto;
  }
}

// Método para mostrar el diálogo de confirmación
Future<void> _showConfirmQuantityRangeDialog(
    BuildContext context, int quantity) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // Evita cerrar el diálogo tocando fuera de él
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirmar Selección'),
        content: Text(
            'La cantidad $quantity está dentro del rango específico. ¿Estás seguro de que deseas cambiar el precio?'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancelar'),
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el diálogo sin hacer nada
            },
          ),
          TextButton(
            child: Text('Confirmar'),
            onPressed: () {
              Navigator.of(context)
                  .pop(); // Cierra el diálogo y confirma el cambio
            },
          ),
        ],
      );
    },
  );
}
