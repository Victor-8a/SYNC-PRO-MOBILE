import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sync_pro_mobile/Pedidos/Models/Producto.dart';

Future<List<Product>> validarExistencias(Map<Product, int> cart) async {
  final url = Uri.parse('http://192.168.1.169:3333/inventario/checkStock');
  final headers = {"Content-Type": "application/json"};
  final body = json
      .encode({"codigos": cart.keys.map((product) => product.codigo).toList()});

  try {
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Accede a la lista de productos en la respuesta
      final productos = data['productos'] as List;
      List<Product> productosInsuficientes = [];

      for (var producto in productos) {
        final codigoProducto = producto['codigo'];
        final existencia = producto['existencia'];

        final productoCarrito =
            cart.keys.firstWhere((p) => p.codigo == codigoProducto);

        // Verifica que el productoCarrito no sea nulo
        // ignore: unnecessary_null_comparison
        if (productoCarrito != null && cart[productoCarrito]! > existencia) {
          // Agrega el producto a la lista si la cantidad en el carrito es mayor que la existencia
          productosInsuficientes.add(productoCarrito);
        }
      }
      return productosInsuficientes; // Retorna la lista de productos con existencias insuficientes
    } else {
      // Manejo de errores de la API
      throw Exception("Error en la validación de existencias");
    }
  } catch (e) {
    print(e.toString());
    return []; // Devuelve una lista vacía en caso de error
  }
}
