import 'package:flutter/material.dart';
import 'package:elcontraste_push/screens/screen_news.dart';
import 'package:elcontraste_push/screens/screen_radio.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  _BottomNavigationScreenState createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int _selectedIndex = 0; // Índice de la pantalla seleccionada

  // Lista de pantallas principales
  final List<Widget> _pages = [
    const NoticiasPage(), // Pantalla de noticias
    const ScreenRadio(),  // Pantalla de radio
  ];

  // Método para manejar el cambio de índice
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Muestra la pantalla seleccionada
      bottomNavigationBar: BottomNavigationBar(
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
            backgroundColor: Color.fromARGB(255, 105, 111, 117),
          ),
        ],
      ),
    );
  }
}