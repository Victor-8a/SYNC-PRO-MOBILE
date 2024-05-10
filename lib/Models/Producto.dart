class Product {
  final int codigo;
  final String barras;
  final String descripcion;
  final double precioFinal;
 
  Product({
    required this.codigo,
    required this.barras,
    required this.descripcion,
    required this.precioFinal,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      codigo: json['codigo'],
      barras: json['Barras'],
      descripcion: json['Descripcion'],
      precioFinal: json['PrecioFinal'].toDouble(),
    );
  }

  Map<String, dynamic> toJson(int cantidad) {
    return {
      'codigo': codigo,
      'Barras': barras,
      'Descripcion': descripcion,
      'PrecioFinal': precioFinal,
      'Cantidad': cantidad, // Agregar la cantidad al mapa JSON
    };
  }
}