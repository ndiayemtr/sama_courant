import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/services/mlkit_label_text_recognizer.dart';

class OcrDebugPage extends StatefulWidget {
  const OcrDebugPage({super.key});

  @override
  State<OcrDebugPage> createState() => _OcrDebugPageState();
}

class _OcrDebugPageState extends State<OcrDebugPage> {
  final _picker = ImagePicker();
  static const _recognizer = MlKitLabelTextRecognizer();

  String _result = '';
  bool _loading = false;

  Future<void> _pickAndReadImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );

    if (image == null) {
      return;
    }

    setState(() {
      _loading = true;
      _result = '';
    });

    try {
      final text = await _recognizer.recognizeText(image.path);

      if (!mounted) return;

      setState(() {
        _result = text;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _result = 'Erreur OCR : $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test OCR')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FilledButton.icon(
              onPressed: _loading ? null : _pickAndReadImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Photographier une étiquette'),
            ),
            const SizedBox(height: 16),
            if (_loading)
              const CircularProgressIndicator()
            else
              Expanded(
                child: SingleChildScrollView(
                  child: SelectableText(
                    _result.isEmpty
                        ? 'Aucun texte détecté pour le moment.'
                        : _result,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
