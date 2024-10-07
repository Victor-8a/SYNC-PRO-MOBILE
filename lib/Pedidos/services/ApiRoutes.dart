// lib/utils/api_routes.dart

class ApiRoutes {
  static const String baseUrl = 'http://192.168.1.26:4000'; //pruebas

  // static const String baseUrl = 'http://85.10.196.212:4006';

  // Método para obtener la URL completa concatenando la base con la ruta específica
  static Uri buildUri(String endpoint) {
    return Uri.parse('$baseUrl/$endpoint');
  }
}
