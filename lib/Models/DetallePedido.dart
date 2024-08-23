class DetallePedido {
  int? id;
  int? idPedido;
  int? codArticulo;
  String? descripcion;
  int? cantidad;
  double? precioVenta;
  int? porcDescuento;
  double? total;

  DetallePedido({
    this.id,
    this.idPedido,
    this.codArticulo,
    this.descripcion,
    this.cantidad,
    this.precioVenta,
    this.porcDescuento,
    this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idPedido': idPedido,
      'codArticulo': codArticulo,
      'descripcion': descripcion,
      'cantidad': cantidad,
      'precioVenta': precioVenta,
      'porcDescuento': porcDescuento,
      'total': total,
    };
  }

  factory DetallePedido.fromJson(Map<String, dynamic> json) {
    return DetallePedido(
      id: json['Id'],
      idPedido: json['IdPedido'],
      codArticulo: json['CodArticulo'],
      descripcion: json['Descripcion'],
      cantidad: json['Cantidad'],
      precioVenta: (json['PrecioVenta'] as num?)?.toDouble(), // Convertir a double si es necesario
      porcDescuento: json['PorcDescuento'],
      total: (json['Total'] as num?)?.toDouble(), // Convertir a double si es necesario
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'idPedido': idPedido,
    'codArticulo': codArticulo,
    'descripcion': descripcion,
    'cantidad': cantidad,
    'precioVenta': precioVenta,
    'porcDescuento': porcDescuento,
    'total': total,
  };
}
