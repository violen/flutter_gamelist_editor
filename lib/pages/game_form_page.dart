import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/game.dart';
import '../models/gist.dart';
import '../services/github.dart';

class GameFormPage extends StatefulWidget {
  GameFormPage({Key key, this.game, this.index}) : super(key: key);

  final Game game;
  final int index;

  @override
  _GameFormPageState createState() => _GameFormPageState();
}

class _GameFormPageState extends State<GameFormPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();

  final _selectedPlayStyles = <PlayStyle>[];

  System _selectedSystem;

  bool _canSave = false;

  @override
  void initState() {
    super.initState();

    if (widget.game != null) {
      _titleController.text = widget.game.title;
      _selectedSystem = widget.game.system;
      _selectedPlayStyles.addAll(widget.game.playStyles);
    }

    _titleController.addListener(() {
      setState(() {
        _canSave = _formKey.currentState.validate();
      });
    });
  }

  @override
  void dispose() {
    _titleController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: (widget.game != null) ? Text("Bearbeten") : Text("Erstellen"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: (_formKey.currentState != null &&
                        _formKey.currentState.validate() ||
                    _canSave)
                ? () {
                    var newGame = Game(
                        title: _titleController.text,
                        system: _selectedSystem,
                        playStyles: _selectedPlayStyles);
                    widget.game != null
                        ? Gist().gameList[widget.index] = newGame
                        : Gist().gameList.add(newGame);

                    Github().saveGistLocally().then((gist) {
                      Navigator.pop(context);
                    });
                  }
                : null,
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: "Titel"),
                  validator: (value) {
                    return value.isEmpty ? 'Muss ausgefüllt sein.' : null;
                  },
                ),
                // System
                DropdownButtonFormField(
                  validator: (value) {
                    var msg;
                    if (_selectedSystem == System.UNKNOWN)
                      msg = 'System darf nicht unbekannt sein';
                    if (_selectedSystem == null) msg = 'Muss gewählt werden';

                    return msg;
                  },
                  value: _selectedSystem,
                  onChanged: (system) {
                    setState(() {
                      _selectedSystem = system;
                    });
                  },
                  items: System.values.map((system) {
                    return DropdownMenuItem<System>(
                      value: system,
                      child: Text(system.name),
                    );
                  }).toList(),
                ),
                // PlayStyle
                DropdownButtonFormField(
                  validator: (value) {
                    return _selectedPlayStyles.isEmpty
                        ? "Mindestens eines muss gewählt worden sein"
                        : null;
                  },
                  value: _selectedPlayStyles.isEmpty
                      ? null
                      : _selectedPlayStyles.last,
                  onChanged: (playStyle) {
                    setState(() {
                      if (_selectedPlayStyles.contains(playStyle)) {
                        _selectedPlayStyles.remove(playStyle);
                      } else {
                        _selectedPlayStyles.add(playStyle);
                      }
                    });
                  },
                  items: PlayStyle.values.map((playStyle) {
                    return DropdownMenuItem<PlayStyle>(
                      value: playStyle,
                      child: Row(
                        children: <Widget>[
                          Icon(_selectedPlayStyles.contains(playStyle)
                              ? Icons.check
                              : null),
                          Text(playStyle.name)
                        ],
                      ),
                    );
                  }).toList(),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
