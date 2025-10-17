import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../services/graphql_service.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final List<String> _allGenres = [
    'Ficción',
    'No Ficción',
    'Romance',
    'Fantasía',
    'Ciencia ficción',
    'Misterio',
    'Historia',
    'Biografía',
    'Autoayuda',
    'Infantil',
  ];

  final Set<String> _selected = {};
  bool _isSaving = false;

  void _toggle(String genre) {
    setState(() {
      if (_selected.contains(genre)) {
        _selected.remove(genre);
      } else if (_selected.length < 3) {
        _selected.add(genre);
      } else {
        // max 3
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Puedes seleccionar hasta 3 géneros')),
        );
      }
    });
  }

  Future<void> _save() async {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un género')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final client = GraphQLProvider.of(context).value;
    final result = await client.mutate(
      MutationOptions(
        document: gql(GraphQLService.saveGenresMutation),
        variables: {'genres': _selected.toList()},
      ),
    );

    setState(() => _isSaving = false);

    if (!mounted) return;

    if (result.hasException) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.exception.toString())),
      );
      return;
    }

    // Optionally confirm preferences
    final confirm = await client.mutate(
      MutationOptions(document: gql(GraphQLService.confirmPreferencesMutation)),
    );
    if (!mounted) return;

    if (confirm.hasException) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(confirm.exception.toString())),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preferencias guardadas')),
    );

    // Navigate to search/home using GoRouter
    context.go('/search');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selecciona tus géneros')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Elige hasta 3 géneros que prefieras', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: _allGenres.map((g) {
                  final selected = _selected.contains(g);
                  return InkWell(
                    onTap: () => _toggle(g),
                    child: Container(
                      decoration: BoxDecoration(
                        color: selected ? Theme.of(context).colorScheme.primary : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        g,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving ? const CircularProgressIndicator() : const Text('Guardar preferencias'),
            ),
          ],
        ),
      ),
    );
  }
}
