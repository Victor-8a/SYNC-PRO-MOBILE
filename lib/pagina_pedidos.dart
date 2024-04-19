import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Definición de la clase Product
class Product {
  final int id;
  final String barras;
  final String name;
  final double price;

  Product(this.id, this.barras, this.name, this.price);
}

// Definición de la clase SeleccionarProducto
// Definición de la clase SeleccionarProducto
class SeleccionarProducto extends StatelessWidget {
  final List<Product> productos;

  SeleccionarProducto({Key? key, required this.productos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: productos.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(productos[index].name),
            onTap: () {
              print(productos[index].id);
            },
          );
        },
      ),
    );
  }
}

// Clase PaginaPedidos
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
      return sum + (product.price * _selectedProductQuantities[product]!);
    });

    return Scaffold(
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
            Text('Cliente: $_selectedClient'), // Etiqueta de cliente
            ElevatedButton(
              onPressed: () {
                _navigateToSeleccionarCliente(context); // Navega a SeleccionarCliente
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
            Text('Productos seleccionados:'), // Etiqueta de productos
            ElevatedButton(
              onPressed: () {
                _navigateToSeleccionarProducto(context); // Navega a SeleccionarProducto
              },
              child: Text('Agregar Producto'),
            ),
            // Mostrar los productos seleccionados con su precio y cantidad
            const SizedBox(height: 16.0),
            if (_selectedProducts.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _selectedProducts.map((product) {
                  int quantity = _selectedProductQuantities[product]!;
                  double subtotal = product.price * quantity;
                  return Row(
                    children: [
                      Text('${product.name} - \$${product.price} x $quantity'),
                      const SizedBox(width: 8.0),
                      Text('- Subtotal: \$${subtotal.toStringAsFixed(2)}'),
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
    // Realizar la solicitud HTTP a la API para obtener los productos
    http.get(Uri.parse('http://192.168.1.169:3500/dashboard')).then((response) {
      if (response.statusCode == 200) {
        // Si la solicitud es exitosa, decodifica la respuesta JSON
        List<dynamic> jsonResponse = json.decode(response.body);
        List<Product> products = [];

        // Convierte los datos decodificados en objetos Product
        for (var productData in jsonResponse) {
          products.add(Product(
            productData['id'],
            productData['barras'],
            productData['name'],
            productData['price'].toDouble(),
          ));
        }

        // Navega a la pantalla SeleccionarProducto con la lista de productos obtenidos
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
        // Si la solicitud falla, imprime el mensaje de error
        print('Failed to load products: ${response.statusCode}');
      }
    }).catchError((error) {
      // Si ocurre un error durante la solicitud, imprime el error
      print('Error loading products: $error');
    });
  }
}

class SeleccionarCliente extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Aquí iría la implementación para seleccionar cliente
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

void main() {
  runApp(MaterialApp(
    home: PaginaPedidos(),
  ));
}
