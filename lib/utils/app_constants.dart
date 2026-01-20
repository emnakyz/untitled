class AppConstants {
  static const String mqttServer = 'driver.cloudmqtt.com';
  static const String mqttUsername = 'xnfrrtci';
  static const String mqttPassword = 'FjrZfpbzhWrj'; // Güvenlik riski: Canlı ortamda gizlenmeli
  static const String mqttClientIdentifier = 'Flutter_Android';
  static const int mqttPort = 18968;

  // Topics
  static const String topicSensorData = 'sensor_data';
  static const String topicControl = 'control';

  // Commands
  static const String cmdWaterOn = 'suac';
  static const String cmdWaterOff = 'sukapa';
  static const String cmdLightOn = 'isikac';
  static const String cmdLightOff = 'isikkapat';
}
