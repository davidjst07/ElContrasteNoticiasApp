import 'package:flutter/material.dart';

class ContactoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        title: const Text('Contacto'),
      ),*/
      body: Stack(
        children: <Widget>[
          // Fondo con imagen GIF
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/radiofondo1.gif'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Contenido de la página de contacto
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 500), // Espaciado para que no quede pegado arriba
                const Text(
                  'Contáctanos',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text('📧 Email: info@elcontraste.co',
                    style: TextStyle(fontSize: 16)),
                const SizedBox(height: 5),
                const Text('📞 Teléfono: +57 313 690 28 21',
                    style: TextStyle(fontSize: 16)),
                const SizedBox(height: 5),
                GestureDetector(
                  onTap: () {
                    // Abre el enlace en el navegador
                  },
                  child: const Text(
                    '🌐 Sitio Web: https://elcontraste.co',
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
