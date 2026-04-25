import 'package:flutter/material.dart';

import '../models/game.dart';
import '../models/gist.dart';
import '../services/github.dart';

class GameFormPage extends StatefulWidget {
  const GameFormPage({super.key, this.game, this.index});

  final Game? game;
  final int? index;

  @override
  State<GameFormPage> createState() => _GameFormPageState();
}

class _GameFormPageState extends State<GameFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();

  final _selectedPlayStyles = <PlayStyle>[];

  System? _selectedSystem;

  bool _canSave = false;

  @override
  void initState() {
    super.initState();

    if (widget.game != null) {
      _titleController.text = widget.game!.title;
      _selectedSystem = widget.game!.system;
      _selectedPlayStyles.addAll(widget.game!.playStyles);
    }

    _titleController.addListener(() {
      setState(() {
        _canSave = _formKey.currentState?.validate() ?? false;
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
      appBar: AppBar(
        title: (widget.game != null) ? const Text("Bearbeiten") : const Text("Erstellen"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: (_canSave || (_formKey.currentState?.validate() ?? false))
                ? () {
                    var newGame = Game(
                        title: _titleController.text,
                        system: _selectedSystem ?? System.unknown,
                        playStyles: _selectedPlayStyles);
                    if (widget.game != null && widget.index != null) {
                        Gist().gameList[widget.index!] = newGame;
                    } else {
                        Gist().gameList.add(newGame);
                    }

                    Github().saveGistLocally().then((_) {
                      if (!mounted) return;
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: "Titel"),
                  validator: (value) {
                    return (value == null || value.isEmpty) ? 'Muss ausgefüllt sein.' : null;
                  },
                ),
                // System
                DropdownButtonFormField<System>(
                  validator: (value) {
                    if (value == System.unknown) return 'System darf nicht unbekannt sein';
                    if (value == null) return 'Muss gewählt werden';
                    return null;
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
                DropdownButtonFormField<PlayStyle>(
                  validator: (value) {
                    return _selectedPlayStyles.isEmpty
                        ? "Mindestens eines muss gewählt worden sein"
                        : null;
                  },
                  value: _selectedPlayStyles.isEmpty
                      ? null
                      : _selectedPlayStyles.last,
                  onChanged: (playStyle) {
                    if (playStyle == null) return;
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
