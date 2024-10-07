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
  int idEncargado;
  String passUser;

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
    required this.idEncargado,
    required this.passUser,
  });
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? 0,
      nombre: json['nombre'] ?? '',
      claveEntrada: json['claveEntrada'] ?? '',
      claveInterna: json['claveInterna'] ?? '',
      cambiarPrecio: json['cambiarPrecio'] ?? false,
      porcPrecio: (json['porcPrecio'] is int)
          ? (json['porcPrecio'] as int).toDouble()
          : json['porcPrecio']?.toDouble() ?? 0.0,
      aplicarDesc: json['aplicarDesc'] ?? false,
      porcDesc: (json['porcDesc'] is int)
          ? (json['porcDesc'] as int).toDouble()
          : json['porcDesc']?.toDouble() ?? 0.0,
      existNegativa: json['existNegativa'] ?? false,
      anulado: json['anulado'] ?? false,
      tema: json['tema'] ?? '',
      idVendedor: json['idVendedor'] ?? 0,
      verTodo: json['verTodo'] ?? false,
      permitirAbrirVentanas: json['permitirAbrirVentanas'] ?? false,
      ventasFechaAnterior: json['ventasFechaAnterior'] ?? false,
      esAdmin: json['esAdmin'] ?? false,
      diasFacturacion: json['diasFacturacion'] ?? 0,
      esEncargado: json['esEncargado'] ?? false,
      idEncargado: json['idEncargado'] ?? 0,
      passUser: json['pass_user'] ?? '',
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
