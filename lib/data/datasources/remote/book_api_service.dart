import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_finder_pro/data/models/book_model.dart';
import 'package:book_finder_pro/data/datasources/local/book_local_storage.dart';

// Tipos de busca avançada
enum SearchType { all, title, author, isbn }

/// Serviço para comunicação com a API do Google Books.
class BookApiService {
  final BookLocalStorage _localStorage;

  static const String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';
  // Nota: A Google Books API geralmente não requer uma chave para buscas simples.
  // Coloque a chave real se for necessário para cotas/funcionalidades avançadas.
  // const String _apiKey = '';

  BookApiService(this._localStorage);

  /// Realiza a busca de livros com paginação e busca avançada.
  Future<List<Book>> searchBooks({
    required String query,
    required SearchType type,
    int startIndex = 0,
    int maxResults = 20,
  }) async {
    if (query.isEmpty) {
      return [];
    }

    // 1. Verificar Cache
    final cacheKey = '$query-$type-$startIndex';
    final cachedData = _localStorage.getSearchCache(cacheKey);
    if (cachedData.isNotEmpty) {
      // Retorna dados do cache se disponíveis (converte para Book)
      return cachedData.map((m) => Book.fromJson(m)).toList();
    }

    // 2. Montar query string
    String queryPrefix = '';
    switch (type) {
      case SearchType.title:
        queryPrefix = 'intitle:';
        break;
      case SearchType.author:
        queryPrefix = 'inauthor:';
        break;
      case SearchType.isbn:
        queryPrefix = 'isbn:';
        break;
      case SearchType.all:
      default:
        queryPrefix = '';
        break;
    }

    final fullQuery = '$queryPrefix$query';

    final Map<String, dynamic> params = {
      'q': fullQuery,
      'startIndex': startIndex,
      'maxResults': maxResults,
      // 'key': _apiKey, // Descomente e adicione a chave se necessário
    };

    try {
      final uri = Uri.parse(_baseUrl).replace(
          queryParameters: params.map((k, v) => MapEntry(k, v.toString())));
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : {};
        final List items = data['items'] ?? [];
        final List<Book> books = items
            .map((item) => Book.fromJson(item as Map<String, dynamic>))
            .toList();

        // 3. Armazenar no Cache antes de retornar
        await _localStorage.saveSearchCache(cacheKey, books);

        return books;
      } else {
        throw Exception('Falha ao carregar livros: ${response.statusCode}');
      }
    } catch (e) {
      // Tratamento simples de erros
      throw Exception('Erro de conexão ou API. Verifique sua rede.');
    }
  }
}

// Provedor Dio
// Provedor do Serviço de API (depende do serviço de cache local)
final bookApiServiceProvider = Provider<BookApiService>((ref) {
  final localStorage = ref.watch(bookLocalStorageProvider);
  return BookApiService(localStorage);
});
