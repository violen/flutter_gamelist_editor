import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:image_picker/image_picker.dart';

import '../models/game.dart';
import '../models/gist.dart';
import '../services/github.dart';

class GameFormPage extends StatefulWidget {
  const GameFormPage({super.key, this.game, this.index});

  final Game? game;
  final int? index;

  @override
  State<GameFormPage> createState() => _GameFormPageState();
}

class _GameFormPageState extends State<GameFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _selectedPlayStyles = <PlayStyle>[];
  System? _selectedSystem;
  bool _isScanning = false;

  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);
  final LanguageIdentifier _languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);

  @override
  void initState() {
    super.initState();
    if (widget.game != null) {
      _titleController.text = widget.game!.title;
      _selectedSystem = widget.game!.system;
      _selectedPlayStyles.addAll(widget.game!.playStyles);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textRecognizer.close();
    _languageIdentifier.close();
    super.dispose();
  }

  Future<void> _scanTitle() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) return;

    setState(() => _isScanning = true);

    try {
      final inputImage = InputImage.fromFilePath(image.path);
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);

      String foundText = recognizedText.text.replaceAll('\n', ' ').trim();

      if (foundText.isNotEmpty) {
        // Step 2: Identify Language
        final String languageCode = await _languageIdentifier.identifyLanguage(foundText);
        debugPrint("Detected language: $languageCode");

        if (languageCode != 'de' && languageCode != 'und') {
          // Step 3: Translate if not German
          final sourceLanguage = BCP47Code.fromCode(languageCode);
          if (sourceLanguage != null) {
            final translator = OnDeviceTranslator(
              sourceLanguage: sourceLanguage,
              targetLanguage: TranslateLanguage.german,
            );
            
            final String translatedText = await translator.translateText(foundText);
            await translator.close();
            
            if (mounted) {
              final bool? useTranslation = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Übersetzung gefunden"),
                  content: Text("Original: $foundText\n\nÜbersetzung: $translatedText\n\nSoll die Übersetzung verwendet werden?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("ORIGINAL")),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("ÜBERSETZUNG")),
                  ],
                ),
              );
              
              if (useTranslation == true) {
                foundText = translatedText;
              }
            }
          }
        }

        _titleController.text = foundText;
      }
    } catch (e) {
      debugPrint("OCR/Translation error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Fehler bei der Texterkennung: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      var newGame = Game(
          title: _titleController.text,
          system: _selectedSystem ?? System.unknown,
          playStyles: _selectedPlayStyles);

      if (widget.game != null && widget.index != null) {
        Gist().gameList[widget.index!] = newGame;
      } else {
        Gist().gameList.add(newGame);
      }

      Github().saveGistLocally().then((_) {
        if (!mounted) return;
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.game != null ? "Spiel bearbeiten" : "Neues Spiel"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _save,
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "Titel",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.title),
                  suffixIcon: _isScanning
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.camera_alt),
                          onPressed: _scanTitle,
                          tooltip: "Titel scannen",
                        ),
                ),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'Bitte Titel eingeben'
                    : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<System>(
                decoration: const InputDecoration(
                  labelText: "System",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.computer),
                ),
                value: _selectedSystem,
                items: System.values
                    .where((s) => s != System.unknown)
                    .map((s) =>
                        DropdownMenuItem(value: s, child: Text(s.displayName)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedSystem = val),
                validator: (val) => val == null ? 'Bitte System wählen' : null,
              ),
              const SizedBox(height: 24),
              Text(
                "Play Styles",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: PlayStyle.values.map((style) {
                  final isSelected = _selectedPlayStyles.contains(style);
                  return FilterChip(
                    label: Text(style.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedPlayStyles.add(style);
                        } else {
                          _selectedPlayStyles.remove(style);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              if (_selectedPlayStyles.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 12),
                  child: Text(
                    "Bitte mindestens einen Stil wählen",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _save,
        label: const Text("Speichern"),
        icon: const Icon(Icons.save),
      ),
    );
  }
}

extension BCP47Code on TranslateLanguage {
  static TranslateLanguage? fromCode(String code) {
    // Map common BCP47 codes to ML Kit TranslateLanguage
    switch (code) {
      case 'en': return TranslateLanguage.english;
      case 'ja': return TranslateLanguage.japanese;
      case 'fr': return TranslateLanguage.french;
      case 'es': return TranslateLanguage.spanish;
      case 'it': return TranslateLanguage.italian;
      case 'ko': return TranslateLanguage.korean;
      case 'zh': return TranslateLanguage.chinese;
      // Add more as needed
      default: return null;
    }
  }
}
