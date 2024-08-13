class RangoPrecioProducto {
  int? id;
  int codProducto;
  double cantidadInicio;
  double cantidadFinal;
  double precio;
  bool inhabilitado;

  RangoPrecioProducto({
    this.id,
    required this.codProducto,
    required this.cantidadInicio,
    required this.cantidadFinal,
    required this.precio,
    this.inhabilitado = false,
  });

  // Método para convertir el objeto a un Map (para SQLite)
  Map<String, dynamic> toMap() {
    return {
      'Id': id,
      'CodProducto': codProducto,
      'CantidadInicio': cantidadInicio,
      'CantidadFinal': cantidadFinal,
      'Precio': precio,
      'Inhabilitado': inhabilitado ? 1 : 0,
    };
  }

  // Método para crear una instancia de RangoPrecioProducto desde un Map
  factory RangoPrecioProducto.fromMap(Map<String, dynamic> map) {
    return RangoPrecioProducto(
      id: map['Id'],
      codProducto: map['CodProducto'],
      cantidadInicio: map['CantidadInicio'],
      cantidadFinal: map['CantidadFinal'],
      precio: map['Precio'],
      inhabilitado: map['Inhabilitado'] == 1,
    );
  }

  // Método para crear una instancia de RangoPrecioProducto desde JSON
  factory RangoPrecioProducto.fromJson(Map<String, dynamic> json) {
    return RangoPrecioProducto(
      id: json['Id'],
      codProducto: json['CodProducto'],
      cantidadInicio: json['CantidadInicio'],
      cantidadFinal: json['CantidadFinal'],
      precio: json['Precio'],
      inhabilitado: json['Inhabilitado'] == 1,
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
      'Inhabilitado': inhabilitado ? 1 : 0,
    };
  }
}
