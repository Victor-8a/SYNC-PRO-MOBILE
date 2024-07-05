
class Empresa {
  int id;
  String cedula;
  String empresa;
  String nombreComercial;
  String telefono01;
  String telefono02;
  String fax01;
  String fax02;
  String direccion;
  String frase;
  String email;
  String web;
  String facebook;
  String info;
  int fel;
  String felCliente;
  String felPassword;
  int establecimientoFel;
  String servidorFel;
  String regimenFel;
  String felPasswordNit;
  int codigo;


  Empresa({
    required this.id,
    required this.cedula,
    required this.empresa,
    required this.nombreComercial,
    required this.telefono01,
    required this.telefono02,
    required this.fax01,
    required this.fax02,
    required this.direccion,
    required this.frase,
    required this.email,
    required this.web,
    required this.facebook,
    required this.info,
    required this.fel,
    required this.felCliente,
    required this.felPassword,
    required this.establecimientoFel,
    required this.servidorFel,
    required this.regimenFel,
    required this.felPasswordNit,
    this.codigo = 0,
  });

  factory Empresa.fromJson(Map<String, dynamic> json) {
    return Empresa(
      id: json['Id'] ?? 0,
      cedula: json['Cedula'] ?? '',
      empresa: json['Empresa'] ?? '',
      nombreComercial: json['NombreComercial'] ?? '',
      telefono01: json['Telefono01'] ?? '',
      telefono02: json['Telefono02'] ?? '',
      fax01: json['Fax01'] ?? '',
      fax02: json['Fax02'] ?? '',
      direccion: json['Direccion'] ?? '',
      frase: json['Frase'] ?? '',
      email: json['Email'] ?? '',
      web: json['Web'] ?? '',
      facebook: json['Facebook'] ?? '',
      info: json['Info'] ?? '',
      fel: json['FEL'] ?? -1,
      felCliente: json['FELCliente'] ?? '',
      felPassword: json['FELPassword'] ?? '',
      establecimientoFel: json['EstablecimientoFEL'] ?? 0,
      servidorFel: json['ServidorFEL'] ?? '',
      regimenFel: json['RegimenFEL'] ?? '',
      felPasswordNit: json['FELPasswordNIT'] ?? '',
      codigo: json['codigo'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Id': id,
      'Cedula': cedula,
      'Empresa': empresa,
      'NombreComercial': nombreComercial,
      'Telefono01': telefono01,
      'Telefono02': telefono02,
      'Fax01': fax01,
      'Fax02': fax02,
      'Direccion': direccion,
      'Frase': frase,
      'Email': email,
      'Web': web,
      'Facebook': facebook,
      'Info': info,
      'FEL': fel,
      'FELCliente': felCliente,
      'FELPassword': felPassword,
      'EstablecimientoFEL': establecimientoFel,
      'ServidorFEL': servidorFel,
      'RegimenFEL': regimenFel,
      'FELPasswordNIT': felPasswordNit,
      'codigo': codigo,

    };
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Cedula': cedula,
      'Empresa': empresa,
      'NombreComercial': nombreComercial,
      'Telefono01': telefono01,
      'Telefono02': telefono02,
      'Fax01': fax01,
      'Fax02': fax02,
      'Direccion': direccion,
      'Frase': frase,
      'Email': email,
      'Web': web,
      'Facebook': facebook,
      'Info': info,
      'FEL': fel,
      'FELCliente': felCliente,
      'FELPassword': felPassword,
      'EstablecimientoFEL': establecimientoFel,
      'ServidorFEL': servidorFel,
      'RegimenFEL': regimenFel,
      'FELPasswordNIT': felPasswordNit,
      'codigo': codigo,
    };
  }
}
