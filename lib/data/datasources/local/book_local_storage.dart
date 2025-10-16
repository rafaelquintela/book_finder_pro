import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:book_finder_pro/data/models/book_model.dart';
import 'package:flutter/material.dart';

/// Serviço que fornece API simples para persistência local e cache usando SharedPreferences.
class BookLocalStorage {
  static const _favoritesKey = 'favorites_list_json';
  static const _searchCacheKeyPrefix = 'search_cache_';
  static const _themeModeKey = 'theme_mode';
  static const _primaryColorKey = 'primary_color';

  final SharedPreferences _prefs;

  BookLocalStorage._(this._prefs);

  static Future<BookLocalStorage> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    return BookLocalStorage._(prefs);
  }

  // --- Favorites API (serializa como JSON) ---
  List<Book> getFavorites() {
    final jsonStr = _prefs.getString(_favoritesKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
    return list.map((m) => Book.fromJson(m as Map<String, dynamic>)).toList();
  }

  bool isFavorite(String id) => getFavorites().any((b) => b.id == id);

  Future<void> addFavorite(Book book) async {
    final favs = getFavorites();
    favs.removeWhere((b) => b.id == book.id);
    favs.add(book);
    await _prefs.setString(
        _favoritesKey, jsonEncode(favs.map((b) => b.toMap()).toList()));
  }

  Future<void> removeFavorite(String id) async {
    final favs = getFavorites();
    favs.removeWhere((b) => b.id == id);
    await _prefs.setString(
        _favoritesKey, jsonEncode(favs.map((b) => b.toMap()).toList()));
  }

  // --- Search cache API (armazena listas de mapas JSON) ---
  List<Map<String, dynamic>> getSearchCache(String key) {
    final jsonStr = _prefs.getString('$_searchCacheKeyPrefix$key');
    if (jsonStr == null || jsonStr.isEmpty) return [];
    final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
    return List<Map<String, dynamic>>.from(list.cast<Map<String, dynamic>>());
  }

  Future<void> saveSearchCache(String key, List<Book> books) async {
    await _prefs.setString('$_searchCacheKeyPrefix$key',
        jsonEncode(books.map((b) => b.toMap()).toList()));
  }

  // --- Theme API via SharedPreferences ---
  Brightness getThemeMode() {
    final v = _prefs.getString(_themeModeKey);
    if (v == 'dark') return Brightness.dark;
    return Brightness.light;
  }

  Future<void> setThemeMode(Brightness mode) async {
    await _prefs.setString(
        _themeModeKey, mode == Brightness.dark ? 'dark' : 'light');
  }

  Color getCustomPrimaryColor() {
    final v = _prefs.getInt(_primaryColorKey);
    if (v == null) return Colors.blue;
    return Color(v);
  }

  Future<void> setCustomPrimaryColor(Color color) async {
    await _prefs.setInt(_primaryColorKey, color.value);
  }
}

// Providers para inicialização e acesso global
final localStorageInitializerProvider =
    FutureProvider<BookLocalStorage>((ref) async {
  final storage = await BookLocalStorage.initialize();
  return storage;
});

final bookLocalStorageProvider = Provider<BookLocalStorage>((ref) {
  final async = ref.watch(localStorageInitializerProvider);
  return async.value!;
});
