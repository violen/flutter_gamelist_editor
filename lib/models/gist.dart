import 'dart:convert';

import 'game.dart';

String gistToJson(Gist data) => json.encode(data.toJson());

class Gist {

  Gist._();
  static final Gist _instance = Gist._();
  factory Gist() => _instance;

  final fileName = 'gamesList.json';

  Map<String, dynamic> _content; 

  Gist load(String rawGistString) {
    var content = _loadGistContent(rawGistString);
    _content = {
      'meta': { 'lastEdit': DateTime.fromMillisecondsSinceEpoch(content['meta']['lastEdit']) ?? DateTime.now() },
      'gameList': content['gameList'].map((el) => Game.fromJson(el)).toList()..sort()
    };
    return _instance;
  }

  String save(String rawGistString) {
    var gist = _loadGist(rawGistString);
    gist['files'][fileName]['content'] = json.encode(toJson(update: true));
    return json.encode(gist);
  }

  Map<String, dynamic> toJson({bool update = false}) => {
    'meta': { 'lastEdit': update ? DateTime.now().millisecondsSinceEpoch : _content['meta']['lastEdit'].millisecondsSinceEpoch },
    'gameList': _content['gameList'].map((el) => el.toJson()).toList()
  };

  List get gameList {
    return _content != null ? _content['gameList'] : <Game>[];
  }

  DateTime get lastEdit {
    return _content['meta']['lastEdit'];
  }

  remove(Game game) {
    gameList.remove(game);
  }

  set lastEdit(DateTime lastEdit) {
    _content['meta']['lastEdit'] = lastEdit;
  }

  Map _loadGist(String string) => json.decode(string);
  Map _loadGistContent(String string) => json.decode(_loadGist(string)['files'][fileName]['content']);

}