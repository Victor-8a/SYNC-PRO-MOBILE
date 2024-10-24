import 'package:http/http.dart' as http;
import 'dart:convert';

class VentaService {
  final String apiUrl =
      'https://tudominio.com/api/ventas'; // Asegúrate de cambiar la URL a la de tu API.

  Future<void> registrarVenta(Map<String, dynamic> datosVenta) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(datosVenta),
      );

      if (response.statusCode == 200) {
        print("Venta registrada con éxito.");
      } else {
        throw Exception('Error al registrar la venta: ${response.body}');
      }
    } catch (e) {
      print('Excepción al registrar la venta: $e');
      // Manejar el error en la UI si es necesario
    }
  }
}
