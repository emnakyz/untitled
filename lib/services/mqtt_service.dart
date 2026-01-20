import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../utils/app_constants.dart';

class MqttService {
  static final MqttService _instance = MqttService._internal();

  factory MqttService() => _instance;

  MqttService._internal();

  MqttServerClient? _client;
  final ValueNotifier<String> sensorDataNotifier =
      ValueNotifier<String>('Veri Bekleniyor...');
  final ValueNotifier<MqttConnectionState> connectionStateNotifier =
      ValueNotifier<MqttConnectionState>(MqttConnectionState.disconnected);

  Timer? _reconnectTimer;

  Future<void> initialize() async {
    _client =
        MqttServerClient(AppConstants.mqttServer, AppConstants.mqttClientIdentifier);
    _client!.port = AppConstants.mqttPort;
    _client!.secure = false;
    _client!.logging(on: kDebugMode);
    _client!.keepAlivePeriod = 20;
    _client!.onDisconnected = _onDisconnected;
    _client!.onConnected = _onConnected;
    _client!.onSubscribed = _onSubscribed;

    final connMessage = MqttConnectMessage()
        .authenticateAs(AppConstants.mqttUsername, AppConstants.mqttPassword)
        .withClientIdentifier(AppConstants.mqttClientIdentifier)
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atMostOnce);
    _client!.connectionMessage = connMessage;
    _client!.autoReconnect = true; // Auto Reconnect aktif edildi

    await _connect();
  }

  Future<void> _connect() async {
     if (_client?.connectionStatus?.state == MqttConnectionState.connected) return;

    try {
      debugPrint('MQTT Connecting....');
      await _client!.connect();
    } on Exception catch (e) {
      debugPrint('MQTT Client exception - $e');
      _client!.disconnect();
    }

    if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
      debugPrint('MQTT Client Connected');
      connectionStateNotifier.value = MqttConnectionState.connected;
      _subscribeToTopic(AppConstants.topicSensorData);
    } else {
      debugPrint(
          'MQTT Client connection failed - disconnecting, state is ${_client!.connectionStatus!.state}');
      _client!.disconnect();
    }
  }

  void _subscribeToTopic(String topic) {
    if (_client?.connectionStatus?.state == MqttConnectionState.connected) {
      _client!.subscribe(topic, MqttQos.atMostOnce);
      _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
        final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;
        final String pt =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        sensorDataNotifier.value = pt;
        debugPrint(
            'MQTT_LOG: New data arrived: topic is <${c[0].topic}>, payload is <-- $pt -->');
      });
    }
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
    // Auto reconnect mantığı - kütüphanenin autoReconnect özelliği yetmezse manuel deneme
    if (!_client!.autoReconnect) {
       _reconnectTimer = Timer(const Duration(seconds: 5), _connect);
    }
  }

  void _onSubscribed(String topic) {
    debugPrint('MQTT_LOG: Subscribed to $topic');
  }

  void disconnect() {
    _client?.disconnect();
  }
}
