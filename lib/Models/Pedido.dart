class Pedido {
  int? id;
  int? numPedido;
  int? codCliente;
  String? fecha;
  String? observaciones;
  int? idUsuario;
  String? fechaEntrega;
  int? codMoneda;
  int? tipoCambio;
  int? anulado;
  int? idVendedor;
  int? synced;

  Pedido({
    this.id,
    this.numPedido,
    this.codCliente,
    this.fecha,
    this.observaciones,
    this.idUsuario,
    this.fechaEntrega,
    this.codMoneda,
    this.tipoCambio,
    this.anulado,
    this.idVendedor,
    this.synced,
  });

  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id: json['id'],
      numPedido: json['NumPedido'],
      codCliente: json['CodCliente'],
      fecha: json['Fecha'],
      observaciones: json['Observaciones'],
      idUsuario: json['IdUsuario'],
      fechaEntrega: json['FechaEntrega'],
      codMoneda: json['CodMoneda'],
      tipoCambio: json['TipoCambio'],
      anulado: json['Anulado'],
      idVendedor: json['idVendedor'],
      synced: json['synced'],
    );
  }

Map<String, dynamic> toJson() {
    return {
      'id': id,
      'NumPedido': numPedido,
      'CodCliente': codCliente,
      'Fecha': fecha,
      'Observaciones': observaciones,
      'IdUsuario': idUsuario,
      'FechaEntrega': fechaEntrega,
      'CodMoneda': codMoneda,
      'TipoCambio': tipoCambio,
      'Anulado': anulado,
      'idVendedor': idVendedor,
      'synced': synced,
    };
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'NumPedido': numPedido,
    'CodCliente': codCliente,
    'Fecha': fecha,
    'Observaciones': observaciones,
    'IdUsuario': idUsuario,
    'FechaEntrega': fechaEntrega,
    'CodMoneda': codMoneda,
    'TipoCambio': tipoCambio,
    'Anulado': anulado,
    'idVendedor': idVendedor,
    'synced': synced,
  };

  static Pedido fromMap(Map<String, dynamic> map) {
    return Pedido(
      id: map['id'],
      numPedido: map['NumPedido'],
      codCliente: map['CodCliente'],
      fecha: map['Fecha'],
      observaciones: map['Observaciones'],
      idUsuario: map['IdUsuario'],
      fechaEntrega: map['FechaEntrega'],
      codMoneda: map['CodMoneda'],
      tipoCambio: map['TipoCambio'],
      anulado: map['Anulado'],
      idVendedor: map['idVendedor'],
      synced: map['synced'],
    );

}
}
