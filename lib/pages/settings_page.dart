import 'package:flutter/material.dart';
import 'package:flutter_gamelist_editor/util/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _gistUrlController = TextEditingController();
  final _oAuthTokenController = TextEditingController();

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((sp) {
      _gistUrlController.text = sp.getString(KEY_GIST_URL);
      _oAuthTokenController.text = sp.getString(KEY_AUTH_TOKEN);
    });

    _gistUrlController.addListener(() {
      SharedPreferences.getInstance().then((sp) {
        sp.setString(KEY_GIST_URL, _gistUrlController.text);
      });
    });

    _oAuthTokenController.addListener(() {
      SharedPreferences.getInstance().then((sp) {
        sp.setString(KEY_AUTH_TOKEN, _oAuthTokenController.text);
      });
    });
  }

  @override
  void dispose() {
    [_gistUrlController, _oAuthTokenController].forEach((c) {
      c.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Einstellungen'),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _gistUrlController,
              decoration: InputDecoration(
                labelText: 'URL',
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _oAuthTokenController,
              decoration: InputDecoration(labelText: 'Token'),
            ),
          ),
        ],
      ),
    );
  }
}
