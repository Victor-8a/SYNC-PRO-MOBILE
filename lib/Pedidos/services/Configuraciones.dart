import 'package:flutter/material.dart';
import 'package:sync_pro_mobile/Pedidos/db/dbConfiguraciones.dart';

class ConfiguracionesPage extends StatefulWidget {
  @override
  _ConfiguracionesPageState createState() => _ConfiguracionesPageState();
}

class _ConfiguracionesPageState extends State<ConfiguracionesPage> {
  final DatabaseHelperConfiguraciones dbHelper = DatabaseHelperConfiguraciones();
  bool usarRuta = false;
  bool clientesFiltrados = false;

  @override
  void initState() {
    _loadUsaRuta();
    _loadClientesFiltrados();
    super.initState();
  }

  Future<void> _loadUsaRuta() async {
    bool value = await dbHelper.getUsaRuta();
    setState(() {
      usarRuta = value;
      clientesFiltrados = value;
    });
  }

  Future<void> _loadClientesFiltrados() async {
    bool value = await dbHelper.getClientesFiltrados();
    setState(() {
      clientesFiltrados = value;
    });
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

  Future<void> saveconfiguraciones() async {
    await dbHelper.setConfiguracion(usarRuta, clientesFiltrados);
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
                SizedBox(height: 40),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: saveconfiguraciones,
                    icon: Icon(Icons.save,
                        color: Colors.white),
                    label: Text('Guardar Configuración',
                        style: TextStyle(
                          color: Colors.white,
                        )),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      padding: EdgeInsets.symmetric(
                          horizontal: 30, vertical: 15),
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
