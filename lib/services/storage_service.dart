import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/geocam_model.dart';
import '../models/news_model.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();

  factory StorageService() => _instance;

  StorageService._internal();

  static const String _geocamKey = 'geocam_data';
  static const String _bookmarkedNewsKey = 'bookmarked_news';

  Future<bool> saveGeoCamData(GeoCamModel data) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_geocamKey, jsonEncode(data.toJson()));
    } catch (e) {
      if (kDebugMode) {
        print('Error saving GeoCam data: $e');
      }
      return false;
    }
  }

  Future<GeoCamModel?> getGeoCamData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? dataString = prefs.getString(_geocamKey);

      if (dataString == null || dataString.isEmpty) {
        return null;
      }

      final Map<String, dynamic> dataMap = jsonDecode(dataString);
      return GeoCamModel.fromJson(dataMap);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting GeoCam data: $e');
      }
      return null;
    }
  }

  Future<bool> clearGeoCamData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_geocamKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing GeoCam data: $e');
      }
      return false;
    }
  }

  Future<bool> saveBookmarkedNews(List<NewsModel> news) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String> newsJsonList =
          news.map((item) => jsonEncode(item.toJson())).toList();
      return await prefs.setStringList(_bookmarkedNewsKey, newsJsonList);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving bookmarked news: $e');
      }
      return false;
    }
  }

  Future<bool> addBookmarkedNews(NewsModel news) async {
    try {
      final List<NewsModel> currentBookmarks = await getBookmarkedNews();

      final int existingIndex =
          currentBookmarks.indexWhere((item) => item.id == news.id);
      if (existingIndex >= 0) {
        currentBookmarks[existingIndex] = news;
      } else {
        news.isBookmarked = true;
        currentBookmarks.add(news);
      }

      return await saveBookmarkedNews(currentBookmarks);
    } catch (e) {
      if (kDebugMode) {
        print('Error adding bookmarked news: $e');
      }
      return false;
    }
  }

  Future<List<NewsModel>> getBookmarkedNews() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<String>? newsJsonList =
          prefs.getStringList(_bookmarkedNewsKey);

      if (newsJsonList == null || newsJsonList.isEmpty) {
        return [];
      }

      return newsJsonList.map((jsonString) {
        final Map<String, dynamic> itemMap = jsonDecode(jsonString);
        final NewsModel news = NewsModel.fromJson(itemMap);
        news.isBookmarked = true;
        return news;
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting bookmarked news: $e');
      }
      return [];
    }
  }

  Future<bool> removeBookmarkedNews(int newsId) async {
    try {
      final List<NewsModel> currentBookmarks = await getBookmarkedNews();
      final List<NewsModel> updatedBookmarks =
          currentBookmarks.where((item) => item.id != newsId).toList();

      return await saveBookmarkedNews(updatedBookmarks);
    } catch (e) {
      if (kDebugMode) {
        print('Error removing bookmarked news: $e');
      }
      return false;
    }
  }

  Future<bool> isNewsBookmarked(int newsId) async {
    try {
      final List<NewsModel> bookmarkedNews = await getBookmarkedNews();
      return bookmarkedNews.any((item) => item.id == newsId);
    } catch (e) {
      if (kDebugMode) {
        print('Error checking if news is bookmarked: $e');
      }
      return false;
    }
  }

  Future<bool> clearAllBookmarkedNews() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_bookmarkedNewsKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing all bookmarked news: $e');
      }
      return false;
    }
  }
}
