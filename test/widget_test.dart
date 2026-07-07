import 'package:flutter_test/flutter_test.dart';

import 'package:quickqr/main.dart';

void main() {
  testWidgets('QuickQR renders Generate and Scan tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const QuickQrApp());
    await tester.pumpAndSettle();

    expect(find.text('Generate'), findsWidgets);
    expect(find.text('Scan'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
  });
}
