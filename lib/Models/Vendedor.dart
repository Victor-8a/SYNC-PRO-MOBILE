class Vendedor {
   int value;
   String nombre;

  Vendedor({
    required this.value,
    required this.nombre,
  });

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'nombre': nombre,
    };
  }

  factory Vendedor.fromJson(Map<String, dynamic> json) {
    return Vendedor(
      value: json['value'],
      nombre: json['nombre'],
    );
  }
}