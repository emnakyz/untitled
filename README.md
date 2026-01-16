# IoT Sensor Control App

A Flutter application for monitoring sensor data and controlling devices (Water and Light) via MQTT.

## Features

- **Real-time Monitoring**: Subscribes to `sensor_data` topic and displays live readings.
- **Remote Control**: Publishes commands to `control` topic to toggle devices:
  - Water (Start/Stop) -> `suac`, `sukapa`
  - Lights (On/Off) -> `isikac`, `isikkapat`
- **Connection Status**: Visual indicator for MQTT connection state.
- **Robust Architecture**: Separation of concerns with a dedicated `MqttService` class.

## Project Structure

```
lib/
├── models/
│   └── config.dart       # MQTT Configuration constants
├── services/
│   └── mqtt_service.dart # Usage of mqtt_client for connection management
└── main.dart             # UI Implementation
```

## Getting Started

1.  **Dependencies**:
    Run `flutter pub get` to install the required packages.

2.  **Configuration**:
    Update `lib/models/config.dart` with your MQTT broker credentials.

3.  **Run**:
    ```bash
    flutter run
    ```

## Requirements

- Flutter SDK: >=3.2.3
- Android SDK: 21+ (Compatible with Android 14)
- An active MQTT Broker

## License

This project is open-source.
