import 'package:flutter/material.dart';
import 'seleccionar_producto.dart';

class PaginaPedidos extends StatelessWidget {
  const PaginaPedidos({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String _selectedSalesperson = 'Vendedor 1';
    String _selectedClient = 'Cliente 1';
    DateTime _selectedDate = DateTime.now();
    final List<String> _selectedProducts = [];
    String _observations = '';

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedSalesperson,
              onChanged: (newValue) {
                // Aquí puedes manejar el cambio de vendedor seleccionado
              },
              items: ['Vendedor 1', 'Vendedor 2', 'Vendedor 3']
                  .map((vendedor) {
                    return DropdownMenuItem(
                      value: vendedor,
                      child: Text(vendedor),
                    );
                  }).toList(),
              decoration: const InputDecoration(
                labelText: 'Vendedor',
              ),
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _selectedClient,
              onChanged: (newValue) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => seleccionar_producto()), // Navega a la pantalla de selección de productos
                );
              },
              items: ['Cliente 1', 'Cliente 2', 'Cliente 3']
                  .map((cliente) {
                    return DropdownMenuItem(
                      value: cliente,
                      child: Text(cliente),
                    );
                  }).toList(),
              decoration: const InputDecoration(
                labelText: 'Cliente',
              ),
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                const Text('Fecha de Entrega: '),
                const SizedBox(width: 8.0),
                InkWell(
                  onTap: () {
                    _selectDate(context);
                  },
                  child: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: null,
              onChanged: (newValue) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => seleccionar_producto()), // Navega a la pantalla de selección de productos
                );
              },
              items: ['Producto 1', 'Producto 2', 'Producto 3']
                  .map((producto) {
                    return DropdownMenuItem(
                      value: producto,
                      child: Text(producto),
                    );
                  }).toList(),
              decoration: const InputDecoration(
                labelText: 'Producto',
              ),
            ),
            // Resto del contenido del segundo código
            const SizedBox(height: 16.0),
            TextField(
              onChanged: (value) {
                _observations = value;
              },
              decoration: const InputDecoration(
                labelText: 'Observaciones',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Aquí puedes agregar la lógica para agregar el pedido
                // a tu sistema o enviarlo a tu API
              },
              child: const Text('Agregar Pedido'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      // Actualiza la fecha seleccionada
     
    }
  }
}
