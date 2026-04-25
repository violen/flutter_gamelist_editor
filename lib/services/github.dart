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

  final _fileName = 'gist_data.json';

  factory Github() {
    return _instance;
  }

  Future<Map<String, String>> get _authHeader async {
    var sp = await SharedPreferences.getInstance();
    return {
      'Authorization': 'token ${sp.getString(KEY_AUTH_TOKEN) ?? ""}',
      'Accept': 'application/vnd.github.v3+json'
    };
  }

  Future<void> loadFromInternet() async {
    var sp = await SharedPreferences.getInstance();
    var url = sp.getString(KEY_GIST_URL);
    if (url == null || url.isEmpty) return;
    try {
      var response = await http.get(Uri.parse(url), headers: await _authHeader);
      if (response.statusCode == 200) {
        await _writeGistString(response.body);
        Gist().load(response.body);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error loading from internet: $e");
    }
  }

  Future<void> saveToInternet() async {
    var sp = await SharedPreferences.getInstance();
    var url = sp.getString(KEY_GIST_URL);
    if (url == null || url.isEmpty) return;
    try {
      var response = await http.patch(Uri.parse(url), 
        headers: await _authHeader, 
        body: json.encode({ 'files': { Gist().fileName: { 'content': gistToJson(Gist()) }}}));
      if (response.statusCode == 200) {
        await _writeGistString(response.body);
        Gist().load(response.body);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error saving to internet: $e");
    }
  }

  Future<void> loadLocally() async {
    var loadedString = await _readGistString();
    if (loadedString.isNotEmpty) {
      try {
        Gist().load(loadedString);
        notifyListeners();
      } catch (e) {
        debugPrint("Error loading locally: $e");
      }
    }
  }

  Future<void> saveGistLocally() async {
    var file = await _getGistFile();
    if (!await file.exists()) return;
    
    var gistString = await file.readAsString();
    var updatedGist = Gist().save(gistString);

    await file.writeAsString(updatedGist);
    Gist().load(updatedGist);
    notifyListeners();
  }

  Future<String> _readGistString() async {
    var file = await _getGistFile();
    if (await file.exists()) {
      return file.readAsString();
    }
    return "";
  }

  Future<void> _writeGistString(String string) async {
    var file = await _getGistFile();
    await file.writeAsString(string);
  }

  Future<File> _getGistFile() async {
    var dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

}
