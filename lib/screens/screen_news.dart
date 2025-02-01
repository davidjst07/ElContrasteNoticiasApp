import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart'; // Importa el paquete logger

// Instancia global de Logger para manejar registros
final logger = Logger();

class NoticiasPage extends StatefulWidget {
  const NoticiasPage({super.key});

  @override
  NoticiasPageState createState() => NoticiasPageState();
}

class NoticiasPageState extends State<NoticiasPage> {
  List<Map<String, String>> noticias = [];
  bool isLoading = true; // Indicador de carga

  @override
  void initState() {
    super.initState();
    fetchNoticias();
  }

  Future<void> fetchNoticias() async {
    try {
      final response = await http.get(Uri.parse('https://elcontraste.co/wp-json/wp/v2/posts?_embed'));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        if (mounted) {
          setState(() {
            noticias = data.map((item) {
              final title = item['title']['rendered'] as String;
              final image = item['_embedded']['wp:featuredmedia']?[0]['source_url'] as String? ?? '';
              final link = item['link'] as String;
              return {'title': title, 'image': image, 'url': link};
            }).toList();
            isLoading = false; // Finaliza la carga
          });
        }
      } else {
        logger.e('Error al cargar noticias: ${response.statusCode}');
        if (mounted) {
          setState(() {
            isLoading = false; // Finaliza la carga incluso si hay un error
          });
        }
      }
    } catch (e) {
      logger.e('Error al obtener las noticias: $e');
      if (mounted) {
        setState(() {
          isLoading = false; // Finaliza la carga incluso si hay un error
        });
      }
    }
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      logger.e('No se pudo abrir $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagen de fondo con opacidad
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/2.png'),
                fit: BoxFit.cover,
                //colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
              ),
            ),
          ),
          // Contenido principal con desplazamiento
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo en la parte superior
                const SizedBox(height: 320),
                /*Align(
                  alignment: Alignment.topCenter,
                  child: Image.asset(
                    'assets/log_el_contraste_noticias_blanco.png', // Reemplaza con la ruta de tu logo
                    width: 300,
                    height: 200,
                  ),
                ),*/
                const SizedBox(height: 20),
                // Carrusel de noticias
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  )
                else if (noticias.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      "No hay noticias disponibles",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  )
                else
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 290,
                      autoPlay: true,
                      enlargeCenterPage: true,
                    ),
                    items: noticias.map((noticia) {
                      return GestureDetector(
                        onTap: () => _launchURL(noticia['url']!),
                        child: Card(
                          color: const Color(0xFF1d2969).withOpacity(0.9),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                          child: Column(
                            children: [
                              if (noticia['image'] != null && noticia['image']!.isNotEmpty)
                                Image.network(
                                  noticia['image']!,
                                  fit: BoxFit.cover,
                                  height: 190,
                                  width: double.infinity,
                                ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  noticia['title']!,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                // Texto adicional debajo del carrusel
                const SizedBox(height: 10),
                const Text(
                  "Para más información pulsa la imagen",
                  style: TextStyle(
                    color: Color(0xFF1d2969),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 20), // Espaciado inferior
              ],
            ),
          ),
        ],
      ),
    );
  }
}