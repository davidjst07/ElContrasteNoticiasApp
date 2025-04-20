import 'package:ElContrasteApp/screens/screen_contacto.dart';
import 'package:flutter/material.dart';
import 'package:ElContrasteApp/screens/screen_news.dart';
import 'package:ElContrasteApp/screens/screen_radio.dart';
import 'package:ElContrasteApp/widgets/radio_player.dart';
import 'package:ElContrasteApp/widgets/menuapp.dart'; // Importa el menú

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  _BottomNavigationScreenState createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const NoticiasPage(),
    const RadioPage(),
    ContactoPage(), // Asegúrate de tener esta página creada
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
       //title: const Text('El Contraste Noticias APP'),
       backgroundColor: Colors.transparent,
       automaticallyImplyLeading: false,
       title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Builder(builder: (context) {
            return IconButton (
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          })
        ],
       ),
      ),
      drawer: const MenuApp(), // Agrega el menú aquí
      body: _pages[_selectedIndex],
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 60, // Altura fija para el reproductor
            child: PersistentRadioPlayer(),
          ),
          BottomNavigationBar(
            type: BottomNavigationBarType.shifting,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.newspaper),
                activeIcon: Icon(Icons.perm_device_info_outlined),
                label: 'Noticias',
                backgroundColor: Color(0xFF0B375E),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.radio),
                activeIcon: Icon(Icons.radio_outlined),
                label: 'Radio',
                backgroundColor: Color(0xFF5A6270),
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.contact_page),
                activeIcon: Icon(Icons.contact_page_outlined),
                label: 'Contacto',
                backgroundColor: Color.fromARGB(255, 0, 0, 0),
              ),
            ],
          ),
        ],
      ),
    );
  }
}