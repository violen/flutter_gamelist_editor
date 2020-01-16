import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gamelist_editor/models/gist.dart';
import 'package:flutter_gamelist_editor/util/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class Github extends ChangeNotifier {
  Github._();

  static final Github _instance = Github._();

  final _fileName = 'gameList.json';

  factory Github() {
    return _instance;
  }

  Future<Map<String, String>> get _authHeader async {
    var sp = await SharedPreferences.getInstance();
    return {
      'Authorization': 'token ${sp.getString(KEY_AUTH_TOKEN)}',
      'Accept': 'application/vnd.github.v3+json'
    };
  }

  Future loadFromInternet() async {
    var sp = await SharedPreferences.getInstance();
    var response = await http.get(sp.getString(KEY_GIST_URL), headers: await _authHeader);
    await _writeGistString(response.body);
    Gist().load(response.body);
    notifyListeners();
  }

  Future saveToInternet() async {
    var sp = await SharedPreferences.getInstance();
    var response = await http.patch(sp.getString(KEY_GIST_URL), headers: await _authHeader, body: json.encode({ 'files': { Gist().fileName: { 'content': gistToJson(Gist()) }}}));
    await _writeGistString(response.body);
    Gist().load(response.body);
    notifyListeners();
  }

  loadLocally() async {
    var loadedString = await _readGistString();
    Gist().load(loadedString);
    notifyListeners();
  }

  saveGistLocally() async {
    var file = await _getGistFile();
    
    var gistString = await file.readAsString();
    var updatedGist = Gist().save(gistString);

    await file.writeAsString(updatedGist);
    Gist().load(updatedGist);
    notifyListeners();
  }

  Future<String> _readGistString() async {
    var file = await _getGistFile();
    return file.readAsString();
  }

  _writeGistString(String string) async {
    var file = await _getGistFile();
    await file.writeAsString(string);
  }

  Future<File> _getGistFile() async {
    var dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

}