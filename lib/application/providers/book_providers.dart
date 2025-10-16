import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_finder_pro/data/models/book_model.dart';
import 'package:book_finder_pro/data/repositories/book_repository.dart';
import 'package:book_finder_pro/data/datasources/remote/book_api_service.dart';
import 'package:book_finder_pro/core/constants/app_theme.dart';

// --- TEMA E CONFIGURAÇÕES ---

/// StateNotifier para gerenciar o modo de tema (Claro/Escuro) e cor primária.
class ThemeModeNotifier extends StateNotifier<ThemeData> {
  final BookRepository _repository;
  Brightness _brightness;
  Color _primaryColor;

  ThemeModeNotifier(this._repository)
      : _brightness = _repository.getThemeMode(),
        _primaryColor = _repository.getCustomPrimaryColor(),
        super(AppTheme.lightTheme) {
    _loadTheme();
  }

  void _loadTheme() {
    _updateTheme(_brightness, _primaryColor);
  }

  void toggleTheme() {
    _brightness =
        _brightness == Brightness.light ? Brightness.dark : Brightness.light;
    _repository.setThemeMode(_brightness);
    _updateTheme(_brightness, _primaryColor);
  }

  void setPrimaryColor(Color color) {
    _primaryColor = color;
    _repository.setCustomPrimaryColor(color);
    _updateTheme(_brightness, _primaryColor);
  }

  // Atualiza o state (ThemeData)
  void _updateTheme(Brightness brightness, Color primaryColor) {
    if (brightness == Brightness.light) {
      state = AppTheme.lightTheme.copyWith(
        colorScheme: AppTheme.lightTheme.colorScheme.copyWith(
          primary: primaryColor,
        ),
      );
    } else {
      state = AppTheme.darkTheme.copyWith(
        colorScheme: AppTheme.darkTheme.colorScheme.copyWith(
          primary: primaryColor,
        ),
      );
    }
  }

  // Getters para UI
  Brightness get currentBrightness => _brightness;
  Color get currentPrimaryColor => _primaryColor;
}

final themeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeData>((ref) {
  final repo = ref.watch(bookRepositoryProvider);
  return ThemeModeNotifier(repo);
});

// --- FAVORITOS ---

/// StateNotifier para gerenciar a lista de livros favoritos.
class FavoritesNotifier extends StateNotifier<List<Book>> {
  final BookRepository _repository;

  FavoritesNotifier(this._repository) : super(_repository.getFavorites());

  // Atualiza a lista de favoritos
  void _loadFavorites() {
    state = _repository.getFavorites();
  }

  // Alterna o estado de favorito de um livro e atualiza o estado de busca/favoritos
  Future<void> toggleFavorite(Book book) async {
    await _repository.toggleFavorite(book);
    _loadFavorites();
  }

  bool isFavorite(String bookId) {
    return state.any((book) => book.id == bookId);
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<Book>>((ref) {
  final repo = ref.watch(bookRepositoryProvider);
  return FavoritesNotifier(repo);
});

// --- BUSCA E PAGINAÇÃO ---

class SearchState {
  final List<Book> books;
  final bool isLoading;
  final String? errorMessage;
  final bool hasMore;
  final int currentPage;
  final String currentQuery;
  final SearchType currentType;

  SearchState({
    this.books = const [],
    this.isLoading = false,
    this.errorMessage,
    this.hasMore = false,
    this.currentPage = 0,
    this.currentQuery = '',
    this.currentType = SearchType.title,
  });

  // Método copyWith para facilitar a atualização de estado
  SearchState copyWith({
    List<Book>? books,
    bool? isLoading,
    String? errorMessage,
    bool? hasMore,
    int? currentPage,
    String? currentQuery,
    SearchType? currentType,
  }) {
    return SearchState(
      books: books ?? this.books,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      currentQuery: currentQuery ?? this.currentQuery,
      currentType: currentType ?? this.currentType,
    );
  }
}

/// StateNotifier para gerenciar o estado da busca e paginação.
class BookSearchNotifier extends StateNotifier<SearchState> {
  final BookRepository _repository;
  static const int _maxResults = 20;

  BookSearchNotifier(this._repository) : super(SearchState());

  /// Define o tipo de busca (Título, Autor, ISBN)
  void setSearchType(SearchType type) {
    if (state.currentType != type) {
      state = state.copyWith(currentType: type);
      // Reinicia a busca se a query não estiver vazia
      if (state.currentQuery.isNotEmpty) {
        search(state.currentQuery);
      }
    }
  }

  /// Inicia uma nova busca. Reseta a lista e a página.
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = SearchState(); // Limpa o estado se a busca for vazia
      return;
    }

    if (state.currentQuery == query &&
        state.books.isNotEmpty &&
        state.currentPage > 0) {
      // Se a query não mudou e já temos resultados, não refaça a primeira busca.
      return;
    }

    state = state.copyWith(
      isLoading: true,
      currentQuery: query.trim(),
      currentPage: 0,
      books: [], // Limpa resultados anteriores
      errorMessage: null,
      hasMore: true, // Assume que há mais até que a API prove o contrário
    );

    await _fetchBooks(0);
  }

  /// Carrega a próxima página de resultados.
  Future<void> loadNextPage() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    await _fetchBooks(state.currentPage + 1);
  }

  // Lógica central para buscar livros da API
  Future<void> _fetchBooks(int page) async {
    final startIndex = page * _maxResults;

    try {
      final newBooks = await _repository.searchBooks(
        query: state.currentQuery,
        type: state.currentType,
        startIndex: startIndex,
        maxResults: _maxResults,
      );

      // Verificação para garantir que o estado não foi descartado
      if (!mounted) return;

      final allBooks = page == 0 ? newBooks : [...state.books, ...newBooks];

      state = state.copyWith(
        books: allBooks,
        isLoading: false,
        currentPage: page,
        hasMore: newBooks.length ==
            _maxResults, // Se retornou o máximo, provavelmente há mais.
        errorMessage: null,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
        hasMore: false,
      );
    }
  }

  // Chamado para atualizar o estado de favorito de um livro na lista de busca
  void updateBookFavoriteStatus(String bookId, bool isFavorite) {
    final newBooks = state.books.map((book) {
      if (book.id == bookId) {
        return book.copyWith(isFavorite: isFavorite);
      }
      return book;
    }).toList();

    state = state.copyWith(books: newBooks);
  }
}

final bookSearchProvider =
    StateNotifierProvider<BookSearchNotifier, SearchState>((ref) {
  final repo = ref.watch(bookRepositoryProvider);
  return BookSearchNotifier(repo);
});
