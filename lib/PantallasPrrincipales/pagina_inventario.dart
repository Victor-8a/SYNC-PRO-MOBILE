import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sync_pro_mobile/Models/Producto.dart';
import 'package:sync_pro_mobile/services/ProductoService.dart';

class PaginaInventario extends StatefulWidget {
  const PaginaInventario({Key? key}) : super(key: key);

  @override
  _PaginaInventarioState createState() => _PaginaInventarioState();
}

class _PaginaInventarioState extends State<PaginaInventario> {
  late Future<List<Product>> futureProducts;
  List<Product> displayedProducts = [];
  final ProductService productService = ProductService();

  @override
  void initState() {
    super.initState();
    futureProducts = productService.getProductsFromLocalDatabase();
  }

  void _filterProducts(String query) {
    futureProducts.then((products) {
      setState(() {
        displayedProducts = products
            .where((product) =>
                product.descripcion.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    });
  }

  void _syncProducts() async {
    setState(() {
      futureProducts = productService.fetchProducts();
    });
  }
 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: _filterProducts,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Buscar producto',
                    prefixIcon: Icon(Icons.search),
                    prefixIconColor: Colors.blue,
                  ),
                  cursorColor: Colors.blue,
                ),
              ),
              SizedBox(width: 8.0), // Espacio adicional entre el TextField y el botón
               IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  _syncProducts();
})],
          ),
          SizedBox(height: 8.0), // Espacio adicional después de la fila
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: futureProducts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final products = displayedProducts.isNotEmpty
                      ? displayedProducts
                      : snapshot.data!;
                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ListTile(
                        title: Text(
                          '${product.barras} ${product.descripcion}',
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Existencia: ${product.existencia}'),
                            Text('Costo: ${product.costo.toStringAsFixed(2)}'),
                            Text('Precios: A) ${product.precioFinal.toStringAsFixed(2)}, ' +
                                'B) ${product.precioB.toStringAsFixed(2)}, ' +
                                'C) ${product.precioC.toStringAsFixed(2)}, ' +
                                'D) ${product.precioD.toStringAsFixed(2)}'),
                            Text('Marca: ${product.marcas}'),
                            Text('Categoría: ${product.categoriaSubCategoria}'),
                            Divider(color: Colors.blue),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    ),
  );
}
}