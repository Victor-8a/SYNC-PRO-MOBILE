class Detalleventa {
int id;
int idFactura;
int codArticulo;
String descripcion;
double cantidad; 
double unidades; 
double paquetes; 
double costo; 
double precioVenta;
double precioMayoreo;
double porcDedscuento;
double totalDescuento;
double porcImpuesto; 
double totalImpuesto; 
double subTotalGravado; 
double subTotalExento;
double total; 
int idBodega; 
int codMoneda;
int maxDesc; 
int regalias;
double porcComision;
int idLote;
int idUsuario;
bool compuesto;
double bonifUnit; 
double bonifPaq;
bool mayoreoMenudeo;


Detalleventa({  
  required this.id,
  required this.idFactura,
  required this.codArticulo,
  required this.descripcion,
  required this.cantidad,
  required this.unidades,
  required this.paquetes,
  required this.costo,
  required this.precioVenta,
  required this.precioMayoreo,
  required this.porcDedscuento,
  required this.totalDescuento,
  required this.porcImpuesto,
  required this.totalImpuesto,
  required this.subTotalGravado,
  required this.subTotalExento,
  required this.total,
  required this.idBodega,
  required this.codMoneda,
  required this.maxDesc,
  required this.regalias,
  required this.porcComision,
  required this.idLote,
  required this.idUsuario,
  required this.compuesto,
  required this.bonifUnit,
  required this.bonifPaq,
  required this.mayoreoMenudeo,

});


Map<String, dynamic> toJson() => {  
  'id': id,         
  'idFactura': idFactura,
  'codArticulo': codArticulo,
  'descripcion': descripcion,
  'cantidad': cantidad,
  'unidades': unidades,
  'paquetes': paquetes,
  'costo': costo,
  'precioVenta': precioVenta,
  'precioMayoreo': precioMayoreo,
  'porcDedscuento': porcDedscuento,
  'totalDescuento': totalDescuento,
  'porcImpuesto': porcImpuesto,
  'totalImpuesto': totalImpuesto,
  'subTotalGravado': subTotalGravado,
  'subTotalExento': subTotalExento,
  'total': total,
  'idBodega': idBodega,
  'codMoneda': codMoneda,
  'maxDesc': maxDesc,
  'regalias': regalias,
  'porcComision': porcComision,
  'idLote': idLote,
  'idUsuario': idUsuario,
  'compuesto': compuesto,
  'bonifUnit': bonifUnit,
  'bonifPaq': bonifPaq,
  'mayoreoMenudeo': mayoreoMenudeo,
};

  factory Detalleventa.fromJson(Map<String, dynamic> json) => Detalleventa(
    id: json['id'],
    idFactura: json['idFactura'],
    codArticulo: json['codArticulo'],
    descripcion: json['descripcion'], 
    cantidad: json['cantidad'],
    unidades: json['unidades'],
    paquetes: json['paquetes'],
    costo: json['costo'],
    precioVenta: json['precioVenta'],
    precioMayoreo: json['precioMayoreo'],
    porcDedscuento: json['porcDedscuento'],
    totalDescuento: json['totalDescuento'],
    porcImpuesto: json['porcImpuesto'],
    totalImpuesto: json['totalImpuesto'],
    subTotalGravado: json['subTotalGravado'],
    subTotalExento: json['subTotalExento'],
    total: json['total'],
    idBodega: json['idBodega'],
    codMoneda: json['codMoneda'],
    maxDesc: json['maxDesc'],
    regalias: json['regalias'],
    porcComision: json['porcComision'],
    idLote: json['idLote'],
    idUsuario: json['idUsuario'],
    compuesto: json['compuesto'],
    bonifUnit: json['bonifUnit'],
    bonifPaq: json['bonifPaq'],
    mayoreoMenudeo: json['mayoreoMenudeo'],

  );

}