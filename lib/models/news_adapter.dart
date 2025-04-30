import 'package:intl/intl.dart';
import 'news.dart';
import 'news_model.dart';
import '../utils/constants.dart';

class NewsAdapter {
  static NewsModel newsToNewsModel(News news) {
    return NewsModel(
      id: int.tryParse(news.id) ?? 0,
      title: news.title,
      description: news.summary,
      content: news.content,
      imageUrl: news.imageUrl,
      publishedAt: news.publishDate.toIso8601String(),
      source: news.source,
      url: '${AppConstants.appDeepLinkPrefix}/news/${news.id}',
      isBookmarked: false,
    );
  }

  static News newsModelToNews(NewsModel model) {
    final DateTime publishDate =
        DateTime.tryParse(model.publishedAt) ?? DateTime.now();

    return News(
      id: model.id.toString(),
      title: model.title,
      summary: model.description,
      content: model.content,
      imageUrl: model.imageUrl,
      source: model.source,
      category: model.source,
      publishDate: publishDate,
      authorName: "Unknown",
      viewCount: 0,
    );
  }

  static String formatDate(String dateIsoString) {
    try {
      final DateTime date = DateTime.parse(dateIsoString);
      final DateFormat formatter = DateFormat('dd MMM yyyy');
      return formatter.format(date);
    } catch (e) {
      return dateIsoString;
    }
  }
}
