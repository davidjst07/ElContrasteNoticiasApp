import 'package:ElContrasteApp/widgets/news_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart'; // Para formatear fechas

class NewsDetailPage extends StatefulWidget {
  final News news;

  const NewsDetailPage({Key? key, required this.news}) : super(key: key);

  @override
  _NewsDetailPageState createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  final ScrollController _scrollController = ScrollController();
  double _opacity = 0.0;
  double _logoOpacity = 1.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollEffects);
  }

  void _updateScrollEffects() {
    final offset = _scrollController.offset;
    final newOpacity = (offset / 100).clamp(0, 1).toDouble();
    final newLogoOpacity = 1 - (offset / 50).clamp(0, 1).toDouble();
    
    if (newOpacity != _opacity || newLogoOpacity != _logoOpacity) {
      setState(() {
        _opacity = newOpacity;
        _logoOpacity = newLogoOpacity;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateScrollEffects);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B375E).withOpacity(_opacity),
        elevation: _opacity > 0.1 ? 4 : 0,
        title: Row(
          children: [
            Opacity(
              opacity: _opacity,
              child: Image.asset(
                'assets/c.png',
                height: 30,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.news.title,
                style: TextStyle(
                  color: Colors.white.withOpacity(_opacity),
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        iconTheme: IconThemeData(
          color: Colors.white.withOpacity(_opacity),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: NotificationListener<ScrollUpdateNotification>(
        onNotification: (notification) {
          _updateScrollEffects();
          return false;
        },
        child: Stack(
          children: [
            // Fondo azul estático en la parte superior
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).padding.top + kToolbarHeight,
              child: Container(
                color: const Color(0xFF0B375E),
              ),
            ),
            
            SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  // Espacio superior con logo sobre el fondo azul
                  SizedBox(
                    height: MediaQuery.of(context).padding.top + kToolbarHeight,
                    child: Center(
                      child: Opacity(
                        opacity: _logoOpacity,
                        child: Image.asset(
                          'assets/c.png',
                          height: 40,
                        ),
                      ),
                    ),
                  ),
                  
                  if (widget.news.imageUrl.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.news.imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  
                  // Fecha de publicación
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, 
                            size: 16, 
                            color: Color(0xFF0B375E)),
                        const SizedBox(width: 8),
                        Text(
                          'Publicado el ${DateFormat('dd MMMM yyyy', 'es').format(widget.news.publishDate)}',
                          style: const TextStyle(
                            color: Color(0xFF0B375E),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Html(
                      data: widget.news.content,
                      style: {
                        "body": Style(
                          fontSize: FontSize(18.0),
                          color: Colors.black87,
                          padding: HtmlPaddings.zero,
                        ),
                        "img": Style(
                          width: Width(MediaQuery.of(context).size.width - 32),
                          height: Height.auto(),
                          padding: HtmlPaddings.only(bottom: 10),
                          alignment: Alignment.center,
                        ),
                      },
                      extensions: [
                        TagExtension(
                          tagsToExtend: {"img"},
                          builder: (extensionContext) => ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width,
                            ),
                            child: InteractiveViewer(
                              minScale: 0.5,
                              maxScale: 3.0,
                              child: Image.network(
                                extensionContext.attributes["src"] ?? "",
                                fit: BoxFit.contain,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.broken_image, size: 50),
                              ),
                            ),
                          ),
                        ),
                      ],
                      onLinkTap: (url, _, __) {
                        if (url != null) {
                          launchUrl(
                            Uri.parse(url),
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}