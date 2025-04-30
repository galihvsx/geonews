import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/news_model.dart';

class NewsService {
  static final NewsService _instance = NewsService._internal();

  factory NewsService() => _instance;

  NewsService._internal() {
    _dio = Dio();
  }

  late final Dio _dio;

  static const String _jsonPlaceholderUrl =
      'https://jsonplaceholder.typicode.com/posts';

  Future<List<NewsModel>> getNews({int start = 0, int limit = 10}) async {
    try {
      final Response response = await _dio.get(
        _jsonPlaceholderUrl,
        queryParameters: {
          '_start': start,
          '_limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => NewsModel.fromJson(item)).toList();
      } else {
        debugPrint('Error fetching news: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching news: $e');
      return [];
    }
  }

  Future<NewsModel?> getNewsDetail(int id) async {
    try {
      final Response response = await _dio.get('$_jsonPlaceholderUrl/$id');

      if (response.statusCode == 200) {
        final dynamic data = response.data;
        return NewsModel.fromJson(data);
      } else {
        debugPrint('Error fetching news detail: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching news detail: $e');
      return null;
    }
  }
}
