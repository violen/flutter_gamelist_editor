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

  @override
  void initState() {
    super.initState();
    if (widget.game != null) {
      _titleController.text = widget.game!.title;
      _selectedSystem = widget.game!.system;
      _selectedPlayStyles.addAll(widget.game!.playStyles);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.game != null ? "Spiel bearbeiten" : "Neues Spiel"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _save,
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: "Titel",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Bitte Titel eingeben' : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<System>(
                decoration: const InputDecoration(
                  labelText: "System",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.computer),
                ),
                value: _selectedSystem,
                items: System.values
                    .where((s) => s != System.unknown)
                    .map((s) => DropdownMenuItem(value: s, child: Text(s.displayName)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedSystem = val),
                validator: (val) => val == null ? 'Bitte System wählen' : null,
              ),
              const SizedBox(height: 24),
              Text(
                "Play Styles",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: PlayStyle.values.map((style) {
                  final isSelected = _selectedPlayStyles.contains(style);
                  return FilterChip(
                    label: Text(style.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedPlayStyles.add(style);
                        } else {
                          _selectedPlayStyles.remove(style);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              if (_selectedPlayStyles.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 12),
                  child: Text(
                    "Bitte mindestens einen Stil wählen",
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _save,
        label: const Text("Speichern"),
        icon: const Icon(Icons.save),
      ),
    );
  }
}
