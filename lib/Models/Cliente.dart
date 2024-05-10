class Cliente {
  int codCliente;
  String nombre;
  String cedula;
  String direccion;

  Cliente({
    required this.codCliente,
    required this.nombre,
    required this.cedula,
    required this.direccion,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      codCliente: json['CodCliente'],
      nombre: json['Nombre'],
      cedula: json['Cedula'],
      direccion: json['Direccion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codCliente': codCliente,
      'nombre': nombre,
      'cedula': cedula,
      'direccion': direccion
    };}
}