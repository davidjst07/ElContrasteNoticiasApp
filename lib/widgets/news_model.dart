class News {
  final int id;
  final String title;
  final String content;
  final String imageUrl;
  final String date;
  final String author;
  final DateTime publishDate;

  News({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.publishDate,
    this.date = '',
    this.author = '',
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'],
      title: json['title']['rendered'],
      content: json['content']['rendered'],
      imageUrl: json['_embedded']?['wp:featuredmedia']?[0]['source_url'] ?? '',
      publishDate: DateTime.parse(json['date']),
      date: json['date'] ?? '',
      author: json['_embedded']?['author']?[0]['name'] ?? '',
    );
  }
}