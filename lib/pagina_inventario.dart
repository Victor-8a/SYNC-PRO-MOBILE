import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product {
  final int codigo;
  final String barras;
  final String descripcion;
  final double costo;
  final double precioFinal;
  final double precioB;
  final double precioC;
  final double precioD;
  final String marcas;
  final String categoriaSubCategoria;

  Product({
    required this.codigo,
    required this.barras,
    required this.descripcion,
    required this.costo,
    required this.precioFinal,
    required this.precioB,
    required this.precioC,
    required this.precioD,
    required this.marcas,
    required this.categoriaSubCategoria,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      codigo: json['codigo'],
      barras: json['Barras'],
      descripcion: json['Descripcion'],
      costo: json['Costo'].toDouble(),
      precioFinal: json['PrecioFinal'].toDouble(),
      precioB: json['PRECIOB'].toDouble(),
      precioC: json['PRECIOC'].toDouble(),
      precioD: json['PRECIOD'].toDouble(),
      marcas: json['Marcas'],
      categoriaSubCategoria: json['Categoria_SubCategoria'],
    );
  }
}

class PaginaInventario extends StatefulWidget {
  const PaginaInventario({Key? key}) : super(key: key);

  @override
  _PaginaInventarioState createState() => _PaginaInventarioState();
}

class _PaginaInventarioState extends State<PaginaInventario> {
  late Future<List<Product>> futureProducts;
  List<Product> displayedProducts = [];

  @override
  void initState() {
    super.initState();
    futureProducts = fetchProducts();
  }

  Future<List<Product>> fetchProducts() async {
    final response =
        await http.get(Uri.parse('http://192.168.1.169:3500/dashboard'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Inventario',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
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
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: futureProducts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final products =
                      displayedProducts.isNotEmpty ? displayedProducts : snapshot.data!;
                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ListTile(
                        title: Text(product.descripcion),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Código: ${product.codigo}'),
                            Text('Barras: ${product.barras}'),
                            Text('Costo: ${product.costo.toStringAsFixed(2)}'),
                            Text('Precio Final: ${product.precioFinal.toStringAsFixed(2)}'),
                            Text('Marca: ${product.marcas}'),
                          ],
                        ),
                        // Otros detalles del producto según necesites
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
