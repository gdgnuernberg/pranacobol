import 'package:flutter_test/flutter_test.dart';
import 'package:pranacobol_web/main.dart';

void main() {
  testWidgets('PranaCOBOL web app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PranaCobolApp());

    // Pump multiple times to allow async initApp to execute (catches the HTTP exception and completes loading)
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }

    // Verify that the logo name is present
    expect(find.text('PranaCOBOL'), findsOneWidget);
  });
}

