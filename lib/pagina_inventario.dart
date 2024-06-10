import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sync_pro_mobile/db/dbProducto.dart';
import 'Models/Producto.dart';

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
    futureProducts = fetchProducts().catchError((error) async {
      return await getProductsFromLocalDatabase();
    });
  }
   
// Suponiendo que ya tienes la clase Product y los métodos
// Product.fromJson, getProductsFromLocalDatabase y saveProductsToLocalDatabase definidos.

Future<List<Product>> fetchProducts() async {
  try {
    // Verificar la conectividad de red
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // Si no hay conexión a Internet, obtén los productos de la base de datos local
      print("NO HAY CONEXIÓN");
      return await getProductsFromLocalDatabase();
    }
    
    // Si hay conexión a Internet, intenta obtener los productos de la API
    print("SI HAY CONEXIÓN");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    
    if (token == null) {
      throw Exception('No token found');
    }
    
    
    final response = await http.get(
      Uri.parse('http://192.168.1.212:3000/dashboard/personalizado'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    ).timeout(Duration(seconds: 10)); // Añadimos un timeout para la petición HTTP
    
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      print(data);
      final products = data.map((json) => Product.fromJson(json)).toList();
      return products;
    } else {
      throw Exception('Failed to load products');
    }
  } catch (error) {
    // En caso de error al obtener productos de la API, intenta obtenerlos de la base de datos local
    print('Error fetching products: $error');
    return await getProductsFromLocalDatabase();
  }
}



  Future<List<Product>> getProductsFromLocalDatabase() async {
    final dbHelper = DatabaseHelper();
    return await dbHelper.getProducts();
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
                  final products = displayedProducts.isNotEmpty
                      ? displayedProducts
                      : snapshot.data!;
                  return ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ListTile(
                        title: Text(
                          product.barras + ' ' + product.descripcion,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Existencia: ${product.existencia}'),
                            Text('Costo: ${product.costo.toStringAsFixed(2)}'),
                            Text('Precios: A) ${product.precioFinal.toStringAsFixed(2)}' +
                                ' B) ${product.precioB.toStringAsFixed(2)}' +
                                ' C) ${product.precioC.toStringAsFixed(2)}' +
                                ' D) ${product.precioD.toStringAsFixed(2)}'),
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
    );
  }
}
