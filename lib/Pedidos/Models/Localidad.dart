class Localidad {
  int id;
  String nombre;

  Localidad({
    required this.id,
    required this.nombre,
  });

  factory Localidad.fromJson(Map<String, dynamic> json) {
    return Localidad(
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
  static List<Localidad> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Localidad.fromJson(json)).toList();
  }

  // Método para convertir una lista de instancias de Ruta a una lista de objetos JSON
  static List<Map<String, dynamic>> toJsonList(List<Localidad> rutas) {
    return rutas.map((ruta) => ruta.toJson()).toList();
  }
}
