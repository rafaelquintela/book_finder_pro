import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_finder_pro/data/datasources/local/book_local_storage.dart';
import 'package:book_finder_pro/presentation/home/main_screen.dart';
import 'package:book_finder_pro/application/providers/book_providers.dart';

// Opcional: Adicionar a parte gerada do modelo de dados do Hive
// import 'package:book_finder_pro/data/models/book_model.g.dart';
// OBS: Este arquivo deve ser gerado antes de rodar.

void main() async {
  // Garante que os widgets estão inicializados antes de chamar o initialize do Hive
  WidgetsFlutterBinding.ensureInitialized();

  // O Hive será inicializado pelo FutureProvider no início.
  // Não é necessário chamar Hive.initFlutter() aqui, pois já é feito no BookLocalStorage.initialize().

  // Envolve o app com ProviderScope do Riverpod
  runApp(const ProviderScope(child: BookFinderProApp()));
}

class BookFinderProApp extends ConsumerWidget {
  const BookFinderProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Observa o FutureProvider para saber se o armazenamento local está pronto
    final localStorageAsync = ref.watch(localStorageInitializerProvider);

    // Observa o provedor de tema para aplicar o tema dinamicamente
    final themeData = ref.watch(themeProvider);

    return localStorageAsync.when(
      loading: () => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Inicializando sistema de armazenamento...',
                    style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
      error: (e, s) => MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Text('Erro fatal ao carregar dados: $e'),
          ),
        ),
      ),
      data: (_) => MaterialApp(
        title: 'Book Finder Pro',
        debugShowCheckedModeBanner: false,
        // Aplica o tema dinâmico (claro/escuro e cor personalizada)
        theme: themeData,
        home: const MainScreen(),
      ),
    );
  }
}
