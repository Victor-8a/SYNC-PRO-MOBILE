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
  bool? anulado;
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
    this.anulado = false,
    this.idVendedor,
    this.synced = 1,
  }) {
    numPedido = id;
    synced = 1; // Asegurarse de que siempre se establezca a 1
  }

  // Método para crear una instancia de Pedido desde JSON
  factory Pedido.fromJson(Map<String, dynamic> json) {
    return Pedido(
      id: json['id'],
      numPedido: json['id'],
      codCliente: json['CodCliente'],
      fecha: json['Fecha'],
      observaciones: json['Observaciones'],
      idUsuario: json['IdUsuario'],
      fechaEntrega: json['FechaEntrega'],
      codMoneda: json['CodMoneda'],
      tipoCambio: json['TipoCambio'],
      anulado: json['Anulado'] == 1, // Convertir 1 a true y 0 a false
      idVendedor: json['idVendedor'],
      synced: 1, // Asegurar que synced sea 1 cuando se crea desde JSON
    );
  }

  // Método para convertir una instancia de Pedido a un mapa
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numPedido': id,
      'CodCliente': codCliente,
      'Fecha': fecha,
      'Observaciones': observaciones,
      'IdUsuario': idUsuario,
      'FechaEntrega': fechaEntrega,
      'CodMoneda': codMoneda,
      'TipoCambio': tipoCambio,
      'Anulado': anulado == true ? 1 : 0, // Convertir true/false a 1/0
      'idVendedor': idVendedor,
      'synced': synced, // Asegurar que synced se incluya en el JSON
    };
  }

  // Método para convertir una instancia de Pedido a un mapa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'numPedido': id,
      'CodCliente': codCliente,
      'Fecha': fecha,
      'Observaciones': observaciones,
      'IdUsuario': idUsuario,
      'FechaEntrega': fechaEntrega,
      'CodMoneda': codMoneda,
      'TipoCambio': tipoCambio,
      'Anulado': anulado == true ? 1 : 0, // Convertir true/false a 1/0
      'idVendedor': idVendedor,
      'synced': synced, // Asegurar que synced se incluya en el mapa
    };
  }

  // Método para crear una instancia de Pedido desde un mapa
  factory Pedido.fromMap(Map<String, dynamic> map) {
    return Pedido(
      id: map['id'],
      numPedido: map['id'],
      codCliente: map['CodCliente'],
      fecha: map['Fecha'],
      observaciones: map['Observaciones'],
      idUsuario: map['IdUsuario'],
      fechaEntrega: map['FechaEntrega'],
      codMoneda: map['CodMoneda'],
      tipoCambio: map['TipoCambio'],
      anulado: map['Anulado'] == 1, // Convertir 1 a true y 0 a false
      idVendedor: map['idVendedor'],
      synced: 1, // Asegurar que synced sea 1 cuando se crea desde un mapa
    );
  }
}
