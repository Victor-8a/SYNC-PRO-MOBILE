class Product {
  final int codigo;
  final String barras;
  final String descripcion;
  final double costo;
  final double precioFinal;
  final double precioB;
  final double precioC;
  final double precioD;
  // final int marcas;
  // final int categoriaSubCategoria;

  Product({
    required this.codigo,
    required this.barras,
    required this.descripcion,
    required this.costo,
    required this.precioFinal,
    required this.precioB,
    required this.precioC,
    required this.precioD,
    // required this.marcas,
    // required this.categoriaSubCategoria,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      codigo:(json['codigo']==null) ? 0:json['codigo'],
      barras:(json['Barras']== null) ? '' :json['Barras'],
      descripcion:(json['Descripcion']== null) ? '': json['Descripcion'],
      costo: (json['Costo'] == null) ? 0 : json['Costo'].toDouble(),
      precioFinal: (json['PrecioFinal'] == null) ? 0 : json['PrecioFinal'].toDouble(),
      precioB: (json['PRECIOB'] == null) ? 0 : json['PRECIOB'].toDouble(),
      precioC: (json['PRECIOC'] == null) ? 0 : json['PRECIOC'].toDouble(),
      precioD: (json['PRECIOD'] == null) ? 0.0 : json['PRECIOD'].toDouble(),
      // marcas: (json['Marcas'] == null) ? 0 : int.parse(json['Marcas']),
      // categoriaSubCategoria: (json['Categoria_SubCategoria'] == null)? 0: int.parse(json['Categoria_SubCategoria']),
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
