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
  String get displayName {
    switch (this) {
      case System.snes:
        return 'SNES';
      case System.wii:
        return 'WII';
      case System.wiiu:
        return 'WIIU';
      case System.gcn:
        return 'GCN';
      case System.pc:
        return 'PC';
      case System.genesis:
        return 'GENESIS';
      case System.switchConsole:
        return 'NSW';
      case System.unknown:
        return 'UNKNOWN';
    }
  }

  Color get color {
    switch (this) {
      case System.snes:
        return const Color(0xFF808080); // Classic Gray
      case System.wii:
        return const Color(0xFF00ADEF); // Wii Blue
      case System.wiiu:
        return const Color(0xFF009AC7); // WiiU Cyan
      case System.gcn:
        return const Color(0xFF6509CB); // GameCube Purple
      case System.pc:
        return const Color(0xFF3E2723); // PC Brown
      case System.genesis:
        return const Color(0xFF000000); // SEGA Black
      case System.switchConsole:
        return const Color(0xFFE60012); // Switch Red
      case System.unknown:
        return Colors.grey;
    }
  }
}
