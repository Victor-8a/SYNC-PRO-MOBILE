class Carrito {
  final int id;
  final int idProducto;
  final int cantidad;
  final double precio;

  Carrito({ 
    required this.id,
    required this.idProducto,
    required this.cantidad,
    required this.precio
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idProducto': idProducto,
      'cantidad': cantidad,
      'precio': precio
    };
  }

  Carrito.fromMap(Map<String, dynamic> map) 
    : id = map['id'],
      idProducto = map['idProducto'],
      cantidad = map['cantidad'],
      precio = map['precio'];
}