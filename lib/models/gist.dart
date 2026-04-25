import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'game.dart';

String gistToJson(Gist data) => json.encode(data.toJson());

class Gist {

  Gist._();
  static final Gist _instance = Gist._();
  factory Gist() => _instance;

  final fileName = 'gamesList.json';

  Map<String, dynamic>? _content; 

  Gist load(String rawGistString) {
    try {
      var content = _loadGistContent(rawGistString);
      if (content == null) return _instance;

      _content = {
        'meta': { 'lastEdit': DateTime.fromMillisecondsSinceEpoch(content['meta']?['lastEdit'] ?? 0) },
        'gameList': ((content['gameList'] as List?)?.map((el) => Game.fromJson(el)).toList().cast<Game>() ?? <Game>[])..sort()
      };
    } catch (e) {
      debugPrint("Error parsing Gist content: $e");
    }
    return _instance;
  }

  String save(String rawGistString) {
    var gist = _loadGist(rawGistString);
    gist['files'][fileName]['content'] = json.encode(toJson(update: true));
    return json.encode(gist);
  }

  Map<String, dynamic> toJson({bool update = false}) => {
    'meta': { 'lastEdit': update ? DateTime.now().millisecondsSinceEpoch : _content?['meta']?['lastEdit']?.millisecondsSinceEpoch ?? 0 },
    'gameList': gameList.map((el) => el.toJson()).toList()
  };

  List<Game> get gameList {
    return _content != null ? _content!['gameList'] : <Game>[];
  }

  DateTime get lastEdit {
    return _content?['meta']?['lastEdit'] ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  void remove(Game game) {
    gameList.remove(game);
  }

  set lastEdit(DateTime lastEdit) {
    if (_content != null && _content!.containsKey('meta')) {
        _content!['meta']['lastEdit'] = lastEdit;
    }
  }

  Map<String, dynamic> _loadGist(String string) => json.decode(string);
  Map<String, dynamic>? _loadGistContent(String string) {
    try {
      var gist = _loadGist(string);
      if (gist.containsKey('files') && gist['files'].containsKey(fileName)) {
        return json.decode(gist['files'][fileName]['content']);
      }
    } catch (e) {
      debugPrint("Error decoding Gist JSON: $e");
    }
    return null;
  }

}
