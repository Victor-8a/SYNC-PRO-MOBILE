import 'package:flutter/material.dart';
import 'package:sync_pro_mobile/pagina_pedidos.dart';
// Asegúrate de usar la ruta correcta

class NuevoPedido extends StatelessWidget {
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
            Navigator.push(context, MaterialPageRoute(builder: (context) => PaginaPedidos(cliente: null,))
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shopping_cart, color: Colors.white),
              SizedBox(width: 8), // Espacio entre el icono y el texto
              Text(
                'Realizar Nuevo Pedido',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
