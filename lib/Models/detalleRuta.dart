class DetalleRuta {
  int? id;
  int idRuta;
  int codCliente; // Un solo ID de cliente
  String estado;
  String observaciones;
  int idPedido;
  String inicio;
  String fin;
  String? nombreCliente ;

  DetalleRuta({
    required this.idRuta,
    required this.codCliente, // Un solo ID de cliente
    required this.estado,
    required this.observaciones,
    required this.idPedido,
    required this.inicio,
    required this.fin,
    this.id,
    this.nombreCliente,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idRuta': idRuta,
      'codCliente': codCliente,
      'estado': estado,
      'observaciones': observaciones,
      'idPedido': idPedido,
      'inicio': inicio,
      'fin': fin,
    };
  }

  factory DetalleRuta.fromMap(Map<String, dynamic> map) {
     DetalleRuta detalle= new DetalleRuta(
      id: map['id'],
      nombreCliente: map['nombreCliente'],
      idRuta: map['idRuta'],
     codCliente: (map['CodCliente'] != null) ? map['CodCliente'] : map['codCliente'],

      estado: map['estado'],
      observaciones: map['observaciones'],
      idPedido: map['idPedido'],
      inicio: map['inicio'],
      fin: map['fin'],
    );
    return detalle;
  }
}
