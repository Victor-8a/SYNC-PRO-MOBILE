class DetalleRuta {
  int id;
  int idRuta;
  int idCodCliente;
  String estado;
  String observaciones;
  int idPedido;
  String inicio;
  String fin;

  DetalleRuta({
    required this.id,
    required this.idRuta,
    required this.idCodCliente,
    required this.estado,
    required this.observaciones,
    required this.idPedido,
    required this.inicio,
    required this.fin,
  });

  factory DetalleRuta.fromMap(Map<String, dynamic> map) => DetalleRuta(
        id: map['id'],
        idRuta: map['idRuta'],
        idCodCliente: map['idCodCliente'],
        estado: map['estado'],
        observaciones: map['observaciones'],
        idPedido: map['idPedido'],
        inicio: map['inicio'],
        fin: map['fin'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'idRuta': idRuta,
        'idCodCliente': idCodCliente,
        'estado': estado,
        'observaciones': observaciones,
        'idPedido': idPedido,
        'inicio': inicio,
        'fin': fin,
      };
}
