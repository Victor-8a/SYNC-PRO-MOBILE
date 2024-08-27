import 'package:flutter/material.dart';
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
        title: Text('Configuraciones'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: usarRuta,
                  onChanged: (bool? value) {
                    if (value != null) {
                      _toggleUsaRuta(value);
                    }
                  },
                ),
                Text('Usar Ruta'),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  value: clientesFiltrados,
                  onChanged: (bool? value) {
                    if (value != null) {
                      _toggleClientesFiltrados(value);
                    }
                  },
                ),
                Text('Clientes Filtrados'),
              ],
            ),
            ElevatedButton(
              onPressed: saveconfiguraciones,
              child: Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
