class Cliente {
  int codCliente;
  String nombre;
  String cedula;
  String direccion;
  String observaciones;
  String telefono1;
  String telefono2;
  String celular;
  String email;
  bool credito;
  double limiteCredito;
  double plazoCredito;
  double tipoPrecio;
  bool restriccion;
  double codMoneda;
  bool moroso;
  bool inHabilitado;
  String fechaIngreso;
  int idLocalidad;
  int idAgente;
  bool permiteDescuento;
  double descuento;
  double maxDescuento;
  bool exonerar;
  String codigo;
  String contacto;
  String telContacto;
  double dpi;
  double categoria;

  Cliente({
    this.codCliente = 0,
    this.nombre = '',
    this.cedula = '',
    this.direccion = '',
    this.observaciones = '',
    this.telefono1 = '',
    this.telefono2 = '',
    this.celular = '',
    this.email = '',
    this.credito = false,
    this.limiteCredito = 0.0,
    this.plazoCredito = 0.0,
    this.tipoPrecio = 0.0,
    this.restriccion = false,
    this.codMoneda = 0.0,
    this.moroso = false,
    this.inHabilitado = false,
    this.fechaIngreso = '',
    this.idLocalidad = 0,
    this.idAgente = 0,
    this.permiteDescuento = false,
    this.descuento = 0.0,
    this.maxDescuento = 0.0,
    this.exonerar = false,
    this.codigo = '',
    this.contacto = '',
    this.telContacto = '',
    this.dpi = 0.0,
    this.categoria = 0.0,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {

    return Cliente(
      codCliente: (json['CodCliente'] == null) ? json['codCliente'] : json['CodCliente'],
      nombre: (json['Nombre'] == null) ? json['nombre'] : json['Nombre'],
      cedula: (json['Cedula'] == null) ? json['cedula'] : json['Cedula'],
      direccion: json['direccion'] ?? '',
      observaciones: json['observaciones'] ?? '',
      telefono1: json['telefono1'] ?? '',
      telefono2: json['telefono2'] ?? '',
      celular: json['celular'] ?? '',
      email: json['email'] ?? '',
      credito: json['credito'] == 1,
      limiteCredito: (json['limiteCredito'] ?? 0.0).toDouble(),
      plazoCredito: (json['plazoCredito'] ?? 0.0).toDouble(),
      tipoPrecio: (json['tipoPrecio'] ?? 0.0).toDouble(),
      restriccion: json['restriccion'] == 1,
      codMoneda: (json['codMoneda'] ?? 0.0).toDouble(),
      moroso: json['moroso'] == 1,
      inHabilitado: json['inHabilitado'] == 1,
      fechaIngreso: json['fechaIngreso'] ?? '',
      idLocalidad: (json['IdLocalidad'] ?? 0),
      idAgente: (json['idAgente'] ?? 0),
      permiteDescuento: json['permiteDescuento'] == 1,
      descuento: (json['descuento'] ?? 0.0).toDouble(),
      maxDescuento: (json['maxDescuento'] ?? 0.0).toDouble(),
      exonerar: json['exonerar'] == 1,
      codigo: json['codigo'] ?? '',
      contacto: json['contacto'] ?? '',
      telContacto: json['telContacto'] ?? '',
      dpi: (json['dpi'] ?? 0.0).toDouble(),
      categoria: (json['categoria'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codCliente': codCliente,
      'nombre': nombre,
      'cedula': cedula,
      'direccion': direccion,
      'observaciones': observaciones,
      'telefono1': telefono1,
      'telefono2': telefono2,
      'celular': celular,
      'email': email,
      'credito': credito ? 1 : 0,
      'limiteCredito': limiteCredito,
      'plazoCredito': plazoCredito,
      'tipoPrecio': tipoPrecio,
      'restriccion': restriccion ? 1 : 0,
      'codMoneda': codMoneda,
      'moroso': moroso ? 1 : 0,
      'inHabilitado': inHabilitado ? 1 : 0,
      'fechaIngreso': fechaIngreso,
      'idLocalidad': idLocalidad,
      'idAgente': idAgente,
      'permiteDescuento': permiteDescuento ? 1 : 0,
      'descuento': descuento,
      'maxDescuento': maxDescuento,
      'exonerar': exonerar ? 1 : 0,
      'codigo': codigo,
      'contacto': contacto,
      'telContacto': telContacto,
      'dpi': dpi,
      'categoria': categoria,
    };
  }
}
