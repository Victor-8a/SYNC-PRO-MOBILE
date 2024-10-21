import 'package:flutter/material.dart';
import 'package:sync_pro_mobile/Pedidos/services/BodegaDescarga.dart';
import 'package:sync_pro_mobile/db/dbConfiguraciones.dart';

class ConfiguracionesPage extends StatefulWidget {
  @override
  _ConfiguracionesPageState createState() => _ConfiguracionesPageState();
}

class _ConfiguracionesPageState extends State<ConfiguracionesPage> {
  final DatabaseHelperConfiguraciones dbHelper =
      DatabaseHelperConfiguraciones();
  bool usarRuta = false;
  bool clientesFiltrados = false;
  bool usarApertura = false;
  int bodegaDescarga = 0;
  List<Map<String, dynamic>> bodegas = []; // Lista para almacenar las bodegas

  @override
  void initState() {
    super.initState();
    _loadUsaRuta();
    _loadClientesFiltrados();
    _loadUsaApertura();
    _loadBodegas(); // Cargamos las bodegas
  }

  Future<void> _loadUsaRuta() async {
    bool value = await dbHelper.getUsaRuta();
    setState(() {
      usarRuta = value;
    });
  }

  Future<void> _loadUsaApertura() async {
    bool value = await dbHelper.getUsaApertura();
    setState(() {
      usarApertura = value;
    });
  }

  Future<void> _loadClientesFiltrados() async {
    bool value = await dbHelper.getClientesFiltrados();
    setState(() {
      clientesFiltrados = value;
    });
  }

  Future<void> _loadBodegas() async {
    try {
      List<Map<String, dynamic>> bodegasList = await fetchBodegaDescarga();
      setState(() {
        bodegas = bodegasList;
        if (bodegas.isNotEmpty) {
          bodegaDescarga = bodegas[0]['id'] ??
              0; // Seleccionamos la primera bodega por defecto
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar las bodegas')),
      );
    }
  }

  void _toggleUsaRuta(bool value) {
    setState(() {
      usarRuta = value;
    });
  }

  void _toggleClientesFiltrados(bool value) {
    setState(() {
      clientesFiltrados = value;
    });
  }

  void _toggleUsaApertura(bool value) {
    setState(() {
      usarApertura = value;
    });
  }

  Future<void> saveconfiguraciones() async {
    await dbHelper.setConfiguracion(
        usarRuta, clientesFiltrados, usarApertura, bodegaDescarga);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Configuración guardada')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Configuraciones',
            style: TextStyle(
              color: Colors.white,
            )),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ajustes Generales',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[800],
                  ),
                ),
                Divider(
                  thickness: 1,
                  color: Colors.indigo[200],
                ),
                SizedBox(height: 20),
                SwitchListTile(
                  value: usarRuta,
                  title: Text(
                    'Usar Ruta',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  activeColor: Colors.blue,
                  onChanged: (bool value) {
                    _toggleUsaRuta(value);
                  },
                ),
                SizedBox(height: 20),
                SwitchListTile(
                  value: clientesFiltrados,
                  title: Text(
                    'Clientes Filtrados',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  activeColor: Colors.blue,
                  onChanged: (bool value) {
                    _toggleClientesFiltrados(value);
                  },
                ),
                SizedBox(height: 20),
                SwitchListTile(
                  value: usarApertura,
                  title: Text(
                    'Usar Apertura de Caja',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  activeColor: Colors.blue,
                  onChanged: (bool value) {
                    _toggleUsaApertura(value);
                  },
                ),
                SizedBox(height: 20),
                // Dropdown para seleccionar la bodega con estilo mejorado
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.blue[800]!, // Color del borde
                      width: 2, // Ancho del borde
                    ),
                    borderRadius:
                        BorderRadius.circular(8), // Bordes redondeados
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: bodegaDescarga,
                      isExpanded:
                          true, // Expande el dropdown a lo ancho del contenedor
                      icon: Icon(Icons.arrow_drop_down,
                          color: Colors.blue[800]), // Icono personalizado
                      onChanged: (int? newValue) {
                        setState(() {
                          bodegaDescarga =
                              newValue ?? 0; // Validamos que no sea nulo
                        });
                      },
                      items: bodegas.map<DropdownMenuItem<int>>((bodega) {
                        return DropdownMenuItem<int>(
                          value: bodega['id'],
                          child: Text(
                            bodega['nombre'],
                            style: TextStyle(
                              fontSize: 16, // Tamaño del texto
                              fontWeight: FontWeight.w500, // Peso del texto
                              color: Colors.blue[800], // Color del texto
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                SizedBox(height: 40),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: saveconfiguraciones,
                    icon: Icon(Icons.save, color: Colors.white),
                    label: Text('Guardar Configuración',
                        style: TextStyle(
                          color: Colors.white,
                        )),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
