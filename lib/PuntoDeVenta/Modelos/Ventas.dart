class Ventas {
  int id;
  int nFactura;
  String tipo;
  String fecha;
  String vence;
  int codCLiente;
  String nombreCliente;
  int idUsuario;
  bool anulado;
  bool facturaCancelado;
  int numApertura;
  int codMoneda;
  double tipoCambio;
  bool exonerar;
  String observaciones;
  int idVendedor;
  bool apertado;
  String hora;
  double subTotal;
  double totalDescuento;
  double totalImpuesto;
  double subTotalGravado;
  double subTotalExento;
  double total;
  int idBodega;
  String autorizacionFEL;
  String numeroFEL;
  String serieFEL;
  bool electronica;
  String emisionFEL;
  String qr;
  String totalLetras;
  int noAbonos;
  double montoAbonos; 
  String contacto; 
  String telContacto; 
  String anuladoPor;
  String nombrePaciente; 
  String nitFacturado;
  String nombreFacturado; 
  String direccionFacturado;
  bool dpi;
  bool recibido;
  String noGuia;
  String notas;
  int idTranspote; 
  int cantidadCuotas;


  Ventas({
    required this.id,
    required this.nFactura,
    required this.tipo,
    required this.fecha,
    required this.vence,
    required this.codCLiente,
    required this.nombreCliente,
    required this.idUsuario,
    required this.anulado,
    required this.facturaCancelado,
    required this.numApertura,
    required this.codMoneda,
    required this.tipoCambio,
    required this.exonerar,
    required this.observaciones,
    required this.idVendedor,
    required this.apertado,
    required this.hora,
    required this.subTotal,
    required this.totalDescuento,
    required this.totalImpuesto,
    required this.subTotalGravado,
    required this.subTotalExento,
    required this.total,
    required this.idBodega,
    required this.autorizacionFEL,
    required this.numeroFEL,
    required this.serieFEL,
    required this.electronica,
    required this.emisionFEL,
    required this.qr,
    required this.totalLetras,
    required this.noAbonos,
    required this.montoAbonos,
    required this.contacto,
    required this.telContacto,
    required this.anuladoPor,
    required this.nombrePaciente,
    required this.nitFacturado,
    required this.nombreFacturado,
    required this.direccionFacturado,
    required this.dpi,
    required this.recibido,
    required this.noGuia,
    required this.notas,
    required this.idTranspote,
    required this.cantidadCuotas

  });
  factory Ventas.fromJson(Map<String, dynamic> json) {
    return Ventas(
      id: json['Id'] as int,
      nFactura: json['NFactura'] as int,
      tipo: json['Tipo'] as String,
      fecha: json['Fecha'] as String,
      vence: json['Vence'] as String,
      codCLiente: json['CodCLiente'] as int,
      nombreCliente: json['NombreCliente'] as String,
      idUsuario: json['IdUsuario'] as int,
      anulado: json['Anulado'] as bool,
      facturaCancelado: json['FacturaCancelado'] as bool,
      numApertura: json['NumApertura'] as int,
      codMoneda: json['CodMoneda'] as int,
      tipoCambio:
          (json['TipoCambio'] as num).toDouble(), // Aseguramos que sea double
      exonerar: json['Exonerar'] as bool,
      observaciones: json['Observaciones'] as String,
      idVendedor: json['IdVendedor'] as int,
      apertado: json['Apertado'] as bool,
      hora: json['Hora'] as String,
      subTotal: (json['SubTotal'] as num).toDouble(),
      totalDescuento: (json['TotalDescuento'] as num).toDouble(),
      totalImpuesto: (json['TotalImpuesto'] as num).toDouble(),
      subTotalGravado: (json['SubTotalGravado'] as num).toDouble(),
      subTotalExento: (json['SubTotalExento'] as num).toDouble(),
      total: (json['Total'] as num).toDouble(),
      idBodega: json['IdBodega'] as int,
      autorizacionFEL: json['AutorizacionFEL'] as String,
      numeroFEL: json['NumeroFEL'] as String,
      serieFEL: json['SerieFEL'] as String,
      electronica: json['Electronica'] as bool,
      emisionFEL: json['EmisionFEL'] as String,
      qr: json['QR'] as String,
      totalLetras: json['TotalLetras'] as String,
      noAbonos: json['NoAbonos'] as int,
      montoAbonos: (json['MontoAbonos'] as num).toDouble(),
      contacto: json['Contacto'] as String,
      telContacto: json['TelContacto'] as String,
      anuladoPor: json['AnuladoPor'] as String,
      nombrePaciente: json['NombrePaciente'] as String,
      nitFacturado: json['NitFacturado'] as String,
      nombreFacturado: json['NombreFacturado'] as String,
      direccionFacturado: json['DireccionFacturado'] as String,
      dpi: json['DPI'] as bool,
      recibido: json['Recibido'] as bool,
      noGuia: json['NoGuia'] as String,
      notas: json['Notas'] as String,
      idTranspote: json['IdTranspote'] as int,
      cantidadCuotas: json['CantidadCuotas'] as int
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'NFactura': nFactura,
      'Tipo': tipo,
      'Fecha': fecha,
      'Vence': vence,
      'CodCLiente': codCLiente,
      'NombreCliente': nombreCliente,
      'IdUsuario': idUsuario,
      'Anulado': anulado,
      'FacturaCancelado': facturaCancelado,
      'NumApertura': numApertura,
      'CodMoneda': codMoneda,
      'TipoCambio': tipoCambio, // Double se maneja correctamente
      'Exonerar': exonerar,
      'Observaciones': observaciones,
      'IdVendedor': idVendedor,
      'Apertado': apertado,
      'Hora': hora,
      'SubTotal': subTotal,
      'TotalDescuento': totalDescuento,
      'TotalImpuesto': totalImpuesto,
      'SubTotalGravado': subTotalGravado,
      'SubTotalExento': subTotalExento,
      'Total': total,
      'IdBodega': idBodega,
      'AutorizacionFEL': autorizacionFEL,
      'NumeroFEL': numeroFEL,
      'SerieFEL': serieFEL,
      'Electronica': electronica,
      'EmisionFEL': emisionFEL,
      'QR': qr,
      'TotalLetras': totalLetras,
      'NoAbonos': noAbonos,
      'MontoAbonos': montoAbonos,
      'Contacto': contacto,
      'TelContacto': telContacto,
      'AnuladoPor': anuladoPor,
      'NombrePaciente': nombrePaciente,
      'NITFacturado': nitFacturado,
      'NombreFacturado': nombreFacturado,
      'DireccionFacturado': direccionFacturado,
      'DPI': dpi,
      'Recibido': recibido,
      'NoGuia': noGuia,
      'Notas': notas,
      'IdTranspote': idTranspote,
      'CantidadCuotas': cantidadCuotas
    };
  }
}
