import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sync_pro_mobile/Pedidos/Models/Producto.dart';
import 'package:sync_pro_mobile/Pedidos/services/ApiRoutes.dart';
import 'package:sync_pro_mobile/Pedidos/services/EmpresaService.dart';
import '../../db/dbDetallePedidos.dart' as dbDetallePedidos;

Future<void> saveOrderDetail(
  int idPedido,
  List<Product> selectedProducts,
  Map<Product, int> selectedProductQuantities,
  Map<Product, double> selectedProductPrices,
  Map<Product, double> discounts,
) async {
  try {
    String? token = await getTokenFromStorage();
    // ignore: unnecessary_null_comparison
    if (token == null) {
      throw Exception('Token de autorización no válido');
    }

    var url = ApiRoutes.buildUri('paraElFuturo');
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    for (var product in selectedProducts) {
      try {
        var orderDetailData = {
          "IdPedido": idPedido,
          "CodArticulo": product.codigo,
          "Descripcion": product.descripcion,
          "Cantidad": selectedProductQuantities[product],
          "PrecioVenta": selectedProductPrices[product] ?? product.precioFinal,
          "PorcDescuento": discounts[product] ?? 0,
          "Total": ((selectedProductPrices[product] ?? product.precioFinal) *
                  selectedProductQuantities[product]! -
              (selectedProductQuantities[product]! *
                  ((selectedProductPrices[product] ?? product.precioFinal) *
                      (discounts[product] ?? 0) /
                      100)))
        };

        await dbDetallePedidos.DatabaseHelperDetallePedidos()
            .insertOrderDetail(orderDetailData);

        var body = jsonEncode(orderDetailData);
        print('Datos del detalle del pedido a enviar: $body');

        var response = await http.post(url, headers: headers, body: body);

        if (response.statusCode == 200) {
          print('Detalle del pedido guardado en la API correctamente');
          print(
              'Detalle del pedido marcado como sincronizado en SQLite: $orderDetailData');
        } else {
          print(
              'Error al guardar el detalle del pedido en la API: ${response.statusCode}');
        }
      } catch (e) {
        print('Error al procesar el producto ${product.codigo}: $e');
      }
    }
  } catch (error, stackTrace) {
    print('Hubo un error al guardar los detalles del pedido: $error');
    print(stackTrace);
  }
}
