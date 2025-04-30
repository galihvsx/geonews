class NewsModel {
  final int id;
  final String title;
  final String description;
  final String content;
  final String imageUrl;
  final String publishedAt;
  final String source;
  final String url;
  bool isBookmarked;

  NewsModel({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.imageUrl,
    required this.publishedAt,
    required this.source,
    required this.url,
    this.isBookmarked = false,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('articles')) {
      final article = json['articles'][0];
      return NewsModel(
        id: json['articles'].indexOf(article),
        title: article['title'] ?? 'No Title',
        description: article['description'] ?? 'No Description',
        content: article['content'] ?? 'No Content',
        imageUrl: article['urlToImage'] ?? '',
        publishedAt: article['publishedAt'] ?? '',
        source: article['source']['name'] ?? 'Unknown Source',
        url: article['url'] ?? '',
      );
    }

    return NewsModel(
      id: json['id'] ?? 0,
      title: json['title']?.toUpperCase().substring(0, 1) +
              (json['title']?.substring(1) ?? '') ??
          'No Title',
      description: json['body']?.substring(
              0, json['body'].length > 100 ? 100 : json['body'].length) ??
          'No Description',
      content: json['body'] ?? 'No Content',
      imageUrl: 'https://placehold.co/600x400.png',
      publishedAt: DateTime.now().toIso8601String(),
      source: 'JSONPlaceholder',
      url: 'https://jsonplaceholder.typicode.com/posts/${json['id']}',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'imageUrl': imageUrl,
      'publishedAt': publishedAt,
      'source': source,
      'url': url,
      'isBookmarked': isBookmarked,
    };
  }
}

class NewsResponse {
  final List<NewsModel> articles;
  final String status;
  final int totalResults;

  NewsResponse({
    required this.articles,
    required this.status,
    required this.totalResults,
  });

  factory NewsResponse.fromJson(dynamic jsonData) {
    if (jsonData is List) {
      return NewsResponse(
        articles: (jsonData)
            .map((item) => NewsModel.fromJson(item as Map<String, dynamic>))
            .toList(),
        status: 'ok',
        totalResults: jsonData.length,
      );
    }

    final json = jsonData as Map<String, dynamic>;

    if (json.containsKey('articles')) {
      return NewsResponse(
        articles: (json['articles'] as List<dynamic>)
            .map((article) => NewsModel.fromJson({
                  'articles': [article]
                }))
            .toList(),
        status: json['status'] ?? 'unknown',
        totalResults: json['totalResults'] ?? json['articles'].length,
      );
    }

    return NewsResponse(
      articles: [],
      status: 'error',
      totalResults: 0,
    );
  }
}
