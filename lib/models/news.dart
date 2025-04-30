import 'package:intl/intl.dart';

class News {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String imageUrl;
  final String source;
  final String category;
  final DateTime publishDate;
  final String authorName;
  final String? authorImageUrl;
  final int viewCount;
  final List<String>? tags;

  News({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.imageUrl,
    required this.source,
    required this.category,
    required this.publishDate,
    required this.authorName,
    this.authorImageUrl,
    this.viewCount = 0,
    this.tags,
  });

  String get formattedDate {
    final formatter = DateFormat('dd MMM yyyy');
    return formatter.format(publishDate);
  }

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String,
      source: json['source'] as String,
      category: json['category'] as String,
      publishDate: DateTime.parse(json['publishDate'] as String),
      authorName: json['authorName'] as String,
      authorImageUrl: json['authorImageUrl'] as String?,
      viewCount: json['viewCount'] as int? ?? 0,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'content': content,
      'imageUrl': imageUrl,
      'source': source,
      'category': category,
      'publishDate': publishDate.toIso8601String(),
      'authorName': authorName,
      'authorImageUrl': authorImageUrl,
      'viewCount': viewCount,
      'tags': tags,
    };
  }
}
