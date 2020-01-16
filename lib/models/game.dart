import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum PlayStyle { LetsPlay, Casual, WithCommunity }
enum System { SNES, WII, WIIU, GCN, PC, GENESIS, SWITCH, UNKNOWN }

class Game extends Comparable<dynamic> {
  String title;
  System system;
  List<PlayStyle> playStyles;

  Game({this.title, this.system, this.playStyles});

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
        title: json['title'],
        system: _parseSystem(json['system']),
        playStyles: _parsePlayStyle(json['playStyle']));
  }

  List<String> _playStylesToJsonArray() {
    return playStyles.map<String>((style) => style.name).toList();
  }

  Map<String, dynamic> toJson() => {
        'title': this.title,
        'system': this.system.name,
        'playStyle': _playStylesToJsonArray()
      };

  @override
  int compareTo(other) {
    return title.compareTo(other.title);
  }
}

List<PlayStyle> _parsePlayStyle(List styles) {
  var playStyles = <PlayStyle>[];

  PlayStyle.values.forEach((el) {
    if (styles.contains(el.name)) playStyles.add(el);
  });
  return playStyles;
}

System _parseSystem(String system) {
  return System.values
      .firstWhere((val) => system == val.name, orElse: () => System.UNKNOWN);
}

extension SystemExtension on System {
  String get name => describeEnum(this);

  Color get color {
    var color;
    switch (this) {
      case System.SNES:
        color = Colors.grey[300];
        break;
      case System.WII:
        color = Colors.blue[200];
        break;
      case System.WIIU:
        color = Colors.blue[300];
        break;
      case System.GCN:
        color = Colors.purple[300];
        break;
      case System.PC:
        color = Colors.brown[300];
        break;
      case System.GENESIS:
        color = Colors.orange[300];
        break;
      case System.SWITCH:
        color = Colors.red[300];
        break;
      default: 
    }
    return color;
  }
}

extension PlayStyleExtension on PlayStyle {
  String get name => describeEnum(this);
}
