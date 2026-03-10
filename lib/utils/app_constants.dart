import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // MQTT yapılandırması (.env dosyasından okunur)
  static String get mqttServer => dotenv.env['MQTT_SERVER'] ?? '';
  static String get mqttUsername => dotenv.env['MQTT_USERNAME'] ?? '';
  static String get mqttPassword => dotenv.env['MQTT_PASSWORD'] ?? '';
  static String get mqttClientIdentifier =>
      dotenv.env['MQTT_CLIENT_ID'] ?? 'Flutter_Client_${DateTime.now().millisecondsSinceEpoch}';
  static int get mqttPort =>
      int.tryParse(dotenv.env['MQTT_PORT'] ?? '1883') ?? 1883;
  static bool get mqttUseTls =>
      (dotenv.env['MQTT_USE_TLS'] ?? 'false').toLowerCase() == 'true';

  // Topics
  static const String topicSensorData = 'sensor_data';
  static const String topicControl = 'control';

  // Commands — Arduino callback'indeki string'lerle birebir eşleşmeli
  static const String cmdWaterOn = 'suac';
  static const String cmdWaterOff = 'sukapa';
  static const String cmdLightOn = 'isikac';
  static const String cmdLightOff = 'isikkapat';
}
