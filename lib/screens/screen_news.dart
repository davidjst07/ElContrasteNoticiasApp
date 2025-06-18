import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ElContrasteApp/screens/news_detail_page.dart';
import 'package:ElContrasteApp/widgets/news_model.dart';

final logger = Logger();

class NoticiasPage extends StatefulWidget {
  const NoticiasPage({super.key});

  @override
  NoticiasPageState createState() => NoticiasPageState();
}

class NoticiasPageState extends State<NoticiasPage> {
  final CancelToken _cancelToken = CancelToken();
  Map<int, String> categorias = {};
  Map<String, List<Map<String, String>>> noticiasPorCategoria = {};
  List<Map<String, String>> ultimasNoticias = [];
  bool isLoading = true;
  String? _selectedCategory;

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
    if (!mounted) return;
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
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final cats = await fetchCategorias();
      if (!mounted) return;

      setState(() {
        categorias = cats;
      });

      await Future.wait([
        fetchUltimasNoticias(),
        fetchNoticias(),
      ]);

      if (!mounted) return;

      final sortedCategories = _getCustomSortedCategories();
      setState(() {
        isLoading = false;
        _selectedCategory =
            sortedCategories.isNotEmpty ? sortedCategories.first : null;
      });
    } catch (e) {
      logger.e('Error en _loadData: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> fetchUltimasNoticias() async {
    try {
      final response = await Dio().get(
        'https://elcontraste.co/wp-json/wp/v2/posts?_embed&per_page=5',
        cancelToken: _cancelToken,
      );

      if (response.statusCode == 200) {
        final List data = response.data;
        setState(() {
          ultimasNoticias = data.map((item) {
            return {
              'id': item['id'].toString(),
              'title': item['title']['rendered'] as String,
              'content': item['content']['rendered'] as String,
              'image': item['_embedded']['wp:featuredmedia']?[0]['source_url']
                      as String? ??
                  '',
              'date': item['date'] as String? ?? '',
              'author':
                  item['_embedded']?['author']?[0]['name'] as String? ?? '',
              'category': getCategoryName(item['categories'][0]),
            };
          }).toList();
        });
      }
    } catch (e) {
      logger.e('Error al obtener últimas noticias: $e');
    }
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
      }
    } catch (e) {
      logger.e('Error al obtener categorías: $e');
    }
    return categorias;
  }

  Future<void> fetchNoticias() async {
    try {
      final tempNoticiasPorCategoria = <String, List<Map<String, String>>>{};

      for (var categoria in categorias.entries) {
        final response = await Dio().get(
          'https://elcontraste.co/wp-json/wp/v2/posts?_embed&categories=${categoria.key}&per_page=5',
          cancelToken: _cancelToken,
        );

        if (response.statusCode == 200) {
          final List data = response.data;
          if (data.isNotEmpty) {
            tempNoticiasPorCategoria[categoria.value] = data.map((item) {
              return {
                'id': item['id'].toString(),
                'title': item['title']['rendered'] as String,
                'content': item['content']['rendered'] as String,
                'image': item['_embedded']['wp:featuredmedia']?[0]['source_url']
                        as String? ??
                    '',
                'date': item['date'] as String? ?? '',
                'author':
                    item['_embedded']?['author']?[0]['name'] as String? ?? '',
              };
            }).toList();
          }
        }
      }

      if (mounted) {
        setState(() {
          noticiasPorCategoria = tempNoticiasPorCategoria;
        });
      }
    } catch (e) {
      logger.e('Error en fetchNoticias: $e');
      if (mounted) {
        setState(() {
          noticiasPorCategoria = {};
        });
      }
      rethrow;
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
    for (var category in noticiasPorCategoria.keys) {
      if (!sortedCategories.contains(category)) {
        sortedCategories.add(category);
      }
    }
    return sortedCategories;
  }

  Widget _buildNewsCarousel(List<Map<String, String>> noticias,
      {bool isLatest = false}) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 245,
        autoPlay: isLatest,
        enlargeCenterPage: true,
      ),
      items: noticias.map((noticia) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NewsDetailPage(
                  news: News(
                    id: int.parse(noticia['id'] ?? '0'),
                    title: noticia['title'] ?? '',
                    content: noticia['content'] ?? '',
                    imageUrl: noticia['image'] ?? '',
                    publishDate: DateTime.parse(noticia['date'] ?? ''),
                  ),
                ),
              ),
            );
          },
          child: Card(
            color: const Color(0xFF1d2969).withOpacity(0.9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
            child: Column(
              children: [
                if (noticia['image'] != null && noticia['image']!.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    child: Image.network(
                      noticia['image']!,
                      fit: BoxFit.cover,
                      height: 190,
                      width: double.infinity,
                    ),
                  ),
                const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "LEER MÁS",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
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
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 2),
        child: Text(
          _selectedCategory!.toUpperCase(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0B375E),
          ),
        ),
      ),
      ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: noticias.length,
        itemBuilder: (context, index) {
          final noticia = noticias[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewsDetailPage(
                    news: News(
                      id: int.parse(noticia['id'] ?? '0'),
                      title: noticia['title'] ?? '',
                      content: noticia['content'] ?? '',
                      imageUrl: noticia['image'] ?? '',
                      publishDate: DateTime.parse(noticia['date'] ?? ''),
                    ),
                  ),
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.only(
                left: 16, 
                right: 16,
                bottom: 8,
                top: index == 0 ? 0 : 8,
            ),
              child: Card(
                color: const Color(0xFF1d2969).withOpacity(0.9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                child: Column(
                  children: [
                    if (noticia['image']?.isNotEmpty ?? false)
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                        child: Image.network(
                          noticia['image']!,
                          fit: BoxFit.cover,
                          height: 195,
                          width: double.infinity,
                        ),
                      ),
                    /*const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        noticia['title'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),*/
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        "LEER MÁS",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            collapsedHeight: kToolbarHeight,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.asset(
                'assets/2b.png',
                fit: BoxFit.cover,
              ),
              collapseMode: CollapseMode.pin,
            ),
            pinned: true,
            backgroundColor: Colors.blue,
            elevation: 4,
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    "ÚLTIMAS NOTICIAS",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B375E),
                    ),
                  ),
                ),
                if (ultimasNoticias.isNotEmpty)
                  _buildNewsCarousel(ultimasNoticias, isLatest: true)
                else
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _getCustomSortedCategories().map((categoria) {
                  return Padding(
                    padding: const EdgeInsets.all(2.0),
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
                            ? Colors.white
                            : const Color.fromARGB(255, 55, 55, 56),
                        minimumSize: const Size(80, 30),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
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
          SliverList(
            delegate: SliverChildListDelegate([
              if (!isLoading && _selectedCategory != null)
                ..._buildNewsForSelectedCategory(),
              if (!isLoading && _selectedCategory == null)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("No hay categorías disponibles"),
                ),
            ]),
          ),
        ],
      ),
    );
  }
}
