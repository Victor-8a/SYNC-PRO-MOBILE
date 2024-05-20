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
  String? valor = json['Id']?.toString(); // Use '?.' to safely access 'toString'
  Vendedor vendedor;

  if (valor == null || valor == 'null' || valor == '0') {
    vendedor = Vendedor(value: json['value'], nombre: json['nombre'] as String? ?? 'No hay nombre');
  } else {
    vendedor = Vendedor(value: int.parse(valor), nombre: json['Nombre'] as String);
  }

  return vendedor;
}

 
  }
