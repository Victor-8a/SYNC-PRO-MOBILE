import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:sync_pro_mobile/Models/Cliente.dart';
import 'package:sync_pro_mobile/seleccionar_clientes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'Models/Producto.dart';
import 'Models/Vendedor.dart';
import 'crear_cliente.dart';
import 'services/local_storage.dart';

void saveSalesperson(Vendedor salesperson) async {
  String salespersonJson = jsonEncode(salesperson.toJson());
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('salesperson', salespersonJson);
}

LocalStorage localStorage = LocalStorage();
Future<String> getTokenFromStorage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString('token') ??
      ""; // Si el token no existe, devuelve una cadena vacía
  return token;
}

Future<String> getIdFromStorage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userId = prefs.getString('userId') ??
      ""; // Si el id no existe, devuelve una cadena vacía
  return userId;
}

Future<Vendedor?> getSalesperson() async {
  String? salespersonJson = await LocalStorage.getString('salesperson');
  if (salespersonJson != null) {
    return Vendedor.fromJson(jsonDecode(salespersonJson));
  } else {
    return null;
  }
}

// Función para guardar el pedido en la base de datos
Future<int?> saveOrder(int selectedClient, String observations,
    int _selectedSalespersonId, DateTime selectedDate) async {
  try {
    String? token = await getTokenFromStorage();
    String userId = await getIdFromStorage();
    // ignore: unnecessary_null_comparison
    if (token == null) {
      print('return null pedido...');
      return null;
    }

    print('INGRESO A SAVEORDER...');
    var url = Uri.parse('http://192.168.1.212:3000/pedidos/save');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    print('Guardando pedido...');

    var dataPedido = {
      "CodCliente": selectedClient,
      "Fecha": DateTime.now().toIso8601String(),
      "Observaciones": observations,
      "IdUsuario": userId,
      "FechaEntrega": selectedDate.toIso8601String(),
      "CodMoneda": 1,
      "TipoCambio": 1,
      "Anulado": false,
      "idVendedor": _selectedSalespersonId,
    };
    var body = jsonEncode(dataPedido);
    print('Guardando pedido: $body');
    var response = await http.post(url, headers: headers, body: body);
    print(
        'Server responded with status code ${response.statusCode} and body: ${response.body}');
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      int idPedido = jsonResponse['savedOrder']['id'];
      return idPedido;
    } else {
      print(
          'Server responded with status code ${response.statusCode} and body: ${response.body}');
      throw Exception('Failed to save order: ${response.statusCode}');
    }
  } catch (error) {
    return null;
  }
}

Future<void> saveOrderDetail(
  int idPedido,
  List<Product> selectedProducts,
  Map<Product, int> selectedProductQuantities,
  Map<Product, double> _selectedProductPrices,
  Map<Product, double> _discounts,
) async {
  try {
    String? token = await getTokenFromStorage();
    if (token == false) {
      throw Exception('Token de autorización no válido');
    }

    var url = Uri.parse('http://192.168.1.212:3000/detalle_pedidos/save');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    for (var product in selectedProducts) {
      var orderDetailData = {
        "IdPedido": idPedido,
        "CodArticulo": product.codigo,
        "Descripcion": product.descripcion,
        "Cantidad": selectedProductQuantities[product],
        "PrecioVenta": _selectedProductPrices[product] ?? product.precioFinal,
        "PorcDescuento": _discounts[product],
        "Total": ((_selectedProductPrices[product] ?? product.precioFinal) *
                selectedProductQuantities[product]!) -
            (selectedProductQuantities[product]! *
                    (_selectedProductPrices[product] ?? product.precioFinal)) *
                (_discounts[product]! / 100)
      };
      var body = jsonEncode(orderDetailData);
      print(jsonEncode(orderDetailData));

      var response = await http.post(url, headers: headers, body: body);

      if (response.statusCode != 200) {
        throw Exception('Failed to save order detail: ${response.statusCode}');
      }
    }
  } catch (error) {
    print('Hubo un error al guardar los detalles del pedido: $error');
  }
}

//aqui inicia el widget
class SeleccionarProducto extends StatefulWidget {
  final List<Product> productos;

  SeleccionarProducto({Key? key, required this.productos}) : super(key: key);

  @override
  _SeleccionarProductoState createState() => _SeleccionarProductoState();
}

class _SeleccionarProductoState extends State<SeleccionarProducto> {
  List<Product> _selectedProducts =
      []; // Inicializa la lista de productos seleccionados
  Map<Product, double> _selectedProductPrices = {};
  Map<Product, int> _selectedProductQuantities = {};
  Map<Product, double> _discounts = {};
  List<Product> _filteredProducts = [];
  List<bool> _productSelected = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _productSelected = List<bool>.filled(widget.productos.length, false);
    _filteredProducts = List.from(widget.productos);
    _searchController.addListener(_onSearchChanged);

    // Inicializar _selectedProductPrices, _selectedProductQuantities y _discounts por defecto
    for (var product in _selectedProducts) {
      _selectedProductPrices[product] = product.precioFinal;
      _selectedProductQuantities[product] =
          1; // Inicializa las cantidades a 1 si es necesario
      _discounts[product] = 0; // Inicializa los descuentos a 0 si es necesario
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    String searchTerm = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = widget.productos.where((product) {
        return product.descripcion.toLowerCase().contains(searchTerm);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Productos',
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
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                labelText: 'Buscar producto',
                prefixIcon: Icon(Icons.search),
                prefixIconColor: Colors.blue,
              ),
              cursorColor: Colors.blue,
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                color: Colors.blue.withOpacity(0),
              ),
              child: ListView.builder(
                itemCount: _filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = _filteredProducts[index];
                  return ListTile(
                    title: Text(
                      product.descripcion,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Precio: Q${product.precioFinal.toStringAsFixed(2)}',
                        ),
                        Text(
                          'Existencia: ${product.existencia}',
                        ),
                        Text(
                          'Precio B: Q${product.precioB.toStringAsFixed(2)}',
                        ),
                        Text(
                          'Precio C: Q${product.precioC.toStringAsFixed(2)}',
                        ),
                        Text(
                          'Precio D: Q${product.precioD.toStringAsFixed(2)}',
                        ),
                      ],
                    ),
                    onTap: _productSelected[index]
                        ? null
                        : () {
                            Navigator.pop(context, product);
                            setState(() {
                              _productSelected[index] = true;
                            });
                          },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PaginaPedidos extends StatefulWidget {
  const PaginaPedidos({Key? key, required cliente}) : super(key: key);

  @override
  _PaginaPedidosState createState() => _PaginaPedidosState();
}

class _PaginaPedidosState extends State<PaginaPedidos> {
  // Porcentaje de descuento

  void _loadSelectedProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? selectedProductsJson =
        prefs.getStringList('selectedProducts');

    if (selectedProductsJson != null) {
      setState(() {
        _selectedProducts = selectedProductsJson.map((jsonString) {
          Map<String, dynamic> productMap = json.decode(jsonString);
          return Product.fromJson(productMap);
        }).toList();

        _selectedProductQuantities = Map.fromIterable(_selectedProducts,
            key: (product) => product,
            value: (product) => prefs.getInt(product.codigo.toString()) ?? 1);
      });
    }
  }

  // En la clase _PaginaPedidosState
  void _loadSelectedClientName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? cliente = prefs.getString('selectedClient');
    print('IMPRESION DE CLIENTE');

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

  Future<Vendedor> loadSalesperson() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idVendedor = prefs.getString('idVendedor');
    print('http://192.168.1.212:3000/vendedor/id/$idVendedor');
    if (idVendedor != null) {
      try {
        final response = await http.get(
            Uri.parse('http://192.168.1.212:3000/vendedor/id/$idVendedor'));
        print(response.body);
        if (response.statusCode == 200) {
          vendedor = Vendedor.fromJson(jsonDecode(response.body));
          print(vendedor.value);
          print(vendedor.nombre);
          return vendedor;
        } else {
          print('Failed to load salesperson: ${response.statusCode}');
          return Vendedor(value: 1, nombre: 'Vendedor 1');
        }
      } catch (error) {
        print('Error loading salesperson: $error');
        throw Exception('Failed to load salesperson: $error');
      }
    } else {
      throw Exception('Failed to load salesperson: idVendedor is null');
    }
    // if (salespersonJson != null) {
    //   Map<String, dynamic> salespersonMap = jsonDecode(salespersonJson);
    //   Vendedor vendedor = Vendedor.fromJson(salespersonMap);
    //   _vendedores = [
    //     vendedor
    //   ]; // Actualizar para almacenar el vendedor en la lista
    //   _selectedSalespersonId = vendedor
    //       .value; // Actualizar para almacenar el ID del vendedor seleccionado
    // }
  }

  Vendedor vendedor = Vendedor(value: 1, nombre: 'Vendedor 1');
  int? _selectedSalespersonId; // ID del vendedor seleccionado
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

  double _calculateTotalWithDiscount() {
    double total = 0.0;
    // Itera sobre los productos seleccionados y calcula el precio total con descuento
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
  @override
  void initState() {
    super.initState();
    loadSalesperson().then((vendedor) {
      if (mounted) {
        setState(() {
          vendedor = vendedor;
        });
      }
      print('Vendedores cargados: $vendedor.nombre');
    }).catchError((error) {
      print('Error cargando vendedores: $error');
    });
    ;
    _loadSelectedClientName();
    _loadSelectedProducts();
    // Inicializa _selectedProductPrices con precioFinal por defecto
    _selectedProducts.forEach((product) {
      _selectedProductPrices[product] = product.precioFinal;
    }); // Agregar esta línea para cargar los productos seleccionados guardados
    fetchVendedores().then((vendedores) {
      if (mounted) {
        setState(() {
          _vendedores = vendedores;
        });
      }
      print('Vendedores cargados: $_vendedores');
    }).catchError((error) {
      print('Error cargando vendedores: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    double _totalPrice = _calculateTotalPrice();
    Vendedor? _selectedSalesperson;

    return WillPopScope(
        onWillPop: () async {
          // Mostrar diálogo de confirmación antes de retroceder
          bool confirm = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('¿Está seguro?'),
              content: Text('Puede perder algunos datos si retrocede.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true); // Close the dialog
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

          // Devolver true si el usuario confirma, false si cancela
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
                    // Ahora puedes usar _vendedores en tu DropdownButtonFormField
                    DropdownButtonFormField<Vendedor>(
                      value: _selectedSalesperson,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedSalesperson = newValue!;
                          print('Vendedor seleccionado: $newValue');
                          print(_selectedSalesperson!.value);
                          print(_selectedSalesperson!.nombre);
                          _selectedSalespersonId = newValue.value;
                          // Actualizar para almacenar el ID del vendedor seleccionado
                          // Guardar el vendedor seleccionado
                        });
                        // saveSalesperson(_selectedSalesperson!);
                      },
                      items: _vendedores.map((vendedor) {
                        return DropdownMenuItem<Vendedor>(
                          value: vendedor,
                          child: Text(
                            vendedor.nombre,
                          ),
                        );
                      }).toList(),

                      decoration: InputDecoration(
                        labelText: 'Vendedor',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      iconSize: 12, // Tamaño del ícono desplegable
                      dropdownColor: Colors
                          .white, // Color de fondo de la lista desplegable
                      elevation: 100,
                      borderRadius: BorderRadius.circular(50),
                      menuMaxHeight: 300,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black,
                      ),

                      // Elevación de la lista desplegable
                    ),
                    Column(
                      children: [
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CrearCliente(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors
                                    .blue, // Cambia el color de fondo a azul
                              ),
                              child: Text('+',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.white,
                                  )),
                            ),
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
                        // Otros widgets que necesites
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
                        _navigateToSeleccionarProducto(context);
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
                      children: _selectedProducts.map((product) {
                        double unitPrice = _selectedProductPrices[product] ??
                            product.precioFinal;
                        int quantity = _selectedProductQuantities[product] ?? 1;
                        double discount = _discounts[product] ?? 0;
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
                        ]
                            .where((price) => price > 0)
                            .toList(); // Filtrar precios mayores a 0

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            ListTile(
                              title: Row(
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
                                    items: availablePrices.toSet().map((price) {
                                      return DropdownMenuItem(
                                        value: price,
                                        child: Text(
                                            'Q${price.toStringAsFixed(2)}'),
                                      );
                                    }).toList(),
                                    onChanged: (newPrice) {
                                      setState(() {
                                        _selectedProductPrices[product] =
                                            newPrice!;
                                        unitPrice = newPrice;
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
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.remove_circle),
                                          onPressed: () {
                                            setState(() {
                                              if (quantity > 1) {
                                                _selectedProductQuantities[
                                                    product] = quantity - 1;
                                                _saveSelectedProducts();
                                              } else {
                                                _selectedProducts
                                                    .remove(product);
                                                _selectedProductQuantities
                                                    .remove(product);
                                                _discounts.remove(product);
                                                _selectedProductPrices
                                                    .remove(product);
                                              }
                                            });
                                          },
                                        ),
                                        Text(quantity.toString()),
                                        IconButton(
                                          icon: Icon(Icons.add_circle),
                                          onPressed: () {
                                            setState(() {
                                              _selectedProductQuantities[
                                                  product] = quantity + 1;
                                              _saveSelectedProducts();
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Expanded(
                                  child: TextField(
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
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                        vertical: 5.0,
                                        horizontal: 10.0,
                                      ),
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text('Q${subtotal.toStringAsFixed(2)}'),
                              ],
                            ),
                            Divider(),
                          ],
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
                          bottom: 10.0), // Agrega espacio entre los botones
                      child: ElevatedButton(
                        onPressed: () async {
                          // Mostrar AlertDialog de confirmación antes de agregar el pedido
                          bool confirm = await showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('¿Está seguro?'),
                              content: Text('¿Desea agregar el pedido?'),
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

                          if (confirm == true) {}
                          // Si el usuario confirma, proceder con la acción de agregar pedido
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
                                  _discounts);
                              Fluttertoast.showToast(
                                msg: 'Pedido guardado exitosamente.',
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                backgroundColor: Colors.blue,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
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

  //aqui termina el widget

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

  Future<List<Vendedor>> fetchVendedores() async {
    final response =
        await http.get(Uri.parse('http://192.168.1.212:3000/vendedor'));
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Vendedor.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load vendedores');
    }
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

    // Serializar el producto junto con su cantidad
    Map<String, dynamic> clientData = cliente.toJson();
    // List<String> selectedClientJson = json.encode(productData).toList();
    // Convertir el mapa en una cadena JSON
    List<String> selectedClientJson = clientData.entries.map((entry) {
      return '${entry.key}: ${entry.value.toString()}';
    }).toList();

    await prefs.setStringList('selectedClient',
        selectedClientJson); // Guardar el nombre del cliente en SharedPreferences
  }

  void _navigateToSeleccionarProducto(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      print('No token found');
      return;
    }

    http.get(
      Uri.parse('http://192.168.1.212:3000/dashboard/personalizado'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    ).then((response) {
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        List<Product> products = [];

        for (var productData in jsonResponse) {
          products.add(Product.fromJson(productData));
        }

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SeleccionarProducto(productos: products)),
        ).then((selectedProduct) {
          if (selectedProduct != null) {
            print(selectedProduct.precioFinal);
            print(selectedProduct.precioB);
            print(selectedProduct.precioC);
            print(selectedProduct.precioD);
            print('PRODUCTOS');
            setState(() {
              _selectedProducts.add(selectedProduct);
              if (_selectedProductQuantities.containsKey(selectedProduct)) {
                // Si el producto ya está en la lista, aumentar la cantidad
                _selectedProductQuantities[selectedProduct] =
                    _selectedProductQuantities[selectedProduct]! + 1;
              } else {
                // Si es un nuevo producto, establecer la cantidad en 1
                _selectedProductQuantities[selectedProduct] = 1;
              }
            });

            _saveSelectedProducts();

            // Aquí se guarda automáticamente la cantidad actualizada
          }
        });
      } else {
        print('Failed to load products: ${response.statusCode}');
      }
    }).catchError((error) {
      print('Error loading products: $error');
    });
  }

  Future<void> _saveSelectedProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> selectedProductsJson = _selectedProducts.map((product) {
      // Serializar el producto junto con su cantidad
      Map<String, dynamic> productData =
          product.toJson(_selectedProductQuantities[product] ?? 1);
      // Convertir el mapa en una cadena JSON
      return json.encode(productData);
    }).toList();
    // Guardar la lista de productos serializados en las preferencias compartidas
    await prefs.setStringList('selectedProducts', selectedProductsJson);
    print('PRODUCTOS SELECCIONADOS');
    print(selectedProductsJson);
    _selectedProducts.forEach((product) {
      prefs.setInt(
          product.codigo.toString(), _selectedProductQuantities[product] ?? 1);
    });
  }

  double _calculateTotalPrice() {
    double total = 0;
    _selectedProductQuantities.forEach((product, quantity) {
      total += product.precioFinal * quantity;
    });
    return total;
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
        // _observations = '';
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
}
