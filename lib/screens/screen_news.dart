import 'package:dio/dio.dart';
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
  CancelToken _cancelToken = CancelToken();

  Map<int, String> categorias = {}; // Almacena las categorías dinámicas
  Map<String, List<Map<String, String>>> noticiasPorCategoria = {};
  bool isLoading = true;

  // Estado para la categoría seleccionada
  String? _selectedCategory;

  // Orden personalizado de categorías
  final List<String> customOrder = [
    "Pasto",
    "Nariño",
    "Deportes",
    "Cauca",
    "Colombia",
    "Mundo"
  ];

  @override
  void dispose() {
    _cancelToken.cancel();
    super.dispose();
  }

  Future<void> _launchURL(String url) async {
    if (!mounted) return; // Verifica si el widget sigue montado
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      logger.e('No se pudo abrir $url');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCategorias().then((categoriasObtenidas) {
      if (mounted) {
        setState(() {
          categorias = categoriasObtenidas;
        });
        fetchNoticias().then((_) {
          if (mounted) {
            // Seleccionar la primera categoría disponible
            final sortedCategories = _getCustomSortedCategories();
            if (sortedCategories.isNotEmpty) {
              setState(() {
                _selectedCategory = sortedCategories.first;
              });
            }
          }
        });
      }
    });
  }

  Future<Map<int, String>> fetchCategorias() async {
    final Map<int, String> categorias = {};
    try {
      final response = await http
          .get(Uri.parse('https://elcontraste.co/wp-json/wp/v2/categories'));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        for (var item in data) {
          final id = item['id'] as int;
          final name = item['name'] as String;
          categorias[id] = name;
        }
      } else {
        logger.e('Error al cargar categorías: ${response.statusCode}');
      }
    } catch (e) {
      logger.e('Error al obtener las categorías: $e');
    }

    if (mounted) {
      setState(() {
        this.categorias = categorias;
      });
    }

    return categorias;
  }

  Future<void> fetchNoticias() async {
    noticiasPorCategoria.clear(); // Limpiar antes de cargar nuevas noticias

    try {
      for (var categoria in categorias.entries) {
        final categoryId = categoria.key;
        final categoryName = categoria.value;

        final response = await Dio().get(
          'https://elcontraste.co/wp-json/wp/v2/posts?_embed&categories=$categoryId&per_page=5',
          cancelToken: _cancelToken,
        );

        if (response.statusCode == 200) {
          final List data = response.data;
          if (data.isNotEmpty) {
            noticiasPorCategoria[categoryName] = data.map((item) {
              return {
                'title': item['title']['rendered'] as String,
                'image': item['_embedded']['wp:featuredmedia']?[0]['source_url']
                        as String? ??
                    '',
                'url': item['link'] as String,
              };
            }).toList();
          }
        } else {
          logger.e(
              'Error al cargar noticias de $categoryName: ${response.statusCode}');
        }
      }

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      logger.e('Error al obtener las noticias: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String getCategoryName(int categoryId) {
    return categorias[categoryId] ?? "General";
  }

  List<String> _getCustomSortedCategories() {
    final sortedCategories = <String>[];
    for (var category in customOrder) {
      if (noticiasPorCategoria.containsKey(category)) {
        sortedCategories.add(category);
      }
    }
    // Agregar categorías restantes al final
    for (var category in noticiasPorCategoria.keys) {
      if (!sortedCategories.contains(category)) {
        sortedCategories.add(category);
      }
    }
    return sortedCategories;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // SliverAppBar para la imagen
          SliverAppBar(
            expandedHeight: 280, // Altura de la imagen
            collapsedHeight: 56.0,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                'assets/2b.png',
                fit: BoxFit.cover,
              ),
              /*title: Opacity(
                opacity: 0.7,
                child: Row(
                  children: [
                    Image.asset(
                      'assets/log_el_contraste_noticias_blanco.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),*/
              titlePadding: EdgeInsets.zero,
              collapseMode: CollapseMode.pin,
            ),
            pinned: true,
          ),
          // Botones de categorías
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _getCustomSortedCategories().map((categoria) {
                  return Padding(
                    padding: const EdgeInsets.all(
                        2.0), // Espacio horizontal reducido
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedCategory = categoria;
                        });
                      },
                      style: ElevatedButton.styleFrom(

                        backgroundColor: _selectedCategory == categoria
                            ? const Color.fromARGB(255, 59, 105, 145)
                            : const Color.fromARGB(255, 184, 187, 190),
                        foregroundColor: _selectedCategory == categoria
                            ? Colors
                                .white // Texto blanco para el botón seleccionado
                            : const Color.fromARGB(255, 55, 55, 56), // Texto blanco para botones no seleccionados
                        minimumSize: const Size(
                            80, 30), // Ancho mínimo de 120 y alto mínimo de 50
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8), // Espaciado interno
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(8), // Bordes redondeados
                        ),
                      ),
                      child: Text(
                        categoria.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Contenido desplazable
          SliverList(
            delegate: SliverChildListDelegate([
              if (isLoading)
                const Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (noticiasPorCategoria.isEmpty)
                const Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Text(
                    "No hay noticias disponibles",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                )
              else if (_selectedCategory == null)
                const Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Text(
                    "Selecciona una categoría",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                )
              else
                ..._buildNewsForSelectedCategory(),
              const SizedBox(height: 20),
            ]),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildNewsForSelectedCategory() {
    final noticias = noticiasPorCategoria[_selectedCategory];
    if (noticias == null || noticias.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            "No hay noticias disponibles en esta categoría",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        )
      ];
    }

    return [
      CarouselSlider(
        options: CarouselOptions(
          height: 245, // Ajusta el tamaño según necesites
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
                  const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      //noticia['title']!
                      "Leer más",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
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
    ];
  }
}
