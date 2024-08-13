// lib/utils/api_routes.dart

class ApiRoutes {
  // Define la URL base
  static const String baseUrl = 'http://192.168.1.212:3000';

  // Método para obtener la URL completa concatenando la base con la ruta específica
  static Uri buildUri(String endpoint) {
    return Uri.parse('$baseUrl/$endpoint');
  }
}
