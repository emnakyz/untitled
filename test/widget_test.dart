// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:untitled/main.dart';

void main() {
  testWidgets('App starts and shows basic UI elements', (WidgetTester tester) async {
    // Test ortamı için gerekli çevresel değişkenleri yükle
    await dotenv.load(fileName: "test/.env.test");

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Başlık kontrolü
    expect(find.text('IoT Sensör Kontrol'), findsOneWidget);

    // Sensör verisi başlangıç metni kontrolü
    expect(find.text('Veri Bekleniyor...'), findsOneWidget);

    // Bağlantı durumu "Bağlantı Yok" veya "Bağlanıyor..." olarak başlayabilir
    // Initial state MqttService'de disconnected olarak tanımlı
    // UI açıldığında initState içinde initialize çağrılıyor ama asenkron olduğu için hemen bağlanmaz.
    // Varsayılan olarak ValueNotifier disconnected ile başlar.

    // Bağlantı durumu göstergesi
    expect(find.byType(Chip), findsOneWidget); // Bağlantı durumu bir Chip içinde gösteriliyor
  });
}


