import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_finder_pro/application/providers/book_providers.dart';
import 'package:book_finder_pro/data/datasources/remote/book_api_service.dart';
import 'package:book_finder_pro/presentation/common_widgets/book_card.dart';

/// Tela principal de Busca com filtros, paginação e responsividade.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    // Listener para carregar mais resultados ao rolar para o final
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      // Carrega a próxima página quando o usuário chega ao final
      ref.read(bookSearchProvider.notifier).loadNextPage();
    }
  }

  void _performSearch(String query) {
    if (query.trim().isNotEmpty && query != _lastQuery) {
      ref.read(bookSearchProvider.notifier).search(query);
      _lastQuery = query;
    }
  }
  
  // Converte SearchType para String amigável
  String _mapTypeToText(SearchType type) {
    switch (type) {
      case SearchType.title: return 'Título';
      case SearchType.author: return 'Autor';
      case SearchType.isbn: return 'ISBN';
      default: return 'Geral';
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(bookSearchProvider);
    final searchNotifier = ref.watch(bookSearchProvider.notifier);
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Livros'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Dropdown para Busca Avançada
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<SearchType>(
                      value: searchState.currentType,
                      icon: const Icon(Icons.filter_list),
                      onChanged: (SearchType? newValue) {
                        if (newValue != null) {
                          searchNotifier.setSearchType(newValue);
                        }
                      },
                      items: SearchType.values.map((SearchType type) {
                        return DropdownMenuItem<SearchType>(
                          value: type,
                          child: Text(_mapTypeToText(type)),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Campo de Busca
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por ${_mapTypeToText(searchState.currentType)}...',
                      suffixIcon: searchState.isLoading 
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: 20, 
                              width: 20, 
                              child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () => _performSearch(_searchController.text),
                          ),
                    ),
                    onSubmitted: _performSearch,
                  ),
                ),
              ],
            ),
          ),
          
          // Indicador de Carregamento/Erros/Resultados
          if (searchState.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Erro: ${searchState.errorMessage}',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ),
            
          // Exibição dos Livros
          Expanded(
            child: searchState.books.isEmpty && !searchState.isLoading
              ? Center(
                  child: Text(
                    searchState.currentQuery.isEmpty
                        ? 'Comece sua busca por livros!'
                        : 'Nenhum livro encontrado para "${searchState.currentQuery}".',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
                  ),
                )
              : GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isTablet ? 2 : 1, // Responsividade
                    childAspectRatio: 3.5, 
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                  ),
                  itemCount: searchState.books.length + (searchState.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == searchState.books.length) {
                      // Ítem final para carregar mais
                      return const Center(child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ));
                    }
                    final book = searchState.books[index];
                    return BookCard(book: book);
                  },
                ),
          ),
          
          // Indicador de carregamento contínuo (se for rolagem)
          if (searchState.isLoading && searchState.books.isNotEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
