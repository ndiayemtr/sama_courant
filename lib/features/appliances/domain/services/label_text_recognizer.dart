// recevoir le chemin d’une image et retourner le texte OCR brut.
abstract class LabelTextRecognizer {
  Future<String> recognizeText(String imagePath);
}
