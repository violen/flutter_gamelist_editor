import 'package:flutter/material.dart';
import 'package:flutter_gamelist_editor/widgets/system_bubble.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'models/game.dart';
import 'models/gist.dart';
import 'pages/game_form_page.dart';
import 'pages/settings_page.dart';
import 'services/github.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game List Editor',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF6D00),
          primary: const Color(0xFFFF6D00),
          surface: const Color(0xFF1E1E1E),
          background: const Color(0xFF121212),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardTheme: const CardThemeData(
          color: Color(0xFF1E1E1E),
          elevation: 4,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
        ),
      ),
      home: ChangeNotifierProvider<Github>(
        create: (BuildContext context) {
          return Github();
        },
        child: const MyHomePage(title: 'Game List Editor'),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: const [Locale('de'), Locale('en')],
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _searchQuery = "";
  final List<System> _activeSystemFilters = [];
  final List<PlayStyle> _activePlayStyleFilters = [];

  List<Game> get _filteredGames {
    return Gist().gameList.where((game) {
      final matchesSearch =
          game.title.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesSystem = _activeSystemFilters.isEmpty ||
          _activeSystemFilters.contains(game.system);
      final matchesPlayStyle = _activePlayStyleFilters.isEmpty ||
          _activePlayStyleFilters
              .any((style) => game.playStyles.contains(style));
      return matchesSearch && matchesSystem && matchesPlayStyle;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    var github = Provider.of<Github>(context);
    if (Gist().gameList.isEmpty) github.loadLocally();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Download from Gist',
            onPressed: () {
              github.loadFromInternet().then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Gist erfolgreich geladen')),
                );
              }).catchError((e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('❌ Fehler beim Laden: $e'), backgroundColor: Colors.red),
                );
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.file_upload),
            tooltip: 'Upload to Gist',
            onPressed: () {
              github.saveToInternet().then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Gist erfolgreich gespeichert')),
                );
              }).catchError((e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('❌ Fehler beim Speichern: $e'), backgroundColor: Colors.red),
                );
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return const SettingsPage();
              }));
            },
          )
        ],
      ),
      body: _filteredGames.isEmpty
          ? const Center(child: Text("Keine Spiele gefunden."))
          : ListView.builder(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 88),
              itemCount: _filteredGames.length,
              itemBuilder: (BuildContext context, int index) {
                final game = _filteredGames[index];
                final gistIndex = Gist().gameList.indexOf(game);
                return Dismissible(
                  key: Key(game.title + gistIndex.toString()),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    setState(() {
                      Gist().remove(game);
                      github.saveGistLocally();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${game.title} gelöscht')),
                    );
                  },
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Spiel löschen?"),
                          content: Text(
                              "Möchtest du '${game.title}' wirklich aus der Liste entfernen?"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("ABBRECHEN"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.red),
                              child: const Text("LÖSCHEN"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.red[400],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: GestureDetector(
                    onTap: () => _openGameForm(game: game, index: gistIndex),
                    child: Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    game.title,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                ),
                                SystemBubble(system: game.system),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: game.playStyles.map((style) {
                                return Chip(
                                  label: Text(
                                    style.name,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "filter",
            onPressed: _showFilterSheet,
            mini: true,
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            shape: const CircleBorder(),
            child: const Icon(Icons.filter_list),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: "add",
            onPressed: () => _openGameForm(),
            tooltip: 'Add a Game',
            shape: const CircleBorder(),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              maxChildSize: 0.9,
              minChildSize: 0.5,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Suche & Filter",
                              style: Theme.of(context).textTheme.headlineSmall),
                          TextButton(
                            onPressed: () {
                              setModalState(() {
                                _searchQuery = "";
                                _activeSystemFilters.clear();
                                _activePlayStyleFilters.clear();
                              });
                              setState(() {});
                            },
                            child: const Text("Zurücksetzen"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: "Titel suchen",
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          setState(() => _searchQuery = value);
                        },
                        controller: TextEditingController.fromValue(
                          TextEditingValue(
                            text: _searchQuery,
                            selection: TextSelection.collapsed(
                                offset: _searchQuery.length),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text("Systeme",
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: System.values
                            .where((s) => s != System.unknown)
                            .map((system) {
                          final isSelected =
                              _activeSystemFilters.contains(system);
                          return FilterChip(
                            label: Text(system.displayName),
                            selected: isSelected,
                            onSelected: (selected) {
                              setModalState(() {
                                if (selected) {
                                  _activeSystemFilters.add(system);
                                } else {
                                  _activeSystemFilters.remove(system);
                                }
                              });
                              setState(() {});
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                      Text("Play Styles",
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: PlayStyle.values.map((style) {
                          final isSelected =
                              _activePlayStyleFilters.contains(style);
                          return FilterChip(
                            label: Text(style.name),
                            selected: isSelected,
                            onSelected: (selected) {
                              setModalState(() {
                                if (selected) {
                                  _activePlayStyleFilters.add(style);
                                } else {
                                  _activePlayStyleFilters.remove(style);
                                }
                              });
                              setState(() {});
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Fertig"),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _openGameForm({Game? game, int? index}) {
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      return GameFormPage(
        game: game,
        index: index,
      );
    }));
  }
}
