import 'package:flutter/material.dart';
import '../models/news_model.dart';
import '../services/news_service.dart';
import '../services/storage_service.dart';

class NewsViewModel extends ChangeNotifier {
  final NewsService _newsService = NewsService();
  final StorageService _storageService = StorageService();

  List<NewsModel> _newsList = [];
  List<NewsModel> _bookmarkedNews = [];
  NewsModel? _selectedNews;
  bool _isLoading = false;
  bool _isRefreshing = false;
  bool _isLoadingMore = false;
  int _currentPage = 0;
  final int _itemsPerPage = 10;
  bool _hasMoreData = true;

  List<NewsModel> get newsList => _newsList;
  List<NewsModel> get bookmarkedNews => _bookmarkedNews;
  NewsModel? get selectedNews => _selectedNews;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreData => _hasMoreData;

  bool isNewsBookmarked(int newsId) {
    return _bookmarkedNews.any((news) => news.id == newsId);
  }

  Future<void> addToBookmarks(NewsModel news) async {
    news.isBookmarked = true;
    await _storageService.addBookmarkedNews(news);
    await loadBookmarkedNews();
    notifyListeners();
  }

  Future<void> removeFromBookmarks(int newsId) async {
    await _storageService.removeBookmarkedNews(newsId);
    _bookmarkedNews.removeWhere((item) => item.id == newsId);

    final int index = _newsList.indexWhere((item) => item.id == newsId);
    if (index >= 0) {
      _newsList[index].isBookmarked = false;
    }

    notifyListeners();
  }

  NewsViewModel() {
    _initializeData();
  }

  Future<void> _initializeData() async {
    await loadBookmarkedNews();
    await fetchNews();
  }

  Future<void> loadBookmarkedNews() async {
    _setLoading(true);

    try {
      _bookmarkedNews = await _storageService.getBookmarkedNews();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading bookmarked news: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchNews() async {
    if (_isLoading && !_isRefreshing) return;

    _setLoading(true);

    try {
      final List<NewsModel> news = await _newsService.getNews(
        start: _currentPage * _itemsPerPage,
        limit: _itemsPerPage,
      );

      if (news.isEmpty) {
        _hasMoreData = false;
      } else {
        _currentPage++;

        for (var item in news) {
          item.isBookmarked = await _storageService.isNewsBookmarked(item.id);
        }

        if (_isRefreshing) {
          _newsList = news;
        } else {
          _newsList.addAll(news);
        }
      }
    } catch (e) {
      debugPrint('Error fetching news: $e');
    } finally {
      _setLoading(false);
      _setRefreshing(false);
    }
  }

  Future<void> refreshNews() async {
    _setRefreshing(true);
    _currentPage = 0;
    _hasMoreData = true;
    await fetchNews();
  }

  Future<void> loadMoreNews() async {
    if (_isLoading || !_hasMoreData) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      await fetchNews();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> getNewsDetail(int newsId) async {
    _setLoading(true);

    try {
      final int index = _newsList.indexWhere((item) => item.id == newsId);

      if (index >= 0) {
        _selectedNews = _newsList[index];
      } else {
        final int bookmarkIndex =
            _bookmarkedNews.indexWhere((item) => item.id == newsId);

        if (bookmarkIndex >= 0) {
          _selectedNews = _bookmarkedNews[bookmarkIndex];
        } else {
          _selectedNews = await _newsService.getNewsDetail(newsId);

          if (_selectedNews != null) {
            _selectedNews!.isBookmarked =
                await _storageService.isNewsBookmarked(newsId);
          }
        }
      }
    } catch (e) {
      debugPrint('Error getting news detail: $e');
    } finally {
      _setLoading(false);
    }
  }

  void setSelectedNews(NewsModel news) {
    _selectedNews = news;
    notifyListeners();
  }

  Future<void> toggleBookmark(NewsModel news) async {
    try {
      if (news.isBookmarked) {
        news.isBookmarked = false;
        await _storageService.removeBookmarkedNews(news.id);
        _bookmarkedNews.removeWhere((item) => item.id == news.id);
      } else {
        news.isBookmarked = true;
        await _storageService.addBookmarkedNews(news);
        await loadBookmarkedNews();
      }

      final int index = _newsList.indexWhere((item) => item.id == news.id);
      if (index >= 0) {
        _newsList[index].isBookmarked = news.isBookmarked;
      }

      if (_selectedNews != null && _selectedNews!.id == news.id) {
        _selectedNews!.isBookmarked = news.isBookmarked;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling bookmark: $e');
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setRefreshing(bool value) {
    _isRefreshing = value;
    if (!value) {
      notifyListeners();
    }
  }
}
