class Ruta {
  int id;
  int? numRuta;
  int idVendedor;
  int idLocalidad;
  String fechaInicio;
  String fechaFin;
  int? sincronizado;
  int anulado;

  Ruta({
    required this.id,
    this.numRuta,
    required this.idVendedor,
    required this.idLocalidad,
    required this.fechaInicio,
    required this.fechaFin,
    this.sincronizado,
    required this.anulado,
  });

  factory Ruta.fromMap(Map<String, dynamic> map) => Ruta(
        id: map['id'],
           numRuta: map['numRuta'],
        idVendedor: map['idVendedor'],
        idLocalidad: map['idLocalidad'],
        fechaInicio: map['fechaInicio'],
        fechaFin: map['fechaFin'],
        sincronizado: map['sincronizado'],
        anulado: map['anulado'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'idVendedor': idVendedor,
         'numRuta': numRuta,
        'idLocalidad': idLocalidad,
        'fechaInicio': fechaInicio,
        'fechaFin': fechaFin,
        'sincronizado': sincronizado,
        'anulado': anulado,
      };
}
