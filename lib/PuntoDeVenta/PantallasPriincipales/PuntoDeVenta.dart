import 'package:flutter/material.dart';
import 'package:sync_pro_mobile/Pedidos/Models/Producto.dart';
import 'package:sync_pro_mobile/PuntoDeVenta/PantallasPriincipales/mostrarCarrito.dart';
import 'package:sync_pro_mobile/PuntoDeVenta/PantallasSecundarias/ProductCard.dart';
import 'package:sync_pro_mobile/PuntoDeVenta/Servicios/ProductoPuntoDeVentaService.dart';

class PuntoDeVentaPage extends StatefulWidget {
  @override
  _PuntoDeVentaPageState createState() => _PuntoDeVentaPageState();
}

class _PuntoDeVentaPageState extends State<PuntoDeVentaPage> {
  final List<Product> products = [];
  final List<Product> cart = [];

  double get total => cart.fold(0.0, (sum, item) => sum + item.precioFinal);

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() async {
    try {
      ProductService productService = ProductService();
      List<Product> fetchedProducts =
          await productService.insertarProductService();
      setState(() {
        products.addAll(fetchedProducts);
      });
    } catch (e) {
      print('Error loading products: $e');
    }
  }

  void _removeFromCart(Product product) {
    setState(() {
      cart.remove(product);
    });
  }

  void openCart() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            MostrarCarrito(cart: cart, onRemove: _removeFromCart),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Punto de Venta',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 68, 118, 255),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Función de búsqueda de productos
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: cart.isNotEmpty ? openCart : null,
              ),
              if (cart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${cart.length}',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return ProductCard(
                    product: products[index],
                    onAddToCart: () {
                      setState(() {
                        cart.add(products[index]);
                      });
                    },
                  );
                },
              ),
            ),
            Divider(thickness: 1, color: Colors.grey[300]),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: Q${total.toStringAsFixed(2)}',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                  ElevatedButton(
                    onPressed: cart.isEmpty
                        ? null
                        : () {
                          openCart();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          cart.isEmpty ? Colors.grey : Colors.green,
                      padding: EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 24.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),

                  
                      ),
                    ),
                    child: Text('Continuar con la Venta',
                        style: TextStyle(fontSize: 12, color: Colors.white)),
                        
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