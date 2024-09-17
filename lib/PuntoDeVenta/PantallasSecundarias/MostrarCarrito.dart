import 'package:flutter/material.dart';
import 'package:sync_pro_mobile/Pedidos/Models/Producto.dart';
import 'package:sync_pro_mobile/PuntoDeVenta/PantallasSecundarias/FinalizarCompra.dart';
import 'package:sync_pro_mobile/db/dbCarrito.dart';

class MostrarCarrito extends StatefulWidget {
  @override
  _MostrarCarritoState createState() => _MostrarCarritoState();
}

class _MostrarCarritoState extends State<MostrarCarrito> {
  Map<Product, int> _cart = {};
  bool _isLoading = true;

  final DatabaseHelperCarrito _databaseHelper = DatabaseHelperCarrito();

  @override
  void initState() {
      _loadCartFromDatabase();
    super.initState();
  
  }

  // Cargar productos desde la base de datos
  Future<void> _loadCartFromDatabase() async {
    setState(() {
      _isLoading = false;
    });

    // Obtener los productos del carrito desde la base de datos
    final cartItems = await _databaseHelper.getCarritoItems();

    // Agrupar productos en un mapa de productos y cantidades
    Map<Product, int> cartMap = {};
    for (var item in cartItems) {
      final product = Product.fromMap(item); // Ajustar según cómo conviertas el producto desde la BD
      cartMap[product] = item['Cantidad'] as int;
    }

    setState(() {
      _cart = cartMap;
      _isLoading = false;
    });
  }

  // Actualizar la cantidad del producto en la base de datos
  Future<void> _updateQuantityInDatabase(Product product, int quantity) async {
    if (quantity > 0) {
      await _databaseHelper.updateCarritoItem(product.codigo, quantity);
    } else {
      await _databaseHelper.removeCarritoItem(product.codigo);
    }
    // Refrescar la vista después de la actualización
    _loadCartFromDatabase();
  }

  void _finalizarCompra() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FinalizarCompra()),
    );
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
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
                          title: Text(product.descripcion,
                              style: TextStyle(fontSize: 18)),
                          subtitle: Text(
                              'Q${product.precioFinal.toStringAsFixed(2)} x $quantity'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove_circle,
                                    color: Colors.red),
                                onPressed: () {
                                  if (quantity > 1) {
                                    _updateQuantityInDatabase(
                                        product, quantity - 1);
                                  } else {
                                    _updateQuantityInDatabase(
                                        product, 0); // Aquí eliminamos el producto si la cantidad llega a 0
                                  }
                                },
                              ),
                              SizedBox(
                                width: 50,
                                child: Text(
                                  quantity.toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.add_circle,
                                    color: Colors.green),
                                onPressed: () {
                                  _updateQuantityInDatabase(
                                      product, quantity + 1);
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Total: Q${_cart.entries.fold(0.0, (double sum, MapEntry<Product, int> entry) => sum + (entry.key.precioFinal) * entry.value).toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          child: ElevatedButton(
                            onPressed: _cart.isEmpty
                                ? null
                                : () {
                                    _finalizarCompra();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _cart.isEmpty ? Colors.grey : Colors.green,
                              padding: EdgeInsets.symmetric(
                                  vertical: 18.0, horizontal: 18.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              'Finalizar Compra',
                              style:
                                  TextStyle(fontSize: 15, color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
