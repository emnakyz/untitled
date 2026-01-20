import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:untitled/services/mqtt_service.dart';
import 'package:untitled/utils/app_constants.dart';
import 'package:untitled/widgets/control_card.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IoT Sensör Kontrol',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), // Material 3 colorScheme
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final MqttService _mqttService = MqttService();

  @override
  void initState() {
    super.initState();
    _mqttService.initialize();
    _mqttService.connectionStateNotifier.addListener(_connectionListener);
  }

  @override
  void dispose() {
    _mqttService.connectionStateNotifier.removeListener(_connectionListener);
    super.dispose();
  }

  void _connectionListener() {
    final state = _mqttService.connectionStateNotifier.value;
    String message = '';
    Color backgroundColor = Colors.grey;

    if (state == MqttConnectionState.connected) {
      message = 'MQTT Bağlantısı Başarılı';
      backgroundColor = Colors.green;
    } else if (state == MqttConnectionState.disconnected) {
      message = 'MQTT Bağlantısı Koptu';
      backgroundColor = Colors.red;
    }

    if (message.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT Sensör Kontrol'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          _buildConnectionIndicator(),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSensorDisplay(),
              const SizedBox(height: 40),
              _buildControlPanel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionIndicator() {
    return ValueListenableBuilder<MqttConnectionState>(
      valueListenable: _mqttService.connectionStateNotifier,
      builder: (context, state, child) {
        Color color;
        String text;

        switch (state) {
          case MqttConnectionState.connected:
            color = Colors.green;
            text = 'Bağlı';
            break;
          case MqttConnectionState.disconnected:
            color = Colors.red;
            text = 'Bağlantı Yok';
            break;
          default:
            color = Colors.orange;
            text = 'Bağlanıyor...';
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Tooltip(
            message: 'MQTT Bağlantı Durumu',
            child: Chip(
              avatar: CircleAvatar(
                backgroundColor: color,
                radius: 6,
              ),
              label: Text(text),
              visualDensity: VisualDensity.compact,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSensorDisplay() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'Sensör Verisi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<String>(
              valueListenable: _mqttService.sensorDataNotifier,
              builder: (context, data, child) {
                return Text(
                  data,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Column(
      children: [
        const Text(
          'Kontrol Paneli',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ControlCard(
                title: 'Su Kontrolü',
                icon: Icons.water_drop,
                onOn: () => _mqttService.publishMessage(AppConstants.topicControl, AppConstants.cmdWaterOn),
                onOff: () => _mqttService.publishMessage(AppConstants.topicControl, AppConstants.cmdWaterOff),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ControlCard(
                title: 'Işık Kontrolü',
                icon: Icons.lightbulb,
                onOn: () => _mqttService.publishMessage(AppConstants.topicControl, AppConstants.cmdLightOn),
                onOff: () => _mqttService.publishMessage(AppConstants.topicControl, AppConstants.cmdLightOff),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
// _ControlCard sınıfı buradan silinip ayrı dosyaya (lib/widgets/control_card.dart) taşındı.
