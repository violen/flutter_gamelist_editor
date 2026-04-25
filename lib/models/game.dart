import 'package:flutter/material.dart';

enum PlayStyle { letsPlay, casual, withCommunity }

enum System { snes, wii, wiiu, gcn, pc, genesis, switchConsole, unknown }

class Game implements Comparable<Game> {
  String title;
  System system;
  List<PlayStyle> playStyles;

  Game({required this.title, required this.system, required this.playStyles});

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
        title: json['title'] ?? '',
        system: _parseSystem(json['system']),
        playStyles: _parsePlayStyle(json['playStyle']));
  }

  List<String> _playStylesToJsonArray() {
    return playStyles.map<String>((style) => style.name).toList();
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'system': system.name,
        'playStyle': _playStylesToJsonArray()
      };

  @override
  int compareTo(Game other) {
    return title.compareTo(other.title);
  }
}

List<PlayStyle> _parsePlayStyle(List<dynamic>? styles) {
  var playStyles = <PlayStyle>[];
  if (styles == null) return playStyles;

  for (var el in PlayStyle.values) {
    // Case-insensitive matching for legacy data
    if (styles.any((s) => s.toString().toLowerCase() == el.name.toLowerCase())) {
      playStyles.add(el);
    }
  }
  return playStyles;
}

System _parseSystem(String? system) {
  if (system == null) return System.unknown;
  
  final input = system.toLowerCase();
  
  // Special handling for renamed enums
  if (input == 'switch') return System.switchConsole;
  
  return System.values.firstWhere(
    (val) => val.name.toLowerCase() == input, 
    orElse: () => System.unknown
  );
}

extension SystemExtension on System {
  Color? get color {
    switch (this) {
      case System.snes:
        return Colors.grey[300];
      case System.wii:
        return Colors.blue[200];
      case System.wiiu:
        return Colors.blue[300];
      case System.gcn:
        return Colors.purple[300];
      case System.pc:
        return Colors.brown[300];
      case System.genesis:
        return Colors.orange[300];
      case System.switchConsole:
        return Colors.red[300];
      case System.unknown:
        return Colors.grey;
    }
  }
}
