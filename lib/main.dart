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
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
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
            onPressed: () => github.loadFromInternet(),
          ),
          IconButton(
            icon: const Icon(Icons.file_upload),
            tooltip: 'Upload to Gist',
            onPressed: () => github.saveToInternet(),
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
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: Gist().gameList.length,
        itemBuilder: (BuildContext context, int index) {
          final game = Gist().gameList[index];
          return Dismissible(
            key: Key(game.title + index.toString()),
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
                    content: Text("Möchtest du '${game.title}' wirklich aus der Liste entfernen?"),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("ABBRECHEN"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
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
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.red[400],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: GestureDetector(
              onTap: () => _openGameForm(game: game, index: index),
              child: Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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
                              style: Theme.of(context).textTheme.titleLarge,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openGameForm(),
        tooltip: 'Add a Game',
        child: const Icon(Icons.add),
      ),
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
