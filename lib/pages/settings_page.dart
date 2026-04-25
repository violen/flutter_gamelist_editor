import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gamelist_editor/util/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _gistUrlController = TextEditingController();
  final _oAuthTokenController = TextEditingController();
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final sp = await SharedPreferences.getInstance();
    setState(() {
      _gistUrlController.text = sp.getString(KEY_GIST_URL) ?? '';
      _oAuthTokenController.text = sp.getString(KEY_AUTH_TOKEN) ?? '';
    });
  }

  Future<void> _saveSettings() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(KEY_GIST_URL, _gistUrlController.text);
    await sp.setString(KEY_AUTH_TOKEN, _oAuthTokenController.text);
  }

  Future<void> _testConnection() async {
    setState(() => _isTesting = true);
    try {
      final response = await http.get(
        Uri.parse(_gistUrlController.text),
        headers: {
          'Authorization': 'token ${_oAuthTokenController.text}',
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final fileName = 'gamesList.json';
        if (data['files'] != null && data['files'].containsKey(fileName)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Verbindung erfolgreich! Gist gefunden.')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('⚠️ Verbunden, aber Datei "$fileName" fehlt im Gist.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Fehler: ${response.statusCode} (${response.reasonPhrase})')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Verbindung fehlgeschlagen: $e')),
      );
    } finally {
      if (mounted) setState(() => _isTesting = false);
    }
  }

  @override
  void dispose() {
    _gistUrlController.dispose();
    _oAuthTokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              await _saveSettings();
              if (mounted) Navigator.pop(context);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline),
                        SizedBox(width: 8),
                        Text('Anleitung', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. GitHub Token: Erstelle einen Personal Access Token mit dem Scope "gist".\n'
                      '2. Gist URL: Nutze die API-URL, z.B. https://api.github.com/gists/DEINE_GIST_ID\n'
                      '3. Die Datei im Gist muss "gamesList.json" heißen.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _oAuthTokenController,
              decoration: const InputDecoration(
                labelText: 'GitHub Personal Access Token',
                helperText: 'Benötigt "gist" Berechtigung',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.vpn_key),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _gistUrlController,
              decoration: const InputDecoration(
                labelText: 'Gist API URL',
                helperText: 'Format: https://api.github.com/gists/<id>',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isTesting ? null : _testConnection,
                icon: _isTesting 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.sync_alt),
                label: const Text('Verbindung testen'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
