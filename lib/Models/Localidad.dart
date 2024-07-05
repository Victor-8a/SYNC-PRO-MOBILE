class Ruta {
  int id;
  String nombre;

  Ruta({
    required this.id,
    required this.nombre,
  });

  factory Ruta.fromJson(Map<String, dynamic> json) {
    return Ruta(
      id: json['id'] ?? 0,
      nombre: json['Nombre'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'Nombre': nombre,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Nombre': nombre,
    };
  }

  // Método para convertir una lista de objetos JSON a una lista de instancias de Ruta
  static List<Ruta> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Ruta.fromJson(json)).toList();
  }

  // Método para convertir una lista de instancias de Ruta a una lista de objetos JSON
  static List<Map<String, dynamic>> toJsonList(List<Ruta> rutas) {
    return rutas.map((ruta) => ruta.toJson()).toList();
  }
}
