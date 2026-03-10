import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:untitled/models/sensor_data.dart';
import 'package:untitled/services/mqtt_service.dart';
import 'package:untitled/utils/app_constants.dart';
import 'package:untitled/widgets/control_card.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IoT Kontrol',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007AFF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF2F2F7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF2F2F7),
          elevation: 0,
          scrolledUnderElevation: 0.5,
        ),
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
    _mqttService.disconnect();
    super.dispose();
  }

  void _connectionListener() {
    final state = _mqttService.connectionStateNotifier.value;
    String message = '';
    Color backgroundColor = Colors.grey;

    if (state == MqttConnectionState.connected) {
      message = 'MQTT Bağlantısı Başarılı';
      backgroundColor = const Color(0xFF34C759);
    } else if (state == MqttConnectionState.disconnected) {
      message = 'MQTT Bağlantısı Koptu';
      backgroundColor = const Color(0xFFFF3B30);
    }

    if (message.isNotEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: const TextStyle(fontWeight: FontWeight.w500)),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              title: const Text(
                'IoT Kontrol',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 28),
              ),
              actions: [_buildConnectionIndicator()],
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 8),
                  _buildSensorDisplay(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Kontroller'),
                  const SizedBox(height: 12),
                  _buildControlPanel(),
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade800,
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
            color = const Color(0xFF34C759);
            text = 'Bağlı';
            break;
          case MqttConnectionState.disconnected:
            color = const Color(0xFFFF3B30);
            text = 'Bağlantı Yok';
            break;
          default:
            color = const Color(0xFFFF9500);
            text = 'Bağlanıyor...';
        }

        return Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  text,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSensorDisplay() {
    return ValueListenableBuilder<SensorData?>(
      valueListenable: _mqttService.sensorDataNotifier,
      builder: (context, data, child) {
        if (data == null) {
          return _buildWaitingCard();
        }

        if (!data.hasData) {
          return _buildRawDataCard(data.rawData ?? 'Bilinmeyen format');
        }

        final metrics = data.metrics;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Sensör Verileri'),
            if (data.location != null || data.sensorType != null)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 8),
                child: Text(
                  [
                    if (data.sensorType != null) data.sensorType,
                    if (data.location != null) data.location,
                  ].join(' • '),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.6,
              ),
              itemCount: metrics.length,
              itemBuilder: (context, index) {
                return _buildMetricCard(metrics[index]);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard(SensorMetric metric) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(metric.icon, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  metric.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              metric.value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1C1C1E),
                letterSpacing: -0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaitingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.sensors, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Sensör Verisi Bekleniyor...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'MQTT bağlantısı kurulduğunda veriler otomatik gösterilecek',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRawDataCard(String rawData) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ham Veri',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            rawData,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'monospace',
              color: Color(0xFF1C1C1E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Row(
      children: [
        Expanded(
          child: ControlCard(
            title: 'Su',
            icon: Icons.water_drop_rounded,
            onOn: () => _mqttService.publishMessage(
                AppConstants.topicControl, AppConstants.cmdWaterOn),
            onOff: () => _mqttService.publishMessage(
                AppConstants.topicControl, AppConstants.cmdWaterOff),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ControlCard(
            title: 'Işık',
            icon: Icons.lightbulb_rounded,
            onOn: () => _mqttService.publishMessage(
                AppConstants.topicControl, AppConstants.cmdLightOn),
            onOff: () => _mqttService.publishMessage(
                AppConstants.topicControl, AppConstants.cmdLightOff),
          ),
        ),
      ],
    );
  }
}
