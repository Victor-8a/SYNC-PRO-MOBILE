import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sync_pro_mobile/seleccionar_clientes.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Product {
  final int codigo;
  final String barras;
  final String descripcion;
  final double precioFinal;
 
  Product({
    required this.codigo,
    required this.barras,
    required this.descripcion,
    required this.precioFinal,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      codigo: json['codigo'],
      barras: json['Barras'],
      descripcion: json['Descripcion'],
      precioFinal: json['PrecioFinal'].toDouble(),
    );
  }

  Map<String, dynamic> toJson(int cantidad) {
    return {
      'codigo': codigo,
      'Barras': barras,
      'Descripcion': descripcion,
      'PrecioFinal': precioFinal,
      'Cantidad': cantidad, // Agregar la cantidad al mapa JSON
    };
  }
}

class Vendedor {
  final int value;
  final String nombre;

  Vendedor({
    required this.value,
    required this.nombre,
    
  });

  factory Vendedor.fromJson(Map<String, dynamic> json) {
    return Vendedor(
      value: json['value'],
      nombre: json['nombre'],
     
    );
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
  List<String>? selectedProductsJson = prefs.getStringList('selectedProducts');

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
  String? selectedClient = prefs.getString('selectedClient');
  if (selectedClient != null) {
    setState(() {
      _selectedClient = selectedClient;
    });
  }
}
  
  List<Vendedor> _vendedores = [];
  String _selectedClient = 'Cliente 1';
  DateTime _selectedDate = DateTime.now();
  List<Product> _selectedProducts = [];
  Map<Product, int> _selectedProductQuantities = {};
  // ignore: unused_field
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
    var _selectedSalesperson;
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
                child: Text(vendedor.nombre,),
                
              );
            }).toList(),
            decoration: InputDecoration(
              labelText: 'Vendedor',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            iconSize: 12, // Tamaño del ícono desplegable
  dropdownColor: Colors.white, // Color de fondo de la lista desplegable
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
              'Cliente: $_selectedClient',
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
      Icons.calendar_today, // Aquí puedes cambiar el icono por el que desees
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
                                _selectedProductQuantities[product] = quantity - 1;
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
                              _selectedProductQuantities[product] = quantity + 1;
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
              onPressed: () {
                // Aquí puedes agregar la lógica para agregar el pedido
                // a tu sistema o enviarlo a tu API
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
  final response = await http.get(Uri.parse('http://192.168.1.212:3000/vendedor'));
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
      _saveSelectedClientName(selectedClient.nombre); // Guardar el nombre del cliente seleccionado
      setState(() {
        _selectedClient = selectedClient.nombre; // Actualizar el nombre del cliente seleccionado
      });
    }
  });
}

Future<void> _saveSelectedClientName(String clientName) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('selectedClient', clientName); // Guardar el nombre del cliente en SharedPreferences
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
        MaterialPageRoute(builder: (context) => SeleccionarProducto(productos: products)),
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
    Map<String, dynamic> productData = product.toJson(_selectedProductQuantities[product] ?? 1);
    // Convertir el mapa en una cadena JSON
    return json.encode(productData);
  }).toList();
  // Guardar la lista de productos serializados en las preferencias compartidas
  await prefs.setStringList('selectedProducts', selectedProductsJson);
  _selectedProducts.forEach((product) {
    prefs.setInt(product.codigo.toString(), _selectedProductQuantities[product] ?? 1);
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

