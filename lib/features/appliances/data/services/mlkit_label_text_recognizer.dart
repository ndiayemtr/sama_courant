import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../domain/services/label_text_recognizer.dart';

class MlKitLabelTextRecognizer implements LabelTextRecognizer {
  const MlKitLabelTextRecognizer();

  @override
  Future<String> recognizeText(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);

    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final recognizedText = await textRecognizer.processImage(inputImage);

      return recognizedText.text;
    } finally {
      await textRecognizer.close();
    }
  }
}
