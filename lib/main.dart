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
  double? _dragStartX;
  double? _dragUpdateX;

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
            onPressed: () => github.loadFromInternet(),
          ),
          IconButton(
            icon: const Icon(Icons.file_upload),
            onPressed: () => github.saveToInternet(),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return const SettingsPage();
              }));
            },
          )
        ],
      ),
      body: ListView.separated(
        separatorBuilder: (BuildContext context, int index) {
          return const Divider(
            color: Colors.grey,
            thickness: 1,
          );
        },
        padding: const EdgeInsets.all(8),
        itemCount: Gist().gameList.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () =>
                _openGameForm(game: Gist().gameList[index], index: index),
            onHorizontalDragStart: (dragStart) {
              _dragStartX = dragStart.globalPosition.dx;
            },
            onHorizontalDragEnd: (dragEnd) {
              if (_dragStartX != null && _dragUpdateX != null && _dragStartX! < _dragUpdateX!) {
                // Delete
                setState(() {
                  Gist().remove(Gist().gameList[index]);
                  github.saveGistLocally();
                });
              }
            },
            onHorizontalDragUpdate: (dragUpdate) {
              _dragUpdateX = dragUpdate.globalPosition.dx;
            },
            child: Container(
              decoration: BoxDecoration(
                border:
                    Border.all(color: Theme.of(context).primaryColor, width: 1),
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Spacer(),
                  Text(Gist().gameList[index].title),
                  const Spacer(),
                  SystemBubble(system: Gist().gameList[index].system,),
                ],
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
