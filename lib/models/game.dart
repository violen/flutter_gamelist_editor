import 'package:flutter/foundation.dart';

enum PlayStyle { LetsPlay, Casual, WithCommunity }
enum System { SNES, WII, WIIU, GCN, PC, GENESIS, SWITCH, UNKNOWN }

class Game extends Comparable<dynamic> {

  String title;
  System system;
  List<PlayStyle> playStyles;

  Game({ this.title, this.system, this.playStyles });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(title: json['title'], system: _parseSystem(json['system']), playStyles: _parsePlayStyle(json['playStyle']));
  } 

  List<String> _playStylesToJsonArray () {
    return playStyles.map<String>((style) { return describeEnum(style); }).toList();
  }

  Map<String, dynamic> toJson() => {
    'title': this.title,
    'system': describeEnum(this.system),
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
      if (styles.contains(describeEnum(el))) playStyles.add(el);
    });
    return playStyles;
}

System _parseSystem(String system) {
  return System.values.firstWhere((val) => system == describeEnum(val), orElse: () => System.UNKNOWN);
}