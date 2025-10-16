import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_finder_pro/data/models/book_model.dart';
import 'package:book_finder_pro/application/providers/book_providers.dart';

/// Modal de detalhes com animação e responsividade, usando a tag Hero.
class BookDetailModal extends StatelessWidget {
  final Book book;

  const BookDetailModal({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    // Responsividade: o modal ocupa a maior parte da tela.
    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      minChildSize: 0.5,
      maxChildSize: 1.0,
      expand: true,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                _buildDetails(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Container(
      width: size.width,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.5),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle drag/fechar
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 20),
          // Imagem Central (Hero)
          Center(
            child: Hero(
              tag: 'book-${book.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: size.width * 0.4, // Responsivo
                  height: size.width * 0.6,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: book.thumbnailUrl != null
                      ? Image.network(
                          book.thumbnailUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                            Icons.menu_book,
                            size: 60,
                            color: Colors.grey,
                          ),
                        )
                      : const Icon(Icons.menu_book,
                          size: 60, color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Título e Autor
          Text(
            book.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            book.authors.isNotEmpty
                ? book.authors.join(', ')
                : 'Autor Desconhecido',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Botão de Favorito (independente)
          Center(child: _FavoriteButton(book: book)),
          const SizedBox(height: 20),

          // Informações de Metadados
          Wrap(
            spacing: 12.0,
            runSpacing: 12.0,
            children: [
              _buildMetaChip(context, Icons.calendar_month, 'Publicação',
                  book.publishedDate ?? 'N/A'),
              _buildMetaChip(
                  context, Icons.layers, 'Páginas', book.pageCount ?? 'N/A'),
              _buildMetaChip(context, Icons.category, 'Categoria',
                  book.categories ?? 'N/A'),
            ],
          ),

          const SizedBox(height: 20),

          // Descrição do Livro
          Text(
            'Descrição',
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Divider(),
          Text(
            book.description ?? 'Sem descrição detalhada disponível.',
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildMetaChip(
      BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Chip(
      avatar: Icon(icon, size: 18, color: theme.colorScheme.onPrimaryContainer),
      label: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer),
          ),
          Text(
            value.length > 20
                ? '${value.substring(0, 20)}...'
                : value, // Evitar textos muito longos
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onPrimaryContainer),
          ),
        ],
      ),
      backgroundColor: theme.colorScheme.primaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
}

// Widget auxiliar para o botão de favorito dentro do modal
class _FavoriteButton extends ConsumerWidget {
  final Book book;
  const _FavoriteButton({required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite =
        ref.watch(favoritesProvider.notifier).isFavorite(book.id);
    final theme = Theme.of(context);

    return ElevatedButton.icon(
      onPressed: () async {
        await ref.read(favoritesProvider.notifier).toggleFavorite(book);

        // Atualiza o estado da busca também
        ref
            .read(bookSearchProvider.notifier)
            .updateBookFavoriteStatus(book.id, !isFavorite);

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              !isFavorite
                  ? 'Adicionado aos favoritos!'
                  : 'Removido dos favoritos!',
              style: TextStyle(color: theme.colorScheme.onPrimary),
            ),
            backgroundColor: theme.colorScheme.primary,
            duration: const Duration(milliseconds: 800),
          ),
        );
      },
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: Colors.white,
      ),
      label: Text(
        isFavorite ? 'Remover dos Favoritos' : 'Adicionar aos Favoritos',
        style: const TextStyle(color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isFavorite ? theme.colorScheme.error : theme.colorScheme.primary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 5,
      ),
    );
  }
}
