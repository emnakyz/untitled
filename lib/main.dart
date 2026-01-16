import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:untitled/services/mqtt_service.dart';

void main() {
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
        primarySwatch: Colors.blue,
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT Sensör Kontrol'),
        centerTitle: true,
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
          child: Chip(
            avatar: CircleAvatar(
              backgroundColor: color,
              radius: 6,
            ),
            label: Text(text),
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
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.blueAccent,
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
            _ControlCard(
              title: 'Su Kontrolü',
              icon: Icons.water_drop,
              onOn: () => _mqttService.publishMessage('control', 'suac'),
              onOff: () => _mqttService.publishMessage('control', 'sukapa'),
            ),
            _ControlCard(
              title: 'Işık Kontrolü',
              icon: Icons.lightbulb,
              onOn: () => _mqttService.publishMessage('control', 'isikac'),
              onOff: () => _mqttService.publishMessage('control', 'isikkapat'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ControlCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onOn;
  final VoidCallback onOff;

  const _ControlCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.onOn,
    required this.onOff,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.blueGrey),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onOn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('AÇ'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: onOff,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('KAPAT'),
            ),
          ],
        ),
      ),
    );
  }
}
