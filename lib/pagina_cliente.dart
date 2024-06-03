import 'package:flutter/material.dart';
import 'package:sync_pro_mobile/crear_cliente.dart';

class PaginaCliente extends StatelessWidget {
  const PaginaCliente({super.key});

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
widthFactor: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, 
            backgroundColor: Colors.blue, padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Color del texto
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 5,
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => CrearCliente())
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_add_alt_rounded, color: Colors.white),
              SizedBox(width: 8), // Espacio entre el icono y el texto
              Text(
                'Nuevo Cliente',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );

  }
}
