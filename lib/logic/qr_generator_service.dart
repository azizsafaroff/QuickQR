import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';

/// Holds the text/link the user wants encoded as a QR code and handles
/// exporting the generated QR image (save to gallery, share).
class QrGeneratorService extends ChangeNotifier {
  String _text = '';

  String get text => _text;

  bool get hasText => _text.trim().isNotEmpty;

  void updateText(String value) {
    if (value == _text) return;
    _text = value;
    notifyListeners();
  }

  Future<void> pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final clipped = data?.text;
    if (clipped == null || clipped.isEmpty) return;
    updateText(clipped);
  }

  void clear() {
    if (_text.isEmpty) return;
    _text = '';
    notifyListeners();
  }

  Future<void> saveImageToGallery(Uint8List pngBytes) async {
    await Gal.putImageBytes(pngBytes, album: 'QuickQR');
  }

  Future<void> shareImage(Uint8List pngBytes) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile.fromData(pngBytes, mimeType: 'image/png', name: 'qrcode.png')],
      ),
    );
  }
}
