/// Arduino/ESP'den gelen sensör verisini parse eden model.
///.
/// Desteklenen formatlar:
/// - Arduino DHT+LDR: "humidity,temperature,lightIntensity"
/// - SEN5x extended:  "key=value,key=value,..." (air_quality formatı)
class SensorData {
  final double? humidity;
  final double? temperature;
  final double? lightIntensity;
  final double? pm1_0;
  final double? pm2_5;
  final double? pm4_0;
  final double? pm10;
  final double? vocIndex;
  final double? noxIndex;
  final String? sensorType;
  final String? location;
  final String? rawData;

  const SensorData({
    this.humidity,
    this.temperature,
    this.lightIntensity,
    this.pm1_0,
    this.pm2_5,
    this.pm4_0,
    this.pm10,
    this.vocIndex,
    this.noxIndex,
    this.sensorType,
    this.location,
    this.rawData,
  });

  /// Ham MQTT payload'ını parse eder.
  factory SensorData.fromPayload(String payload) {
    final trimmed = payload.trim();

    // SEN5x / key=value formatı algılama
    if (trimmed.contains('=')) {
      return SensorData._parseKeyValue(trimmed);
    }

    // Arduino basit CSV formatı: "humidity,temperature,lightIntensity"
    final parts = trimmed.split(',');
    if (parts.length >= 3) {
      return SensorData(
        humidity: double.tryParse(parts[0].trim()),
        temperature: double.tryParse(parts[1].trim()),
        lightIntensity: double.tryParse(parts[2].trim()),
        rawData: trimmed,
      );
    }

    // Tanınmayan format
    return SensorData(rawData: trimmed);
  }

  /// "key1=value1,key2=value2,..." formatını parse eder.
  static SensorData _parseKeyValue(String payload) {
    final map = <String, String>{};
    // Virgülle ayır ama key=value çiftlerini tanı
    final segments = payload.split(',');
    for (final seg in segments) {
      final eqIdx = seg.indexOf('=');
      if (eqIdx > 0) {
        final key = seg.substring(0, eqIdx).trim().toLowerCase();
        final value = seg.substring(eqIdx + 1).trim();
        map[key] = value;
      }
    }

    return SensorData(
      humidity: _tryDouble(map, ['humidity']),
      temperature: _tryDouble(map, ['temp', 'temperature']),
      pm1_0: _tryDouble(map, ['pm1.0']),
      pm2_5: _tryDouble(map, ['pm2.5']),
      pm4_0: _tryDouble(map, ['pm4.0']),
      pm10: _tryDouble(map, ['pm10']),
      vocIndex: _tryDouble(map, ['voc_index']),
      noxIndex: _tryDouble(map, ['nox_index']),
      sensorType: map['sensor'],
      location: map['location'],
      rawData: payload,
    );
  }

  static double? _tryDouble(Map<String, String> map, List<String> keys) {
    for (final k in keys) {
      if (map.containsKey(k)) {
        return double.tryParse(map[k]!);
      }
    }
    return null;
  }

  /// Geçerli veri olup olmadığını kontrol eder.
  bool get hasData =>
      humidity != null ||
      temperature != null ||
      lightIntensity != null ||
      pm2_5 != null;

  /// Tüm okunabilir metrikleri döndürür.
  List<SensorMetric> get metrics {
    final list = <SensorMetric>[];

    if (temperature != null) {
      list.add(SensorMetric(
        label: 'Sıcaklık',
        value: '${temperature!.toStringAsFixed(1)}°C',
        icon: '🌡️',
      ));
    }
    if (humidity != null) {
      list.add(SensorMetric(
        label: 'Nem',
        value: '%${humidity!.toStringAsFixed(1)}',
        icon: '💧',
      ));
    }
    if (lightIntensity != null) {
      list.add(SensorMetric(
        label: 'Işık',
        value: lightIntensity!.toStringAsFixed(0),
        icon: '☀️',
      ));
    }
    if (pm1_0 != null) {
      list.add(SensorMetric(
        label: 'PM1.0',
        value: pm1_0!.toStringAsFixed(1),
        icon: '🌫️',
      ));
    }
    if (pm2_5 != null) {
      list.add(SensorMetric(
        label: 'PM2.5',
        value: pm2_5!.toStringAsFixed(1),
        icon: '🌫️',
      ));
    }
    if (pm4_0 != null) {
      list.add(SensorMetric(
        label: 'PM4.0',
        value: pm4_0!.toStringAsFixed(1),
        icon: '🌫️',
      ));
    }
    if (pm10 != null) {
      list.add(SensorMetric(
        label: 'PM10',
        value: pm10!.toStringAsFixed(1),
        icon: '🌫️',
      ));
    }
    if (vocIndex != null) {
      list.add(SensorMetric(
        label: 'VOC',
        value: vocIndex!.toStringAsFixed(0),
        icon: '🧪',
      ));
    }
    if (noxIndex != null) {
      list.add(SensorMetric(
        label: 'NOx',
        value: noxIndex!.toStringAsFixed(0),
        icon: '⚗️',
      ));
    }

    return list;
  }
}

/// Tek bir sensör metriğini temsil eder.
class SensorMetric {
  final String label;
  final String value;
  final String icon;

  const SensorMetric({
    required this.label,
    required this.value,
    required this.icon,
  });
}

