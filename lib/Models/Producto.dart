class Product {
  final int codigo;
  final String barras;
  final String descripcion;
  final int existencia;
  final double costo;
  final double precioFinal;
  final double precioB;
  final double precioC;
  final double precioD;
  final String marcas;
  final String categoriaSubCategoria;
  final String observaciones;

  Product({
    required this.codigo,
    required this.barras,
    required this.descripcion,
    required this.existencia,
    required this.costo,
    required this.precioFinal,
    required this.precioB,
    required this.precioC,
    required this.precioD,
    required this.marcas,
    required this.categoriaSubCategoria,
    required this.observaciones,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      codigo: json['codigo'] ?? 0,
      barras: json['Barras'] ?? '',
      descripcion: json['Descripcion'] ?? '',
      existencia: json['Existencia'] ?? 0,
      costo: json['Costo']?.toDouble() ?? 0,
      precioFinal: json['PrecioFinal']?.toDouble() ?? 0,
      precioB: json['PRECIOB']?.toDouble() ?? 0,
      precioC: json['PRECIOC']?.toDouble() ?? 0,
      precioD: json['PRECIOD']?.toDouble() ?? 0,
      marcas: json['Marcas'] ?? '',
      categoriaSubCategoria: json['Categoria_SubCategoria'] ?? '',
      observaciones: json['Observaciones'] ?? '',
    );
  }

  Map<String, dynamic> toJson(int cantidad) {
    return {
      'codigo': codigo,
      'Barras': barras,
      'Descripcion': descripcion,
      'Existencia': existencia,
      'Costo': costo,
      'PrecioFinal': precioFinal,
      'PRECIOB': precioB,
      'PRECIOC': precioC,
      'PRECIOD': precioD,
      'Marcas': marcas,
      'Categoria_SubCategoria': categoriaSubCategoria,
      'Observaciones': observaciones,
      'Cantidad': cantidad,
    };
  }
}
