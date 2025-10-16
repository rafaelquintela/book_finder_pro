import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_finder_pro/application/providers/book_providers.dart';
import 'package:book_finder_pro/core/constants/app_theme.dart';

/// Tela do Design System: Exibe componentes e permite configurar o tema.
class DesignSystemScreen extends ConsumerWidget {
  const DesignSystemScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Provedores de estado do Riverpod para gerenciar o tema e a cor
    final themeNotifier = ref.watch(themeProvider.notifier);
    final themeData = ref.watch(themeProvider);
    final isDark = themeNotifier.currentBrightness == Brightness.dark;
    final primaryColor = themeNotifier.currentPrimaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System & Configurações'),
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Título de Branding
          Text(
            'Book Finder Pro',
            style: themeData.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: themeData.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),

          // --- 1. Configuração de Tema (Interativo) ---
          _buildSectionTitle(context, 'Configurações de Tema'),
          Card(
            child: ListTile(
              title: const Text('Modo Escuro / Claro'),
              // Switch para alternar entre os modos
              trailing: Switch(
                value: isDark,
                onChanged: (_) => themeNotifier.toggleTheme(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              title: const Text('Cor Primária Personalizada'),
              trailing: ElevatedButton(
                // Botão que abre o seletor de cores
                onPressed: () => _showColorPicker(context, themeNotifier),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(15),
                ),
                child: const SizedBox.shrink(),
              ),
            ),
          ),
          
          const Divider(height: 40),

          // --- 2. Cores e Tipografia ---
          _buildSectionTitle(context, 'Paleta de Cores'),
          _buildColorPalette(context, themeData),
          const SizedBox(height: 20),
          
          _buildSectionTitle(context, 'Tipografia (Inter)'),
          _buildTypographyExamples(context, themeData),
          const SizedBox(height: 20),

          // --- 3. Componentes UI ---
          _buildSectionTitle(context, 'Botões e Ações'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(onPressed: (){}, child: const Text('Primário')),
              FilledButton(onPressed: (){}, child: const Text('Preenchido')),
              OutlinedButton(onPressed: (){}, child: const Text('Secundário')),
            ],
          ),
          const SizedBox(height: 15),
          FloatingActionButton.extended(
            onPressed: () {},
            icon: const Icon(Icons.add),
            label: const Text('Ação Flutuante'),
            heroTag: UniqueKey(), // Adicionado heroTag para evitar erros
          ),
          const SizedBox(height: 20),
          
          _buildSectionTitle(context, 'Cards e Elevação'),
          Card(
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Este é um card com elevação (Shadow) seguindo o Material 3.',
                style: themeData.textTheme.bodyMedium,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  
  // Exibe o Color Picker (usando cores pré-definidas para simplicidade)
  void _showColorPicker(BuildContext context, ThemeModeNotifier themeNotifier) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color tempColor = themeNotifier.currentPrimaryColor;
        
        return AlertDialog(
          title: const Text('Escolha a Cor Primária'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Simulação de um Color Picker simples (com cores pré-definidas)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Colors.blue,
                    Colors.red,
                    Colors.green,
                    Colors.purple,
                    Colors.orange,
                    Colors.teal,
                  ].map((color) => InkWell(
                    onTap: () {
                      tempColor = color;
                      Navigator.of(context).pop();
                      // Aplica a nova cor
                      themeNotifier.setPrimaryColor(tempColor);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildColorPalette(BuildContext context, ThemeData themeData) {
    final colors = {
      'Primary': themeData.colorScheme.primary,
      'Secondary': themeData.colorScheme.secondary,
      'Error': themeData.colorScheme.error,
      'Background': themeData.colorScheme.surface,
      'Surface': themeData.colorScheme.surface,
    };

    return Card(
      child: Column(
        children: colors.entries.map((entry) {
          return ListTile(
            leading: CircleAvatar(backgroundColor: entry.value, radius: 12),
            title: Text(entry.key),
            // Exibe o código HEX da cor
            trailing: Text('#${entry.value.value.toRadixString(16).substring(2).toUpperCase()}'),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTypographyExamples(BuildContext context, ThemeData themeData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Headline Large', style: themeData.textTheme.headlineLarge),
            Text('Title Medium', style: themeData.textTheme.titleMedium),
            Text('Body Large (Padrão)', style: themeData.textTheme.bodyLarge),
            Text('Label Small', style: themeData.textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
