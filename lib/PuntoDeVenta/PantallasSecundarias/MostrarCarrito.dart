import 'package:flutter/material.dart';
import 'package:sync_pro_mobile/Pedidos/Models/Producto.dart';
import 'package:sync_pro_mobile/PuntoDeVenta/PantallasSecundarias/FinalizarCompra.dart';
import 'package:sync_pro_mobile/PuntoDeVenta/Servicios/VerificarExistencia.dart';
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

  Future<void> _loadCartFromDatabase() async {
    setState(() {
      _isLoading = true;
    });

    final cartItems = await _databaseHelper.getCarritoItems();

    Map<Product, int> cartMap = {};
    for (var item in cartItems) {
      final product = Product.fromMap(item);
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

  void finalizarCompra() async {
    List<Product> productosInsuficientes = await validarExistencias(_cart);
    if (productosInsuficientes.isEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FinalizarCompra()),
      );
    } else {
      String mensajeError =
          "Algunos productos exceden la existencia disponible:\n";

      for (var producto in productosInsuficientes) {
        int cantidadDisponible = producto.existencia;
        mensajeError +=
            "${producto.descripcion}: Solo hay ${cantidadDisponible} disponibles.\n";
        Divider(thickness: 2);
      }

      _mostrarMensajeError(mensajeError);
    }
  }

  void _mostrarMensajeError(String mensaje) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error de Existencias"),
          content: Text(mensaje),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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
                        final TextEditingController _controller =
                            TextEditingController(text: quantity.toString());

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
                                    _updateQuantityInDatabase(product,
                                        0); // Eliminar producto si la cantidad es 0
                                  }
                                },
                              ),
                              SizedBox(
                                width: 50,
                                child: TextField(
                                  controller: _controller,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  onSubmitted: (value) {
                                    // Validar la entrada del usuario
                                    int? newQuantity = int.tryParse(value);
                                    if (newQuantity != null &&
                                        newQuantity > 0) {
                                      _updateQuantityInDatabase(
                                          product, newQuantity);
                                    } else if (newQuantity == 0) {
                                      _updateQuantityInDatabase(
                                          product, 0); // Eliminar producto
                                    } else {
                                      // Restaurar el valor anterior si la entrada es inválida
                                      _controller.text = quantity.toString();
                                    }
                                  },
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                              IconButton(
                                icon:
                                    Icon(Icons.add_circle, color: Colors.green),
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
                                    finalizarCompra();
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
