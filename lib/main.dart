import 'package:flutter/material.dart';
import 'package:flutter_gamelist_editor/widgets/system_bubble.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'models/game.dart';
import 'models/gist.dart';
import 'pages/game_form_page.dart';
import 'pages/settings_page.dart';
import 'services/github.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game List Editor',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: ChangeNotifierProvider<Github>(
        create: (BuildContext context) {
          return Github();
        },
        child: MyHomePage(title: 'Game List Editor'),
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: [const Locale('de'), const Locale('en')],
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  double _dragStartX;
  double _dragUpdateX;

  @override
  Widget build(BuildContext context) {
    var github = Provider.of<Github>(context);
    if (Gist().gameList.isEmpty) github.loadLocally();

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.file_download),
            onPressed: () => github.loadFromInternet(),
          ),
          IconButton(
            icon: Icon(Icons.file_upload),
            onPressed: () => github.saveToInternet(),
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return SettingsPage();
              }));
            },
          )
        ],
      ),
      body: ListView.separated(
        separatorBuilder: (BuildContext context, int index) {
          return Divider(
            color: Colors.grey,
            thickness: 1,
          );
        },
        padding: EdgeInsets.all(8),
        itemCount: Gist().gameList.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () =>
                _openGameForm(game: Gist().gameList[index], index: index),
            onHorizontalDragStart: (dragStart) {
              _dragStartX = dragStart.globalPosition.dx;
            },
            onHorizontalDragEnd: (dragEnd) {
              if (_dragStartX < _dragUpdateX) {
                // Delete
                Gist().remove(Gist().gameList[index]);
                github.saveGistLocally();
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
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Spacer(),
                  Text(Gist().gameList[index].title),
                  Spacer(),
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
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  _openGameForm({Game game, int index}) {
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
      return GameFormPage(
        game: game,
        index: index,
      );
    }));
  }

  _showSnackBar(bool dragRight) {
    _scaffoldKey.currentState?.showSnackBar(SnackBar(
      content: Text("Dragrichtung: ${dragRight ? 'Rechts' : 'Links'}"),
    ));
  }
}
