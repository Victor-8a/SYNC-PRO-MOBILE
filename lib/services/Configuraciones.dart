import 'package:flutter/material.dart';
import 'package:sync_pro_mobile/db/dbConfiguraciones.dart';

class ConfiguracionesPage extends StatefulWidget {
  @override
  _ConfiguracionesPageState createState() => _ConfiguracionesPageState();
}

class _ConfiguracionesPageState extends State<ConfiguracionesPage> {
  final DatabaseHelperConfiguraciones dbHelper = DatabaseHelperConfiguraciones();
  bool usarRuta = false;

  @override
  void initState() {
    super.initState();
    _loadUsaRuta();
  }

  Future<void> _loadUsaRuta() async {
    bool value = await dbHelper.getUsaRuta();
    setState(() {
      usarRuta = value;
    });
  }

  void _toggleUsaRuta(bool value) {
    setState(() {
      usarRuta = value;
    });
  }

  Future<void> _saveUsaRuta() async {
    await dbHelper.setUsaRuta(usarRuta);
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
            ElevatedButton(
              onPressed: _saveUsaRuta,
              child: Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
