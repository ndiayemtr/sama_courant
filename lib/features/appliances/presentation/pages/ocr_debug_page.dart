import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/services/mlkit_label_text_recognizer.dart';
import '../../domain/services/appliance_classifier.dart';
import '../../domain/services/appliance_label_parser.dart';
import '../../domain/services/appliance_label_type_detector.dart';
import '../../domain/services/appliance_power_estimator.dart';
import '../../domain/services/label_text_normalizer.dart';
import '../../domain/services/power_resolver.dart';
import '../../domain/usecases/scan_appliance_label.dart';

class OcrDebugPage extends StatefulWidget {
  const OcrDebugPage({super.key});

  @override
  State<OcrDebugPage> createState() => _OcrDebugPageState();
}

class _OcrDebugPageState extends State<OcrDebugPage> {
  final _picker = ImagePicker();

  static const _scanApplianceLabel = ScanApplianceLabel(
    textRecognizer: MlKitLabelTextRecognizer(),
    textNormalizer: LabelTextNormalizer(),
    labelParser: ApplianceLabelParser(),
    classifier: ApplianceClassifier(),
    powerResolver: PowerResolver(),
    powerEstimator: AppliancePowerEstimator(),
    labelTypeDetector: ApplianceLabelTypeDetector(),
  );

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
      final scanResult = await _scanApplianceLabel(image.path);

      if (!mounted) return;

      context.push('/appliances/add-from-scan', extra: scanResult);
      debugPrint('OCR RAW: ${scanResult.rawOcrText}');
      debugPrint('TYPE: ${scanResult.applianceType}');
      debugPrint('POWER: ${scanResult.powerWatts}');
      debugPrint('POWER SOURCE: ${scanResult.powerSource}');
      debugPrint('CONFIDENCE: ${scanResult.confidenceLevel}');
      debugPrint('ENERGY METRICS: ${scanResult.energyConsumptionMetrics}');
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
