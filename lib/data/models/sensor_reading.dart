/// Modelo que representa uma leitura de sensores (real ou simulada)
class SensorReading {
  final String plantId;
  final DateTime timestamp;
  
  /// Temperatura em Celsius
  final double temperature;
  
  /// Umidade do ar em percentual (0-100)
  final double humidity;
  
  /// Luminosidade em lux (0-10000)
  final int light;
  
  /// Umidade do solo em percentual (0-100)
  final int soilMoisture;
  
  /// Fonte dos dados (mock, arduino, etc)
  final String source;

  SensorReading({
    required this.plantId,
    required this.timestamp,
    required this.temperature,
    required this.humidity,
    required this.light,
    required this.soilMoisture,
    this.source = 'mock',
  });

  /// Converte para JSON para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'plantId': plantId,
      'timestamp': timestamp.toIso8601String(),
      'temperature': temperature,
      'humidity': humidity,
      'light': light,
      'soilMoisture': soilMoisture,
      'source': source,
    };
  }

  /// Cria a partir de Firestore
  factory SensorReading.fromMap(Map<String, dynamic> map) {
    return SensorReading(
      plantId: map['plantId'] ?? '',
      timestamp: DateTime.parse(map['timestamp'] ?? DateTime.now().toIso8601String()),
      temperature: (map['temperature'] ?? 0).toDouble(),
      humidity: (map['humidity'] ?? 0).toDouble(),
      light: (map['light'] ?? 0).toInt(),
      soilMoisture: (map['soilMoisture'] ?? 0).toInt(),
      source: map['source'] ?? 'unknown',
    );
  }

  @override
  String toString() {
    return 'SensorReading(temp: ${temperature.toStringAsFixed(1)}°C, '
        'humidity: $humidity%, '
        'light: $light lux, '
        'soilMoisture: $soilMoisture%)';
  }
}

/// Intervalo numérico com mín e máx
class NumericRange {
  final double min;
  final double max;

  const NumericRange({required this.min, required this.max});

  bool isInRange(double value) => value >= min && value <= max;
  
  double clamp(double value) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  /// Calcula distância em percentual do ideal
  /// 0% = perfeito, 100% = muito longe
  double deviationPercent(double value) {
    if (isInRange(value)) return 0;
    if (value < min) return ((min - value) / (min * 0.5)).clamp(0, 1) * 100;
    return ((value - max) / (max * 0.5)).clamp(0, 1) * 100;
  }
}
