import 'package:flutter/material.dart';

class PaginaRegistrar extends StatelessWidget {
  const PaginaRegistrar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Label:', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10), // Espacio entre el label y el botón
                ElevatedButton(
                  onPressed: () {
                    // Acción del botón
                  },
                  child: const Text('Botón'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
