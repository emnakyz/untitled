import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../models/sensor_data.dart';
import '../utils/app_constants.dart';

class MqttService {
  static final MqttService _instance = MqttService._internal();

  factory MqttService() => _instance;

  MqttService._internal();

  MqttServerClient? _client;
  StreamSubscription? _updatesSubscription;

  /// Parse edilmiş sensör verisi notifier'ı.
  final ValueNotifier<SensorData?> sensorDataNotifier =
      ValueNotifier<SensorData?>(null);
  final ValueNotifier<MqttConnectionState> connectionStateNotifier =
      ValueNotifier<MqttConnectionState>(MqttConnectionState.disconnected);

  Timer? _reconnectTimer;
  bool _isConnecting = false;

  /// MQTT istemcisini başlatır ve bağlantı kurar.
  Future<void> initialize() async {
    final server = AppConstants.mqttServer;
    if (server.isEmpty) {
      debugPrint(
          'MQTT_LOG: MQTT_SERVER .env dosyasında tanımlı değil, bağlantı atlanıyor.');
      return;
    }

    _client = MqttServerClient(server, AppConstants.mqttClientIdentifier);
    _client!.port = AppConstants.mqttPort;
    _client!.keepAlivePeriod = 20;
    _client!.connectTimeoutPeriod = 5000;
    _client!.onDisconnected = _onDisconnected;
    _client!.onConnected = _onConnected;
    _client!.onSubscribed = _onSubscribed;
    _client!.autoReconnect = true;
    _client!.onAutoReconnect = _onAutoReconnect;
    _client!.onAutoReconnected = _onAutoReconnected;

    // Güvenlik: TLS kullan (port 8883) veya cleartext (port 1883)
    if (AppConstants.mqttPort == 8883 || AppConstants.mqttUseTls) {
      _client!.secure = true;
      _client!.securityContext = SecurityContext.defaultContext;
    } else {
      _client!.secure = false;
    }

    // Debug modda loglama aç, ama release'de hassas bilgi loglanmasın
    _client!.logging(on: kDebugMode);

    final connMessage = MqttConnectMessage()
        .authenticateAs(AppConstants.mqttUsername, AppConstants.mqttPassword)
        .withClientIdentifier(AppConstants.mqttClientIdentifier)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    _client!.connectionMessage = connMessage;

    await _connect();
  }

  Future<void> _connect() async {
    if (_isConnecting) return;
    if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
      return;
    }

    _isConnecting = true;
    connectionStateNotifier.value = MqttConnectionState.connecting;

    try {
      debugPrint('MQTT Connecting....');
      await _client!.connect();
    } on Exception catch (e) {
      debugPrint('MQTT Client exception - $e');
      _client?.disconnect();
    } finally {
      _isConnecting = false;
    }

    if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
      debugPrint('MQTT Client Connected');
      connectionStateNotifier.value = MqttConnectionState.connected;
      _subscribeToTopic(AppConstants.topicSensorData);
    } else {
      debugPrint(
          'MQTT Client connection failed - state is ${_client?.connectionStatus?.state}');
      connectionStateNotifier.value = MqttConnectionState.disconnected;
    }
  }

  void _subscribeToTopic(String topic) {
    if (_client?.connectionStatus?.state != MqttConnectionState.connected) {
      return;
    }

    _client!.subscribe(topic, MqttQos.atMostOnce);

    // Önceki dinleyiciyi iptal et, çift dinlemeyi önle
    _updatesSubscription?.cancel();
    _updatesSubscription =
        _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      if (c == null || c.isEmpty) return;
      final recMess = c[0].payload as MqttPublishMessage;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      // Veriyi parse et
      sensorDataNotifier.value = SensorData.fromPayload(pt);
      debugPrint('MQTT_LOG: topic: <${c[0].topic}>, payload length: ${pt.length}');
    });
  }

  void publishMessage(String topic, String message) {
    if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      _client!.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
    } else {
      debugPrint('MQTT_LOG: Cannot publish, client is not connected');
    }
  }

  void _onConnected() {
    debugPrint('MQTT_LOG: Connected');
    connectionStateNotifier.value = MqttConnectionState.connected;
    _reconnectTimer?.cancel();
  }

  void _onDisconnected() {
    debugPrint('MQTT_LOG: Disconnected');
    connectionStateNotifier.value = MqttConnectionState.disconnected;
  }

  void _onAutoReconnect() {
    debugPrint('MQTT_LOG: Auto reconnect başlatıldı...');
    connectionStateNotifier.value = MqttConnectionState.connecting;
  }

  void _onAutoReconnected() {
    debugPrint('MQTT_LOG: Auto reconnect başarılı');
    connectionStateNotifier.value = MqttConnectionState.connected;
    _subscribeToTopic(AppConstants.topicSensorData);
  }

  void _onSubscribed(String topic) {
    debugPrint('MQTT_LOG: Subscribed to $topic');
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _updatesSubscription?.cancel();
    _client?.disconnect();
  }

  /// Kaynakları serbest bırakır.
  void dispose() {
    disconnect();
    sensorDataNotifier.dispose();
    connectionStateNotifier.dispose();
  }
}
