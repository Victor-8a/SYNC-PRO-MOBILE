import 'package:flutter/material.dart';
import 'seleccionar_producto.dart';
import 'seleccionar_clientes.dart'; // Importa las clases SeleccionarProducto y SeleccionarCliente

class Product {
  final String name;
  final double price;

  Product(this.name, this.price);
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
              items: ['Vendedor 1', 'Vendedor 2', 'Vendedor 3']
                  .map((vendedor) {
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
                      child: Colors.blue
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SeleccionarProducto()),
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
  }
  
 
  
}
