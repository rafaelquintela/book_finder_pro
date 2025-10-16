import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_finder_pro/presentation/search/search_screen.dart';
import 'package:book_finder_pro/presentation/favorites/favorites_screen.dart';
import 'package:book_finder_pro/presentation/design_system/design_system_screen.dart';

/// Tela principal que gerencia a navegação por abas (Buscar, Favoritos, Design System).
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;
  
  static final List<Widget> _widgetOptions = <Widget>[
    const SearchScreen(),
    const FavoritesScreen(),
    const DesignSystemScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Buscar',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          NavigationDestination(
            icon: Icon(Icons.style),
            label: 'Design System',
          ),
        ],
      ),
    );
  }
}
