import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:book_finder_pro/data/models/book_model.dart';
import 'package:book_finder_pro/data/datasources/remote/book_api_service.dart';
import 'package:book_finder_pro/data/datasources/local/book_local_storage.dart';

/// Define o contrato para todas as operações de dados de livros.
class BookRepository {
  final BookApiService apiService;
  final BookLocalStorage localStorage;

  BookRepository(this.apiService, this.localStorage);

  // --- Operações Remotas (API) ---

  Future<List<Book>> searchBooks({
    required String query,
    required SearchType type,
    int startIndex = 0,
    int maxResults = 20,
  }) async {
    // A lógica de cache já está no BookApiService, o repositório apenas orquestra.
    // Primeiro, verifica favoritos locais para marcar os livros antes de retornar.
    final apiBooks = await apiService.searchBooks(
      query: query,
      type: type,
      startIndex: startIndex,
      maxResults: maxResults,
    );

    final favorites = localStorage.getFavorites().map((b) => b.id).toSet();

    return apiBooks.map((book) {
      if (favorites.contains(book.id)) {
        return book.copyWith(isFavorite: true);
      }
      return book;
    }).toList();
  }

  // --- Operações Locais (Favoritos) ---

  List<Book> getFavorites() {
    return localStorage.getFavorites();
  }

  Future<void> toggleFavorite(Book book) async {
    if (localStorage.isFavorite(book.id)) {
      await localStorage.removeFavorite(book.id);
    } else {
      // Salva uma cópia marcada como favorita para garantir a consistência no Hive
      await localStorage.addFavorite(book.copyWith(isFavorite: true));
    }
  }

  // --- Operações Locais (Tema) ---

  Brightness getThemeMode() => localStorage.getThemeMode();
  Future<void> setThemeMode(Brightness mode) => localStorage.setThemeMode(mode);

  Color getCustomPrimaryColor() => localStorage.getCustomPrimaryColor();
  Future<void> setCustomPrimaryColor(Color color) =>
      localStorage.setCustomPrimaryColor(color);
}

// Provedor do Repositório
final bookRepositoryProvider = Provider<BookRepository>((ref) {
  final apiService = ref.watch(bookApiServiceProvider);
  final localStorage = ref.watch(bookLocalStorageProvider);
  return BookRepository(apiService, localStorage);
});
