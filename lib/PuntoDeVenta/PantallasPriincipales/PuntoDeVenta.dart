import 'package:flutter/material.dart';
import 'package:sync_pro_mobile/db/dbCarrito.dart';
import 'package:sync_pro_mobile/PuntoDeVenta/PantallasSecundarias/MostrarCarrito.dart';
import 'package:sync_pro_mobile/PuntoDeVenta/PantallasSecundarias/ProductCard.dart';
import 'package:sync_pro_mobile/PuntoDeVenta/Servicios/ProductoPuntoDeVentaService.dart';
import 'package:sync_pro_mobile/Pedidos/Models/Producto.dart';

class PuntoDeVentaPage extends StatefulWidget {
  @override
  _PuntoDeVentaPageState createState() => _PuntoDeVentaPageState();
}

class _PuntoDeVentaPageState extends State<PuntoDeVentaPage> {
  final List<Product> products = [];
  final List<Product> cart = [];
  List<Product> filteredProducts = [];
  TextEditingController searchController = TextEditingController();
  bool isSearching = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() async {
    try {
      ProductServicePOS productService = ProductServicePOS();
      List<Product> fetchedProducts =
          await productService.insertarProductService();
      setState(() {
        products.addAll(fetchedProducts);
        filteredProducts = products;
      });
    } catch (e) {
      print('Error loading products: $e');
    }
  }

  void _filterProducts(String query) {
    setState(() {
      filteredProducts = products
          .where((product) =>
              product.descripcion.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _onSearchChanged(String query) {
    _filterProducts(query);
  }

  void _startSearching() {
    setState(() {
      isSearching = false;
    });
  }

  void _stopSearching() {
    setState(() {
      isSearching = false;
      searchController.clear();
      _filterProducts('');
    });
  }

  void openCart() {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => MostrarCarrito(),
      ),
    )
        .then((value) {
      setState(() {});
    });
  }

  Future<int> _getCartItemCount() async {
    return await DatabaseHelperCarrito().getProductCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearching
            ? TextField(
                controller: searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Buscar productos...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white),
                ),
                onChanged: _onSearchChanged,
                onSubmitted: (value) => _onSearchChanged(value),
              )
            : Text(
                'Punto de Venta',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
        backgroundColor: const Color.fromARGB(255, 68, 118, 255),
        actions: [
          isSearching
              ? IconButton(
                  icon: Icon(Icons.close),
                  onPressed: _stopSearching,
                )
              : IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _startSearching,
                ),
          FutureBuilder<int>(
            future: _getCartItemCount(),
            builder: (context, snapshot) {
              int itemCount = 0;
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  itemCount = snapshot.data!;
                }
              }
              return Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.shopping_cart),
                    onPressed: itemCount > 0 ? openCart : null,
                  ),
                  if (itemCount > 0)
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
                          '$itemCount',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  return ProductCard(
                    product: filteredProducts[index],
                    onAddToCart: () {
                      setState(() {
                        cart.add(filteredProducts[index]);
                      });
                    },
                  );
                },
              ),
            ),
            Divider(thickness: 1, color: Colors.grey[300]),
            Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: FutureBuilder<double>(
                      future: DatabaseHelperCarrito().getTotalCarrito(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: SizedBox());
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          double total = snapshot.data!.toDouble();
                          return Wrap(
                            direction: Axis.vertical,
                            children: [
                              Text(
                                'Total: Q${total.toStringAsFixed(2)}',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue),
                              ),
                            ],
                          );
                        } else {
                          return Text('Carrito vacío');
                        }
                      },
                    ),
                  ),
                  FutureBuilder<int>(
                    future: _getCartItemCount(),
                    builder: (context, snapshot) {
                      bool isButtonEnabled = false;
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData) {
                          isButtonEnabled = snapshot.data! > 0;
                        }
                      }
                      return ElevatedButton(
                        onPressed: isButtonEnabled ? openCart : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isButtonEnabled ? Colors.green : Colors.grey,
                          padding: EdgeInsets.symmetric(
                              vertical: 16.0, horizontal: 18.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text('Continuar Compra',
                            style:
                                TextStyle(fontSize: 12, color: Colors.white)),
                      );
                    },
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
