class RangoPrecioProducto {
  int? id;
  int codProducto;
  double cantidadInicio;
  double cantidadFinal;
  double precio;

  RangoPrecioProducto({
    this.id,
    required this.codProducto,
    required this.cantidadInicio,
    required this.cantidadFinal,
    required this.precio,
  });

  // Método para convertir el objeto a un Map (para SQLite)
  Map<String, dynamic> toMap() {
    return {
      'Id': id,
      'CodProducto': codProducto,
      'CantidadInicio': cantidadInicio,
      'CantidadFinal': cantidadFinal,
      'Precio': precio,
    };
  }

  // Método para crear una instancia de RangoPrecioProducto desde un Map
  factory RangoPrecioProducto.fromMap(Map<String, dynamic> map) {
    return RangoPrecioProducto(
      id: map['Id'],
      codProducto: map['CodProducto'],
      cantidadInicio: (map['CantidadInicio'] is int)
          ? (map['CantidadInicio'] as int).toDouble()
          : map['CantidadInicio'] as double,
      cantidadFinal: (map['CantidadFinal'] is int)
          ? (map['CantidadFinal'] as int).toDouble()
          : map['CantidadFinal'] as double,
      precio: (map['Precio'] is int) ? (map['Precio'] as int).toDouble() : map['Precio'] as double,
    );
  }

  // Método para crear una instancia de RangoPrecioProducto desde JSON
  factory RangoPrecioProducto.fromJson(Map<String, dynamic> json) {
    return RangoPrecioProducto(
      id: json['Id'],
      codProducto: json['CodProducto'],
      cantidadInicio: (json['CantidadInicio'] is int)
          ? (json['CantidadInicio'] as int).toDouble()
          : json['CantidadInicio'] as double,
      cantidadFinal: (json['CantidadFinal'] is int)
          ? (json['CantidadFinal'] as int).toDouble()
          : json['CantidadFinal'] as double,
      precio: (json['Precio'] is int) ? (json['Precio'] as int).toDouble() : json['Precio'] as double,
    );
  }

  // Método para convertir el objeto a JSON
  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'CodProducto': codProducto,
      'CantidadInicio': cantidadInicio,
      'CantidadFinal': cantidadFinal,
      'Precio': precio,
    };
  }
}
