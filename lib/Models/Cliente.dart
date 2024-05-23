
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
  double idLocalidad;
  double idAgente;
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
    required this.codCliente,
    required this.nombre,
    required this.cedula,
    required this.direccion,
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
    this.idLocalidad = 0.0,
    this.idAgente = 0.0,
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
      codCliente: json['CodCliente'],
      nombre: json['Nombre'],
      cedula: json['Cedula'],
      direccion: json['Direccion'],
      observaciones: json['Observaciones'],
      telefono1: json['Telefono1'],
      telefono2: json['Telefono2'],
      celular: json['Celular'],
      email: json['Email'],
      credito: json['Credito'],
      limiteCredito: (json['LimiteCredito'] == null)
          ? 0.0
          : json['LimiteCredito'].toDouble(),
      plazoCredito: (json['PlazoCredito'] == null)
          ? 0.0
          : json['PlazoCredito'].toDouble(),
      tipoPrecio:
          (json['TipoPrecio'] == null) ? 0.0 : json['TipoPrecio'].toDouble(),
      restriccion: json['Restriccion'],
      codMoneda:
          (json['CodMoneda'] == null) ? 0.0 : json['CodMoneda'].toDouble(),
      moroso: json['Moroso'],
      inHabilitado: json['InHabilitado'],
      fechaIngreso: json['FechaIngreso'],
      idLocalidad:
          (json['IdLocalidad'] == null) ? 0.0 : json['IdLocalidad'].toDouble(),
      idAgente: (json['IdAgente'] == null) ? 0.0 : json['IdAgente'].toDouble(),
      permiteDescuento: json['PermiteDescuento'],
      descuento:
          (json['Descuento'] == null) ? 0.0 : json['Descuento'].toDouble(),
      maxDescuento: (json['MaxDescuento'] == null)
          ? 0.0
          : json['MaxDescuento'].toDouble(),
      exonerar: json['Exonerar'],
      codigo: json['Codigo'],
      contacto: json['Contacto'],
      telContacto: json['TelContacto'],
      dpi: (json['DPI'] == null) ? 0.0 : json['DPI'].toDouble(),
      categoria:
          (json['Categoria'] == null) ? 0.0 : json['Categoria'].toDouble(),
    
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codCliente': codCliente,
      'nombre': nombre,
      'cedula': cedula,
      'direccion': direccion,
      'Observaciones': observaciones,
      'Telefono1': telefono1,
      'Telefono2': telefono2,
      'Celular': celular,
      'Email': email,
      'Credito': credito,
      'LimiteCredito': limiteCredito,
      'PlazoCredito': plazoCredito,
      'TipoPrecio': tipoPrecio,
      'Restriccion': restriccion,
      'CodMoneda': codMoneda,
      'Moroso': moroso,
      'InHabilitado': inHabilitado,
      'FechaIngreso': fechaIngreso,
      'IdLocalidad': idLocalidad,
      'IdAgente': idAgente,
      'PermiteDescuento': permiteDescuento,
      'Descuento': descuento,
      'MaxDescuento': maxDescuento,
      'Exonerar': exonerar,
      'Codigo': codigo,
      'Contacto': contacto,
      'TelContacto': telContacto,
      'DPI': dpi,
      'Categoria': categoria,
    };
  }
}
