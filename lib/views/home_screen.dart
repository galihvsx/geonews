import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../view_models/theme_view_model.dart';
import 'geocam_screen.dart';
import 'news_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const GeoCamScreen(),
    const NewsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeViewModel = Provider.of<ThemeViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0
            ? AppConstants.geocamTitle
            : AppConstants.newsTitle),
        actions: [
          IconButton(
            icon: Icon(themeViewModel.isDarkMode
                ? Icons.wb_sunny_outlined
                : Icons.dark_mode_outlined),
            onPressed: themeViewModel.toggleTheme,
            tooltip: themeViewModel.isDarkMode
                ? AppConstants.lightMode
                : AppConstants.darkMode,
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: AppConstants.geocamTitle,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: AppConstants.newsTitle,
          ),
        ],
      ),
    );
  }
}
