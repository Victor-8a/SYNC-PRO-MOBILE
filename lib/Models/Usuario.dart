class Usuario {
  int? id;
  String nombre;
  String claveEntrada;
  String claveInterna;
  bool cambiarPrecio;
  double porcPrecio;
  bool aplicarDesc;
  double porcDesc;
  bool existNegativa;
  bool anulado;
  String tema;
  int idVendedor;
  bool verTodo;
  bool permitirAbrirVentanas;
  bool ventasFechaAnterior;
  bool esAdmin;
  int diasFacturacion;
  bool esEncargado;
  int? idEncargado;
  String? passUser;

  Usuario({
    this.id,
    required this.nombre,
    required this.claveEntrada,
    required this.claveInterna,
    required this.cambiarPrecio,
    required this.porcPrecio,
    required this.aplicarDesc,
    required this.porcDesc,
    required this.existNegativa,
    required this.anulado,
    required this.tema,
    required this.idVendedor,
    required this.verTodo,
    required this.permitirAbrirVentanas,
    required this.ventasFechaAnterior,
    required this.esAdmin,
    required this.diasFacturacion,
    required this.esEncargado,
    this.idEncargado,
    this.passUser,
  });

  // Convertir de JSON a objeto
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nombre: json['Nombre'],
      claveEntrada: json['ClaveEntrada'],
      claveInterna: json['ClaveInterna'],
      cambiarPrecio: json['CambiarPrecio'] == 1,
      porcPrecio: json['PorcPrecio'],
      aplicarDesc: json['AplicarDesc'] == 1,
      porcDesc: json['PorcDesc'],
      existNegativa: json['ExistNegativa'] == 1,
      anulado: json['Anulado'] == 1,
      tema: json['Tema'],
      idVendedor: json['IdVendedor'],
      verTodo: json['VerTodo'] == 1,
      permitirAbrirVentanas: json['PermitirAbrirVentanas'] == 1,
      ventasFechaAnterior: json['VentasFechaAnterior'] == 1,
      esAdmin: json['EsAdmin'] == 1,
      diasFacturacion: json['DiasFacturacion'],
      esEncargado: json['EsEncargado'] == 1,
      idEncargado: json['IdEncargado'],
      passUser: json['pass_user'],
    );
  }

  // Convertir de objeto a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'Nombre': nombre,
      'ClaveEntrada': claveEntrada,
      'ClaveInterna': claveInterna,
      'CambiarPrecio': cambiarPrecio ? 1 : 0,
      'PorcPrecio': porcPrecio,
      'AplicarDesc': aplicarDesc ? 1 : 0,
      'PorcDesc': porcDesc,
      'ExistNegativa': existNegativa ? 1 : 0,
      'Anulado': anulado ? 1 : 0,
      'Tema': tema,
      'IdVendedor': idVendedor,
      'VerTodo': verTodo ? 1 : 0,
      'PermitirAbrirVentanas': permitirAbrirVentanas ? 1 : 0,
      'VentasFechaAnterior': ventasFechaAnterior ? 1 : 0,
      'EsAdmin': esAdmin ? 1 : 0,
      'DiasFacturacion': diasFacturacion,
      'EsEncargado': esEncargado ? 1 : 0,
      'IdEncargado': idEncargado,
      'pass_user': passUser,
    };
  }
}
