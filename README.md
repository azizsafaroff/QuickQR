# QuickQR

A simple QR code scanner and generator that works fully offline — no
backend, no API calls.

## Setup

1. Install dependencies:
   ```
   flutter pub get
   ```
2. Run the app:
   ```
   flutter run
   ```

No `.env` or API key is needed — everything runs on-device.

## What it does

- **Generate tab** — type or paste text/a link into an input field and a QR
  code is generated live as you type. Paste from clipboard, clear the
  input, save the code as an image to the device gallery, or share it to
  other apps.
- **Scan tab** — scans QR codes in real time using the device camera, or
  pick an image from the gallery to scan a QR code from a saved photo. A
  detected code opens a bottom sheet showing the result: tap **Open Link**
  if it's a URL, or **Copy** to copy the text to the clipboard.
- **History tab** — a persisted list of past scans (survives app restarts),
  each showing a relative timestamp. Tapping an entry reopens the result
  sheet.

## Structure

- `lib/logic/qr_generator_service.dart` — the Generate tab's state
  (`ChangeNotifier`): current text, clipboard paste/clear, save-to-gallery
  (`gal`), share (`share_plus`)
- `lib/logic/scan_history_service.dart` — scan history state
  (`ChangeNotifier`): persistence (`shared_preferences`), URL detection,
  clipboard copy, opening links (`url_launcher`), decoding a picked gallery
  image (`mobile_scanner`)
- `lib/ui/` — `generate_tab.dart`, `scan_tab.dart`, `history_tab.dart`,
  `home_screen.dart` (bottom nav), plus `widgets/` (scan result bottom
  sheet, camera scan overlay, "copied" toast) and `utils/` (relative time
  formatting). Built to match the mockup in
  `../quickqr_design/QuickQR.dc.html`; icons use the `lucide_icons` package
  to match that design's icon set.
- `lib/main.dart` — provider wiring, Manrope/JetBrains Mono text theme, and
  a global tap-outside-to-dismiss-keyboard gesture handler

## Notes

- Camera and photo-library permissions are already declared in
  `android/app/src/main/AndroidManifest.xml` and `ios/Runner/Info.plist`.
- Android and iOS only — `mobile_scanner`'s live camera scanning and `gal`'s
  gallery save don't support macOS/web/desktop, so this app isn't built for
  those platforms.
- Tested on Android (`emulator-5554`).
