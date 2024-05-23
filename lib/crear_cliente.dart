import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CrearCliente extends StatefulWidget {
  const CrearCliente({Key? key}) : super(key: key);

  @override
  _CrearClienteState createState() => _CrearClienteState();
}

class _CrearClienteState extends State<CrearCliente> {
  String _selectedOption = 'CF';
  final _cedulaController = TextEditingController();
  final _nombreController = TextEditingController();
  final _celularController = TextEditingController();
  final _telCasaController = TextEditingController();
  final _telOficinaController = TextEditingController();
  final _direccionController = TextEditingController();
  final _emailController = TextEditingController();
  final _observacionesController = TextEditingController();
  final _nombreContactoController = TextEditingController();
  final _telContactoController = TextEditingController();

  Widget _buildRoundedTextField(TextEditingController controller, String labelText, TextInputType keyboardType) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: Colors.grey,
          width: 1.0,
        ),
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        ),
        keyboardType: keyboardType,
      ),
    );
  }

  void _crearCliente() async {
    bool shouldCreate = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmación'),
          content: const Text('¿Está seguro de que desea agregar el cliente?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Sí'),
            ),
          ],
        );
      },
    );

    if (shouldCreate) {
      // Aquí puedes agregar la lógica para crear el cliente.
      print('Cliente creado');

      // Limpiar los campos después de agregar el cliente.
      _limpiarCampos();
    }
  }

  void _cancelar() async {
    bool shouldCancel = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmación'),
          content: const Text('¿Está seguro de que desea cancelar?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Sí'),
            ),
          ],
        );
      },
    );

    if (shouldCancel) {
      // Limpiar los campos sin regresar atrás.
      _limpiarCampos();
    }
  }

  void _limpiarCampos() {
    setState(() {
      _cedulaController.clear();
      _nombreController.clear();
      _celularController.clear();
      _telCasaController.clear();
      _telOficinaController.clear();
      _direccionController.clear();
      _emailController.clear();
      _observacionesController.clear();
      _nombreContactoController.clear();
      _telContactoController.clear();
      _selectedOption = 'CF';
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool shouldPop = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmación'),
            content: const Text('¿Estás seguro de que quieres salir?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Sí'),
              ),
            ],
          ),
        );
        return shouldPop;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Crear Cliente',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
        ),
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: Colors.blue,
                            width: 1.0,
                          ),
                        ),
                        child: TextFormField(
                          controller: _cedulaController,
                          keyboardType: _selectedOption == 'CF' ? TextInputType.text : TextInputType.number,
                          inputFormatters: _selectedOption == 'CF'
                              ? null
                              : <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(
                                    _selectedOption == 'DPI/CUI'
                                        ? 13
                                        : _selectedOption == 'NIT'
                                            ? 9
                                            : null,
                                  ),
                                ],
                          decoration: InputDecoration(
                            labelText: _selectedOption,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          ),
                          enabled: _selectedOption != 'CF',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    DropdownButton<String>(
                      value: _selectedOption,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedOption = newValue!;
                          _cedulaController.clear();
                          _nombreController.clear();
                        });
                      },
                      items: <String>['CF', 'NIT', 'DPI/CUI']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_selectedOption != 'CF')
                  _buildRoundedTextField(_nombreController, 'Nombre', TextInputType.text),
                const SizedBox(height: 20),
                _buildRoundedTextField(_celularController, 'Celular', TextInputType.phone),
                const SizedBox(height: 20),
                _buildRoundedTextField(_telCasaController, 'Tel. Casa', TextInputType.phone),
                const SizedBox(height: 20),
                _buildRoundedTextField(_telOficinaController, 'Tel. Oficina', TextInputType.phone),
                const SizedBox(height: 20),
                _buildRoundedTextField(_direccionController, 'Dirección', TextInputType.streetAddress),
                const SizedBox(height: 20),
                _buildRoundedTextField(_emailController, 'Correo Electrónico', TextInputType.emailAddress),
                const SizedBox(height: 20),
                _buildRoundedTextField(_observacionesController, 'Observaciones', TextInputType.multiline),
                const SizedBox(height: 20),
                _buildRoundedTextField(_nombreContactoController, 'Nombre de Contacto', TextInputType.text),
                const SizedBox(height: 20),
                _buildRoundedTextField(_telContactoController, 'Tel. Contacto', TextInputType.phone),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _crearCliente,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text(
                        'Crear Cliente',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _cancelar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
