// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untitled/main.dart';

void main() {
  testWidgets('App starts and shows basic UI elements', (WidgetTester tester) async {
    await dotenv.load(fileName: "test/.env.test");

    await tester.pumpWidget(const MyApp());

    // Başlık kontrolü
    expect(find.text('IoT Kontrol'), findsOneWidget);

    // Bekleniyor kartı kontrolü
    expect(find.text('Sensör Verisi Bekleniyor...'), findsOneWidget);

    // Kontrol kartları
    expect(find.text('Su'), findsOneWidget);
    expect(find.text('Işık'), findsOneWidget);
  });
}
