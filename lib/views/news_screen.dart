import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';

import '../models/news_adapter.dart';
import '../models/news_model.dart';
import '../utils/constants.dart';
import '../view_models/news_view_model.dart';
import '../widgets/error_widget.dart';
import '../widgets/loading_indicator.dart';
import 'news_detail_screen.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _bookmarkScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<NewsViewModel>(context, listen: false);
      viewModel.fetchNews();
      viewModel.loadBookmarkedNews();
    });
  }

  void _scrollListener() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !Provider.of<NewsViewModel>(context, listen: false).isLoadingMore) {
      Provider.of<NewsViewModel>(context, listen: false).loadMoreNews();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _bookmarkScrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 0,
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withAlpha(100),
            tabs: const [
              Tab(text: AppConstants.latestNews),
              Tab(text: AppConstants.savedNews),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildLatestNewsTab(),
            _buildBookmarkedNewsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildLatestNewsTab() {
    return Consumer<NewsViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading && viewModel.newsList.isEmpty) {
          return const LoadingIndicator(message: AppConstants.loading);
        }

        if (viewModel.newsList.isEmpty) {
          return NoDataWidget(
            message: AppConstants.noNewsAvailable,
            onActionPressed: () => viewModel.fetchNews(),
            actionLabel: AppConstants.refresh,
          );
        }

        return RefreshIndicator(
          onRefresh: () => viewModel.refreshNews(),
          child: AnimationLimiter(
            child: Stack(
              children: [
                ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: viewModel.isLoadingMore
                      ? viewModel.newsList.length + 1
                      : viewModel.newsList.length,
                  itemBuilder: (context, index) {
                    if (index == viewModel.newsList.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    return AnimationConfiguration.staggeredList(
                      position: index,
                      duration: AppConstants.animationDuration,
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: _buildNewsCard(
                            context,
                            viewModel.newsList[index],
                            viewModel,
                          ),
                        ),
                      ),
                    );
                  },
                  controller: _scrollController,
                ),
                if (viewModel.isRefreshing)
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookmarkedNewsTab() {
    return Consumer<NewsViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading && viewModel.bookmarkedNews.isEmpty) {
          return const LoadingIndicator(message: AppConstants.loading);
        }

        if (viewModel.bookmarkedNews.isEmpty) {
          return NoDataWidget(
            message: AppConstants.noBookmarkedNews,
            onActionPressed: () {
              _tabController.animateTo(0);
            },
            actionLabel: AppConstants.browseNews,
          );
        }

        return AnimationLimiter(
          child: RefreshIndicator(
            onRefresh: () => viewModel.loadBookmarkedNews(),
            child: ListView.builder(
              controller: _bookmarkScrollController,
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.bookmarkedNews.length,
              itemBuilder: (context, index) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: AppConstants.animationDuration,
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildNewsCard(
                        context,
                        viewModel.bookmarkedNews[index],
                        viewModel,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildNewsCard(
      BuildContext context, NewsModel newsModel, NewsViewModel viewModel) {
    final isBookmarked = viewModel.isNewsBookmarked(newsModel.id);

    // Konversi ke News untuk NewsDetailScreen
    final news = NewsAdapter.newsModelToNews(newsModel);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // setSelectedNews menerima NewsModel
          viewModel.setSelectedNews(newsModel);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewsDetailScreen(news: news),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.network(
                newsModel.imageUrl,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          newsModel.source,
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Text(
                        NewsAdapter.formatDate(newsModel.publishedAt),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Title
                  Text(
                    newsModel.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Summary
                  Text(
                    newsModel.description,
                    style: TextStyle(
                      color: Colors.grey[700],
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 16),

                  // Source & Bookmark
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Source
                      Row(
                        children: [
                          const Icon(
                            Icons.public,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            newsModel.source,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      // Bookmark button
                      IconButton(
                        onPressed: () {
                          viewModel.toggleBookmark(newsModel);
                        },
                        icon: Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: isBookmarked
                              ? Theme.of(context).primaryColor
                              : null,
                        ),
                        tooltip: isBookmarked
                            ? AppConstants.removeBookmark
                            : AppConstants.addBookmark,
                      ),
                    ],
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
