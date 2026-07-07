import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ScanEntry {
  ScanEntry({required this.value, required this.scannedAt});

  final String value;
  final DateTime scannedAt;

  Map<String, dynamic> toJson() => {
        'value': value,
        'scannedAt': scannedAt.toIso8601String(),
      };

  factory ScanEntry.fromJson(Map<String, dynamic> json) => ScanEntry(
        value: json['value'] as String,
        scannedAt: DateTime.parse(json['scannedAt'] as String),
      );
}

/// Manages scanned QR results: persisted history, clipboard/URL actions,
/// and decoding barcodes from a live camera feed or a picked gallery image.
class ScanHistoryService extends ChangeNotifier {
  ScanHistoryService() {
    _load();
  }

  static const _prefsKey = 'quickqr_scan_history';
  static const _maxEntries = 100;
  static const _duplicateWindow = Duration(seconds: 3);

  final MobileScannerController _imageScanController = MobileScannerController();
  final ImagePicker _imagePicker = ImagePicker();

  List<ScanEntry> _history = [];
  bool _loaded = false;
  String? _lastAddedValue;
  DateTime? _lastAddedAt;

  List<ScanEntry> get history => List.unmodifiable(_history);

  bool get loaded => _loaded;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      _history = decoded
          .map((e) => ScanEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_history.map((e) => e.toJson()).toList());
    await prefs.setString(_prefsKey, encoded);
  }

  /// Records a newly scanned value, ignoring rapid duplicate detections of
  /// the same code (e.g. while it stays in frame during live scanning).
  Future<void> addScan(String value) async {
    if (value.isEmpty) return;
    final now = DateTime.now();
    if (_lastAddedValue == value &&
        _lastAddedAt != null &&
        now.difference(_lastAddedAt!) < _duplicateWindow) {
      return;
    }
    _lastAddedValue = value;
    _lastAddedAt = now;

    _history.insert(0, ScanEntry(value: value, scannedAt: now));
    if (_history.length > _maxEntries) {
      _history.removeRange(_maxEntries, _history.length);
    }
    notifyListeners();
    await _persist();
  }

  Future<void> clearHistory() async {
    if (_history.isEmpty) return;
    _history = [];
    notifyListeners();
    await _persist();
  }

  /// Opens the gallery picker. Returns the picked image path, or null if
  /// the user cancelled.
  Future<String?> pickImageFromGallery() async {
    final file = await _imagePicker.pickImage(source: ImageSource.gallery);
    return file?.path;
  }

  /// Decodes a QR code from an image file and records it in history.
  /// Returns the decoded value, or null if no barcode was found.
  Future<String?> scanImageFile(String path) async {
    final capture = await _imageScanController.analyzeImage(path);
    final barcodes = capture?.barcodes ?? const <Barcode>[];
    if (barcodes.isEmpty) return null;
    final raw = barcodes.first.rawValue;
    if (raw == null || raw.isEmpty) return null;
    await addScan(raw);
    return raw;
  }

  bool isUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) return false;
    return (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
  }

  Future<bool> openUrl(String value) async {
    final uri = Uri.tryParse(value);
    if (uri == null) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> copyToClipboard(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
  }

  @override
  void dispose() {
    _imageScanController.dispose();
    super.dispose();
  }
}
