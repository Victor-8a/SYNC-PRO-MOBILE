class Ruta {
  int id;
  int idVendedor;
  int idLocalidad;
  String fechaInicio;
  String fechaFin;
  int anulado;

  Ruta({
    required this.id,
    required this.idVendedor,
    required this.idLocalidad,
    required this.fechaInicio,
    required this.fechaFin,
    required this.anulado,
  });

  factory Ruta.fromMap(Map<String, dynamic> map) => Ruta(
        id: map['id'],
        idVendedor: map['idVendedor'],
        idLocalidad: map['idLocalidad'],
        fechaInicio: map['fechaInicio'],
        fechaFin: map['fechaFin'],
        anulado: map['anulado'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'idVendedor': idVendedor,
        'idLocalidad': idLocalidad,
        'fechaInicio': fechaInicio,
        'fechaFin': fechaFin,
        'anulado': anulado,
      };
}
