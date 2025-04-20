import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RadioPage extends StatefulWidget {
  const RadioPage({super.key});

  @override
  _RadioPageState createState() => _RadioPageState();
}

class _RadioPageState extends State<RadioPage> {
  List<String> imgList = [];

  @override
  void initState() {
    super.initState();
    fetchImages();
  }

 Future<void> fetchImages() async {
  try {
    final response = await http.get(Uri.parse('https://elcontraste.co/wp-json/custom/v1/radio-images'));
    if (response.statusCode == 200) {
      if (mounted) { // ✅ Verifica si el widget sigue montado antes de llamar a setState()
        setState(() {
          imgList = List<String>.from(json.decode(response.body));
        });
      }
    } else {
      print('Error al cargar imágenes');
    }
  } catch (e) {
    print('Error en fetchImages: $e');
  }
}

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/radiofondo1.gif'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.only(top: 440.0),
            child: CarouselSlider(
              options: CarouselOptions(
                height: 325.0,
                autoPlay: true,
                enlargeCenterPage: true,
              ),
              items: imgList.map((item) => Center(
                child: Image.network(item, fit: BoxFit.cover, width: 450),
              )).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
