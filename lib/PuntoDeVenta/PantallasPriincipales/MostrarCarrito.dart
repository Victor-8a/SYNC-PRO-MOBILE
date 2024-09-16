import 'package:flutter/material.dart';
import 'package:sync_pro_mobile/Pedidos/Models/Producto.dart';

class MostrarCarrito extends StatefulWidget {
  final List<Product> cart;
  final Function(Product) onRemove;

  const MostrarCarrito({required this.cart, required this.onRemove});

  @override
  _MostrarCarritoState createState() => _MostrarCarritoState();
}

class _MostrarCarritoState extends State<MostrarCarrito> {
  late Map<Product, int> _cart;
  final Map<Product, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _cart = _groupProducts(widget.cart);
    // Initialize controllers for each product
    for (var product in _cart.keys) {
      _controllers[product] = TextEditingController(text: _cart[product]!.toString());
    }
  }

  Map<Product, int> _groupProducts(List<Product> products) {
    final Map<Product, int> groupedProducts = {};
    for (var product in products) {
      if (groupedProducts.containsKey(product)) {
        groupedProducts[product] = groupedProducts[product]! + 1;
      } else {
        groupedProducts[product] = 1;
      }
    }
    return groupedProducts;
  }

  void _updateQuantity(Product product, int quantity) {
    setState(() {
      if (quantity > 0) {
        _cart[product] = quantity;
      } else {
        _cart.remove(product);
        _controllers[product]?.dispose(); // Dispose the controller when removing the product
        _controllers.remove(product);
      }
      // Update the controller text after state change
      if (_controllers.containsKey(product)) {
        _controllers[product]!.text = _cart[product]?.toString() ?? '';
      }
    });
    if (quantity == 0) {
      widget.onRemove(product);
    }
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Carrito',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _cart.keys.length,
                itemBuilder: (context, index) {
                  final product = _cart.keys.elementAt(index);
                  final quantity = _cart[product]!;

                  return ListTile(
                    title: Text(product.descripcion, style: TextStyle(fontSize: 18)),
                    subtitle: Text('Q${product.precioFinal.toStringAsFixed(2)} x $quantity'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () {
                            if (quantity > 1) {
                              _updateQuantity(product, quantity - 1);
                            } else {
                              _updateQuantity(product, 0); // Set to 0 to trigger removal
                            }
                          },
                        ),
                        SizedBox(
                          width: 100,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.zero,
                            ),
                            controller: _controllers[product],
                            onChanged: (value) {
                              final newQuantity = int.tryParse(value) ?? quantity;
                              if (newQuantity != quantity) {
                                _updateQuantity(product, newQuantity);
                              }
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add_circle, color: Colors.green),
                          onPressed: () {
                            _updateQuantity(product, quantity + 1);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Divider(thickness: 1, color: Colors.grey[300]),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  
                  Expanded(
                    
                    child: Text(
                      'Total: Q${_cart.entries.fold(0.0, (double sum, MapEntry<Product, int> entry) => sum + (entry.key.precioFinal) * entry.value).toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple,                     
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(
                    child: ElevatedButton(
                      onPressed: _cart.isEmpty
                          ? null
                          : () {
                              // Acción de finalizar compra
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _cart.isEmpty ? Colors.grey : Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 18.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text('Finalizar Compra', style: TextStyle(fontSize: 15, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
