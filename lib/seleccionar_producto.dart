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
            subtitle: Text('Precio: \Q${productos[index].precioFinal.toStringAsFixed(2)}'),
            onTap: () {
              Navigator.pop(context, productos[index]);
            },
          );
        },
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
  List<Product> _selectedProducts = [];
  Map<Product, int> _selectedProductQuantities = {};
  String _observations = '';

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
            if (_selectedProducts.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _selectedProducts.map((product) {
                  int quantity = _selectedProductQuantities[product]!;
                  double subtotal = product.precioFinal * quantity;
                  return Row(
                    children: [
                      Text('${product.descripcion} - \Q${product.precioFinal} x $quantity'),
                      const SizedBox(width: 8.0),
                      Text('- Subtotal: \Q${subtotal.toStringAsFixed(2)}'),
                    ],
                  );
                }).toList(),
              ),
            const SizedBox(height: 16.0),
            TextField(
              onChanged: (value) {
                _observations = value;
              },
              decoration: const InputDecoration(
                labelText: 'Observaciones',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Total: \Q${totalPrice.toStringAsFixed(2)}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Aquí puedes agregar la lógica para agregar el pedido
                // a tu sistema o enviarlo a tu API
              },
              child: const Text('Agregar Pedido'),
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


