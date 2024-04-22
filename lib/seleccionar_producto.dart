import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
}

class SeleccionarProducto extends StatelessWidget {
  final List<Product> productos;

  SeleccionarProducto({Key? key, required this.productos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccionar Producto'),
      ),
      body: ListView.builder(
        itemCount: productos.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(productos[index].descripcion),
            subtitle: Text('Precio: \$${productos[index].precioFinal.toStringAsFixed(2)}'),
            onTap: () {
              Navigator.pop(context, productos[index]);
            },
          );
        },
      ),
    );
  }
}

class SearchWidget extends StatefulWidget {
  final List<String> data;
  final Function(String)? onItemSelected;

  const SearchWidget({
    Key? key,
    required this.data,
    this.onItemSelected,
  }) : super(key: key);

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  late List<String> filteredData;

  @override
  void initState() {
    super.initState();
    filteredData = widget.data;
  }

  void filterData(String query) {
    setState(() {
      filteredData = widget.data.where((item) => item.toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onChanged: filterData,
          decoration: InputDecoration(
            hintText: 'Buscar...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredData.length,
            itemBuilder: (context, index) {
              final item = filteredData[index];
              return ListTile(
                title: Text(item),
                onTap: () {
                  if (widget.onItemSelected != null) {
                    widget.onItemSelected!(item);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class PaginaPedidos extends StatefulWidget {
  const PaginaPedidos({Key? key}) : super(key: key);

  @override
  _PaginaPedidosState createState() => _PaginaPedidosState();
}

class _PaginaPedidosState extends State<PaginaPedidos> {
  List<Product> _selectedProducts = [];
  Map<Product, int> _selectedProductQuantities = {};
  String _observations = '';
  List<Product> _allProducts = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final response = await http.get(Uri.parse('http://192.168.1.169:3500/dashboard'));
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      setState(() {
        _allProducts = jsonResponse.map((data) => Product.fromJson(data)).toList();
      });
    } else {
      print('Failed to load products: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = _selectedProducts.fold(0, (sum, product) {
      return sum + (product.precioFinal * _selectedProductQuantities[product]!);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Pedidos'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16.0),
            Text('Productos seleccionados:'),
            ElevatedButton(
              onPressed: () {
                _navigateToSeleccionarProducto(context);
              },
              child: Text('Agregar Producto'),
            ),
            const SizedBox(height: 16.0),
            // Agregar el widget de búsqueda con la lista de descripciones de productos
            SearchWidget(
              data: _allProducts.map((product) => product.descripcion).toList(),
              onItemSelected: (selectedDescription) {
                final selectedProduct = _allProducts.firstWhere(
                  (product) => product.descripcion == selectedDescription,
                  orElse: () => Product(codigo: 0, barras: '', descripcion: '', precioFinal: 0.0),
                );
                setState(() {
                  if (_selectedProducts.contains(selectedProduct)) {
                    _selectedProductQuantities[selectedProduct] =
                        (_selectedProductQuantities[selectedProduct] ?? 0) + 1;
                  } else {
                    _selectedProducts.add(selectedProduct);
                    _selectedProductQuantities[selectedProduct] = 1;
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
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
              if (_selectedProducts.contains(selectedProduct)) {
                _selectedProductQuantities[selectedProduct] =
                    _selectedProductQuantities[selectedProduct]! + 1;
              } else {
                _selectedProducts.add(selectedProduct);
                _selectedProductQuantities[selectedProduct] = 1;
              }
            });
          }
        });
      } else {
        print('Failed to load products: ${response.statusCode}');
      }
    }).catchError((error) {
      print('Error loading products: $error');
    });
  }
}

