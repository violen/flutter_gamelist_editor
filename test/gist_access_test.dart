import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  group('Gist Access Integration Test', () {
    final configFile = File('test_settings.json');
    
    test('Verify GitHub Gist connectivity and data structure', () async {
      if (!configFile.existsSync()) {
        print('Skipping test: test_settings.json not found.');
        return;
      }

      final config = json.decode(configFile.readAsStringSync());
      final token = config['github_token'];
      final url = config['gist_url'];

      if (token == 'DEIN_TOKEN_HIER' || url.contains('DEINE_GIST_ID')) {
        print('Skipping test: test_settings.json contains placeholders.');
        return;
      }

      print('Testing connection to: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'token $token',
          'Accept': 'application/vnd.github.v3+json',
        },
      );

      expect(response.statusCode, 200, reason: 'GitHub API should return 200 OK');

      final data = json.decode(response.body);
      expect(data, isMap, reason: 'Response should be a JSON map');
      expect(data.containsKey('files'), true, reason: 'Response should contain "files" key');
      
      final fileName = 'gamesList.json';
      expect(data['files'].containsKey(fileName), true, reason: 'Gist should contain a file named "$fileName"');
      
      final content = json.decode(data['files'][fileName]['content']);
      expect(content.containsKey('gameList'), true, reason: 'JSON content should have a "gameList" key');
      expect(content['gameList'], isList, reason: '"gameList" should be a list');
      
      print('✅ Gist access verified! Found ${content['gameList'].length} games.');
    });
  });
}
