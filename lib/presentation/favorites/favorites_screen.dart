import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_finder_pro/application/providers/book_providers.dart';
import 'package:book_finder_pro/presentation/common_widgets/book_card.dart';

/// Tela para exibir a lista de livros favoritos.
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Livros Favoritos'),
        automaticallyImplyLeading: false, // Usado em MainScreen
      ),
      body: favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Theme.of(context).colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    'Você ainda não tem favoritos.',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    'Adicione livros da aba de Busca.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 2 : 1, // 2 colunas para tablet, 1 para celular
                childAspectRatio: 3.5, // Proporção para que o card fique bom
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
              ),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final book = favorites[index];
                // Usa o mesmo BookCard para consistência
                return BookCard(book: book);
              },
            ),
    );
  }
}
