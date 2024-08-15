import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sync_pro_mobile/db/dbProducto.dart';
import 'package:sync_pro_mobile/Models/Producto.dart';
import 'package:sync_pro_mobile/services/ApiRoutes.dart';
import 'package:sync_pro_mobile/services/ObtenerRangoPrecioProducto.dart';

class ProductService {
  Future<List<Product>> fetchProducts() async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
     
        return await getProductsFromLocalDatabase();
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http.get(
      ApiRoutes.buildUri('dashboard/personalizado'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final products = data.map((json) => Product.fromJson(json)).toList();
        await saveProductsToLocalDatabase(products);
        fetchAndSaveRangoPrecios();
        return products;
      } else {
        throw Exception('Failed to load products');
      }
    } catch (error) {
      print('Error fetching products: $error');
      return await getProductsFromLocalDatabase();
    }
  }

  Future<List<Product>> getProductsFromLocalDatabase() async {
    final dbHelper = DatabaseHelperProducto();
    return await dbHelper.getProducts();
  }

  Future<void> saveProductsToLocalDatabase(List<Product> products) async {
    final dbHelper = DatabaseHelperProducto();
    for (var product in products) {
      await dbHelper.insertProduct(product);
    }
  }
}
