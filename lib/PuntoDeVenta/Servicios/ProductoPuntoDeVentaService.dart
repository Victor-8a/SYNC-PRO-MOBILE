import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sync_pro_mobile/Pedidos/Models/Producto.dart';
import 'package:sync_pro_mobile/Pedidos/services/ApiRoutes.dart';
import 'package:sync_pro_mobile/Pedidos/services/LoginToken.dart';
import 'package:sync_pro_mobile/db/dbProducto.dart';

class ProductServicePOS {
  Future<List<Product>> insertarProductService() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await login();

    // Lógica para obtener un token válido
    if (token == null) {
      token = await login();
      if (token == null) {
        throw Exception('No token found and unable to login');
      }
      // Guardar el token en SharedPreferences
      await prefs.setString('token', token);
    }

    final response = await http.get(
      ApiRoutes.buildUri('inventario/personalizado'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    ).timeout(Duration(seconds: 5));

    if (response.statusCode == 200) {
      DatabaseHelperProducto().deleteAllProducts();
      final List<dynamic> data = jsonDecode(response.body);
      final producto = data.map((json) => Product.fromJson(json)).toList();
      await saveProductsToLocalDatabase(producto);
      final products = data.map((json) => Product.fromJson(json)).toList();

      return products;
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<void> saveProductsToLocalDatabase(List<Product> products) async {
    final dbHelper = DatabaseHelperProducto();
    for (var product in products) {
      await dbHelper.insertProduct(product);
    }
  }
}
