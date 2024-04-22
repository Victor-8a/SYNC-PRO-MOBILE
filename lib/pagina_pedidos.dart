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

class SeleccionarCliente extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccionar Cliente'),
      ),
      body: Center(
        child: Text('Pantalla de Seleccionar Cliente'),
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
  String _selectedSalesperson = 'Vendedor 1';
  String _selectedClient = 'Cliente 1';
  DateTime _selectedDate = DateTime.now();
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
            DropdownButtonFormField<String>(
              value: _selectedSalesperson,
              onChanged: (newValue) {
                setState(() {
                  _selectedSalesperson = newValue!;
                });
              },
              items: ['Vendedor 1', 'Vendedor 2', 'Vendedor 3'].map((vendedor) {
                return DropdownMenuItem(
                  value: vendedor,
                  child: Text(vendedor),
                );
              }).toList(),
              decoration: const InputDecoration(
                labelText: 'Vendedor',
              ),
            ),
            const SizedBox(height: 16.0),
            Text('Cliente: $_selectedClient'),
            ElevatedButton(
              onPressed: () {
                _navigateToSeleccionarCliente(context);
              },
              child: Text('Agregar Cliente'),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                const Text('Fecha de Entrega: '),
                const SizedBox(width: 8.0),
                InkWell(
                  onTap: () {
                    _selectDate(context);
                  },
                  child: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Text('Productos seleccionados:'),
            ElevatedButton(
              onPressed: () {
                _navigateToSeleccionarProducto(context);
              },
              child: Text('Agregar Producto'),
            ),
            if (_selectedProducts.isNotEmpty) ...[
              const SizedBox(height: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _selectedProducts.map((product) {
                  int quantity = _selectedProductQuantities[product]!;
                  double subtotal = product.precioFinal * quantity;
                  return Row(
                    children: [
                      Text('${product.descripcion} - \$${product.precioFinal} x $quantity'),
                      const SizedBox(width: 8.0),
                      Text('- Subtotal: \$${subtotal.toStringAsFixed(2)}'),
                    ],
                  );
                }).toList(),
              ),
            ],
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
              'Total: \$${totalPrice.toStringAsFixed(2)}',
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

  void _navigateToSeleccionarCliente(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SeleccionarCliente()),
    ).then((selectedClient) {
      if (selectedClient != null) {
        setState(() {
          _selectedClient = selectedClient;
        });
      }
    });
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

