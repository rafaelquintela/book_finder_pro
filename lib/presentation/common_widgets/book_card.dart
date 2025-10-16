import 'package:flutter/material.dart';
// Usamos Image.network diretamente para evitar dependência externa aqui
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_finder_pro/data/models/book_model.dart';
import 'package:book_finder_pro/application/providers/book_providers.dart';
import 'package:book_finder_pro/presentation/common_widgets/book_detail_modal.dart';

/// Card responsivo e profissional para exibição de um livro.
class BookCard extends ConsumerWidget {
  final Book book;

  const BookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      // Usamos InkWell para um efeito visual de clique Material 3
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Animação suave: Abre o modal de detalhes do livro
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            builder: (context) => BookDetailModal(book: book),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagem do Livro com Cache
              Hero(
                tag: 'book-${book.id}', // Tag para a animação Hero
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 80,
                    height: 120,
                    color: theme.colorScheme.surfaceContainerHighest
                        .withOpacity(0.5),
                    child: book.thumbnailUrl != null
                        ? Image.network(
                            book.thumbnailUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: progress.expectedTotalBytes != null
                                      ? progress.cumulativeBytesLoaded /
                                          (progress.expectedTotalBytes ?? 1)
                                      : null,
                                  color: theme.colorScheme.primary,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.menu_book,
                              size: 40,
                              color: Colors.grey,
                            ),
                          )
                        : const Icon(Icons.menu_book,
                            size: 40, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Informações do Livro
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Autor: ${book.authors.isNotEmpty ? book.authors.join(', ') : 'N/A'}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Detalhes menores
                    Row(
                      children: [
                        Icon(Icons.category,
                            size: 16, color: theme.colorScheme.primary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            book.categories ?? 'Sem categoria',
                            style: theme.textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Botão de Favorito
              Consumer(
                builder: (context, ref, child) {
                  final isFavorite =
                      ref.watch(favoritesProvider.notifier).isFavorite(book.id);

                  return IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite
                          ? Colors.red.shade600
                          : theme.colorScheme.outline,
                      size: 24,
                    ),
                    onPressed: () async {
                      // Microinteração: feedback visual imediato
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isFavorite
                                ? 'Removido dos favoritos!'
                                : 'Adicionado aos favoritos!',
                            style:
                                TextStyle(color: theme.colorScheme.onPrimary),
                          ),
                          backgroundColor: theme.colorScheme.primary,
                          duration: const Duration(milliseconds: 800),
                        ),
                      );

                      // Lógica de toggle
                      await ref
                          .read(favoritesProvider.notifier)
                          .toggleFavorite(book);

                      // Atualiza a lista de busca para refletir o novo estado de favorito
                      ref
                          .read(bookSearchProvider.notifier)
                          .updateBookFavoriteStatus(book.id, !isFavorite);
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
