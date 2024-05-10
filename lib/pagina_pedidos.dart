import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sync_pro_mobile/Models/Cliente.dart';
import 'package:sync_pro_mobile/seleccionar_clientes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'Models/Producto.dart';
import 'Models/Vendedor.dart';


Future<String> getTokenFromStorage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String token = prefs.getString('token') ?? ""; // Si el token no existe, devuelve una cadena vacía
  return token;
}
// Función para guardar el pedido en la base de datos
Future<int?> saveOrder(int selectedClient, String observations, int value) async {
  try {
    String? token = await getTokenFromStorage();
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
      "IdUsuario": 3,
      "FechaEntrega": DateTime.now().add(Duration(days: 7)).toIso8601String(),
      "CodMoneda": 1,
      "TipoCambio": 1,
      "Anulado": false,
      "idVendedor": value,
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


Future<void> saveOrderDetail(int idPedido, List<Product> selectedProducts,
    Map<Product, int> selectedProductQuantities) async {
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
        "PrecioVenta": product.precioFinal
      };
      var body = jsonEncode(orderDetailData);

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
  List<bool> _productSelected = [];
  late List<Product> _filteredProducts;

  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _productSelected = List<bool>.filled(widget.productos.length, false);
    _filteredProducts = List.from(widget.productos);
    _searchController.addListener(_onSearchChanged);
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
                    subtitle: Text(
                      'Precio: \Q${product.precioFinal.toStringAsFixed(2)}',
                      style: TextStyle(color: Colors.grey),
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
  const PaginaPedidos({Key? key}) : super(key: key);

  @override
  _PaginaPedidosState createState() => _PaginaPedidosState();
}

class _PaginaPedidosState extends State<PaginaPedidos> {
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

  List<Vendedor> _vendedores = 
  Vendedor(value: 0, nombre: '') as List<Vendedor>;
  Cliente _selectedClient =
      Cliente(codCliente: 0, nombre: '', cedula: '', direccion: '');
  DateTime _selectedDate = DateTime.now();
  List<Product> _selectedProducts = [];
  Map<Product, int> _selectedProductQuantities = {};
  String _observations = '';

  Color _buttonColor = Colors.blue; // Color para los botones
  @override
  void initState() {
    super.initState();
    _loadSelectedClientName();
    _loadSelectedProducts(); // Agregar esta línea para cargar los productos seleccionados guardados
    fetchVendedores().then((vendedores) {
      setState(() {
        _vendedores = vendedores;
      });
      print('Vendedores cargados: $_vendedores');
    }).catchError((error) {
      print('Error cargando vendedores: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    double _totalPrice = _calculateTotalPrice();
    Vendedor? _selectedSalesperson;

    return Scaffold(
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
                });
              },
              items: _vendedores.map((vendedor) {
                return DropdownMenuItem<Vendedor>(
                  value: vendedor,
                  child: Text(
                    
                    vendedor.nombre, maxLines: vendedor.value,
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
              dropdownColor:
                  Colors.white, // Color de fondo de la lista desplegable
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
            SizedBox(height: 20.0),
            Text(
              'Cliente: ' + _selectedClient.nombre,
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
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
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
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
            Text(
              'Productos seleccionados:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            if (_selectedProducts.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _selectedProducts.map((product) {
                  int quantity = _selectedProductQuantities[product]!;
                  // ignore: unused_local_variable
                  double subtotal = product.precioFinal * quantity;
                  return ListTile(
                    title: Text(
                      '${product.descripcion} - \Q${product.precioFinal.toStringAsFixed(2)} x $quantity',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove_circle),
                          onPressed: () {
                            setState(() {
                              if (quantity > 1) {
                                _selectedProductQuantities[product] =
                                    quantity - 1;
                              } else {
                                _selectedProducts.remove(product);
                                _selectedProductQuantities.remove(product);
                              }
                            });
                          },
                        ),
                        Text(quantity.toString()),
                        IconButton(
                          icon: Icon(Icons.add_circle),
                          onPressed: () {
                            setState(() {
                              _selectedProductQuantities[product] =
                                  quantity + 1;
                            });
                          },
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
                labelText: 'Observaciones',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'Total: \Q${_totalPrice.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
            ),
            SizedBox(height: 20.0),

            ElevatedButton(
              onPressed: () async {
                int? idPedido = await saveOrder(
                     _selectedClient.codCliente, _observations, _selectedSalesperson!.value);
                if (idPedido != null) {
                  saveOrderDetail(
                      idPedido, _selectedProducts, _selectedProductQuantities);
                  Fluttertoast.showToast(
                    msg: 'Pedido guardado exitosamente.',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
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
            )
          ],
        ),
      ),
    );
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

  void _navigateToSeleccionarProducto(BuildContext context) {
    http.get(Uri.parse('http://192.168.1.169:3500/dashboard')).then((response) {
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

            _saveSelectedProducts(); // Aquí se guarda automáticamente la cantidad actualizada
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
}

// Future<void> _addProductToApi(Product product, int quantity) async {
//   try {
//     String? token = await getTokenFromStorage();
//     if (token == null) {
//       throw Exception('Token de autorización no válido');
//     }

//     var url = Uri.parse('http://192.168.1.212:3000/pedidos/save');
//     var headers = {
//       'Content-Type': 'application/json; charset=UTF-8',
//       'Authorization': 'Bearer $token',
//     };
//     var body = jsonEncode(<String, dynamic>{
//       'codigo': product.codigo,
//       'Barras': product.barras,
//       'Descripcion': product.descripcion,
//       'PrecioFinal': product.precioFinal,
//       'Cantidad': quantity,
//     });

//     var response = await http.post(url, headers: headers, body: body);

//     if (response.statusCode == 200) {
//       print('Producto agregado a la API exitosamente.');
//     } else {
//       throw Exception(
//           'Error al agregar el producto a la API: ${response.statusCode}');
//     }
//   } catch (error) {
//     print('Hubo un error al agregar el producto a la API: $error');
//     // Manejar el error según sea necesario
//   }
// }
