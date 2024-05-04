import 'package:untitled/models/config.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT Sensör Kontrol',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  MqttServerClient? client;
  late MqttConnectionState connectionState;
  String sensorData = 'Şu anda veri yok';

  @override
  void initState() {
    super.initState();
    connectToMqtt();
  }

  void connectToMqtt() async {

    client = MqttServerClient(MqttConfig.server,MqttConfig.clientIdentifier);
    client!.port = MqttConfig.port;
    client!.secure = false;
    client!.logging(on: true);
    client!.keepAlivePeriod = MqttClientConstants.defaultKeepAlive;
    client!.onDisconnected = onDisconnected;

    final connMessage = MqttConnectMessage()
    // .authenticateAs(MqttConfig.username,MqttConfig.password)
        .withClientIdentifier(MqttConfig.clientIdentifier)
        .startClean();
    client!.connectionMessage = connMessage;


    try {
      print('MQTT client connected');
      await client!.connect(MqttConfig.username,MqttConfig.password);

      client!.subscribe('sensor_data', MqttQos.atMostOnce);
      client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
        final MqttPublishMessage message = c[0].payload as MqttPublishMessage;
        final String payload =
        MqttPublishPayload.bytesToStringAsString(message.payload.message);
        setState(() {
          sensorData = payload;
        });
      });


    }
    catch (e) {
      print('Exception: $e');
      client!.disconnect();
      // _onDisconnected();
      // _disconnect();
    }

    /// Bağlı olup olmadığımızı kontrol eder
    if (client!.connectionStatus!.state == MqttConnectionState.connected) {
      print('MQTT client connected');
      setState(() {
        connectionState = client!.connectionStatus!.state;
      });
    } else {
      print('ERROR: MQTT client connection failed - '
          'disconnecting, state is ${client!.connectionStatus!.state}');
      _disconnect();
    }
  }

  void onDisconnected() {
    print('Disconnected');
    // MQTT aracısına yeniden bağlanın
    connectToMqtt();
  }
  void _disconnect() {
    client!.disconnect();
    _onDisconnected();
  }
  void _onDisconnected() {
    print('MQTT client disconnected');
  }

  void sendMqttCommand(String command) {
    final  builder = MqttClientPayloadBuilder();
    builder.addString(command);
    client!.publishMessage('control', MqttQos.exactlyOnce, builder.payload!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IoT Sensör Kontrol'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Sensör Verisi: $sensorData'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                sendMqttCommand('suac');
              },
              child: Text('Su Aç'),
            ),
            ElevatedButton(
              onPressed: () {
                sendMqttCommand('sukapa');
              },
              child: Text('Su Kapa'),
            ),
            ElevatedButton(
              onPressed: () {
                sendMqttCommand('isikac');
              },
              child: Text('Işık Aç'),
            ),
            ElevatedButton(
              onPressed: () {
                sendMqttCommand('isikkapat');
              },
              child: Text('Işık Kapat'),
            ),
          ],
        ),
      ),
    );
  }
}
