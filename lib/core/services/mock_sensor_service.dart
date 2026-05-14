import 'dart:math';
import 'package:plant_care/core/services/plant_knowledge_base.dart';
import 'package:plant_care/data/models/sensor_reading.dart';
import 'package:plant_care/data/models/plant_model.dart';

/// Serviço que simula leituras de sensores Arduino fictícios
/// Permite testar o sistema sem hardware real
class MockSensorService {
  final PlantKnowledgeBase knowledgeBase;
  final Random _random = Random();

  /// Histórico de leituras (para simular tendências)
  final Map<String, List<SensorReading>> _sensorHistory = {};

  /// Simula problemas ou cenários especiais
  final Map<String, MockScenario> _scenarios = {};

  MockSensorService(this.knowledgeBase);

  /// Define um cenário especial para uma planta (ex: "ressecamento")
  void setScenario(String plantId, MockScenario scenario) {
    _scenarios[plantId] = scenario;
  }

  /// Limpa o cenário de uma planta
  void clearScenario(String plantId) {
    _scenarios.remove(plantId);
  }

  /// Gera uma leitura de sensor fictícia baseada na hora do dia e tipo de planta
  SensorReading generateReading(PlantModel plant) {
    final plantInfo = knowledgeBase.getPlantInfoByType(plant.type);
    if (plantInfo == null) {
      // Fallback se tipo de planta não reconhecido
      return _generateDefaultReading(plant);
    }

    final now = DateTime.now();
    final scenario = _scenarios[plant.id];

    // Gera valores normais com variação
    double temperature = _generateTemperature(
      plantInfo.temperatureRange,
      now,
      scenario,
    );
    double humidity = _generateHumidity(
      plantInfo.humidityRange,
      now,
      scenario,
    );
    int light = _generateLight(
      plantInfo.lightRange,
      now,
      scenario,
    );
    int soilMoisture = _generateSoilMoisture(
      plant,
      plantInfo.soilMoistureRange,
      scenario,
    );

    final reading = SensorReading(
      plantId: plant.id,
      timestamp: now,
      temperature: temperature,
      humidity: humidity,
      light: light,
      soilMoisture: soilMoisture,
      source: 'mock_sensor',
    );

    // Armazena no histórico para tendências
    _sensorHistory.putIfAbsent(plant.id, () => []);
    _sensorHistory[plant.id]!.add(reading);

    // Mantém apenas últimas 100 leituras
    if (_sensorHistory[plant.id]!.length > 100) {
      _sensorHistory[plant.id]!.removeAt(0);
    }

    return reading;
  }

  /// Gera temperatura com variação ao longo do dia
  double _generateTemperature(
    NumericRange range,
    DateTime now,
    MockScenario? scenario,
  ) {
    final hour = now.hour.toDouble();
    final baseTemp = (range.min + range.max) / 2;

    // Varia -3 a +3 ao longo do dia (mais quente ao meio-dia)
    final timeVariation = 3 * sin((hour - 12) * pi / 12);

    double temp = baseTemp + timeVariation;

    // Aplica ruído aleatório
    temp += (_random.nextDouble() - 0.5) * 2;

    // Aplica cenário especial
    if (scenario?.temperatureMultiplier != null) {
      temp *= scenario!.temperatureMultiplier!;
    }

    return temp.clamp(range.min - 5, range.max + 5);
  }

  /// Gera umidade com variação ao longo do dia
  double _generateHumidity(
    NumericRange range,
    DateTime now,
    MockScenario? scenario,
  ) {
    final hour = now.hour.toDouble();
    final baseHumidity = (range.min + range.max) / 2;

    // Umidade mais alta à noite, mais baixa ao meio-dia
    final timeVariation = 10 * sin((hour - 6) * pi / 12);

    double humidity = baseHumidity + timeVariation;

    // Adiciona ruído
    humidity += (_random.nextDouble() - 0.5) * 5;

    if (scenario?.humidityMultiplier != null) {
      humidity *= scenario!.humidityMultiplier!;
    }

    return humidity.clamp(0, 100);
  }

  /// Gera luminosidade baseada na hora (simula dia/noite)
  int _generateLight(
    NumericRange range,
    DateTime now,
    MockScenario? scenario,
  ) {
    final hour = now.hour.toDouble();

    // Simula nascer do sol ~6h, pôr do sol ~18h
    double daylight = 0;
    if (hour > 6 && hour < 18) {
      // Entre 6 e 18 horas há luz
      daylight = 1 + sin((hour - 6) * pi / 12); // 0 a 2
    }

    final baseLight = (range.min + range.max) / 2;
    int light = (baseLight * daylight).toInt();

    // Adiciona variação de nuvens
    light += _random.nextInt(100) - 50;

    if (scenario?.lightMultiplier != null) {
      light = (light * scenario!.lightMultiplier!).toInt();
    }

    return light.clamp(0, 10000);
  }

  /// Gera umidade do solo
  /// Diminui gradualmente após rega, aumenta com chuva simulada
  int _generateSoilMoisture(
    PlantModel plant,
    NumericRange range,
    MockScenario? scenario,
  ) {
    final lastWatered = plant.lastWatered ?? DateTime.now();
    final timeSinceWatering = DateTime.now().difference(lastWatered).inHours;

    // Seca ~5% por hora
    double moisture = 80 - (timeSinceWatering * 2);

    // Adiciona variação diária
    final hour = DateTime.now().hour.toDouble();
    double diurnal = 5 * sin((hour - 12) * pi / 12); // Mais seco à noite
    moisture += diurnal;

    // Adiciona ruído
    moisture += (_random.nextDouble() - 0.5) * 10;

    if (scenario?.soilMoistureMultiplier != null) {
      moisture *= scenario!.soilMoistureMultiplier!;
    }

    return moisture.clamp(0, 100).toInt();
  }

  /// Fallback: gera leitura padrão sem informação de planta
  SensorReading _generateDefaultReading(PlantModel plant) {
    final now = DateTime.now();
    return SensorReading(
      plantId: plant.id,
      timestamp: now,
      temperature: 22 + (_random.nextDouble() - 0.5) * 4,
      humidity: 60 + (_random.nextDouble() - 0.5) * 20,
      light: 300 + _random.nextInt(500),
      soilMoisture: 60 + (_random.nextInt(20) - 10),
      source: 'mock_sensor',
    );
  }

  /// Retorna histórico de leituras de uma planta
  List<SensorReading> getHistory(String plantId, {int hours = 24}) {
    final history = _sensorHistory[plantId] ?? [];
    final cutoff = DateTime.now().subtract(Duration(hours: hours));
    return history.where((r) => r.timestamp.isAfter(cutoff)).toList();
  }

  /// Média de uma métrica nos últimas N horas
  double getAverageMetric(
    String plantId,
    String metric, {
    int hours = 24,
  }) {
    final history = getHistory(plantId, hours: hours);
    if (history.isEmpty) return 0;

    double sum = 0;
    for (final reading in history) {
      switch (metric.toLowerCase()) {
        case 'temperature':
          sum += reading.temperature;
          break;
        case 'humidity':
          sum += reading.humidity;
          break;
        case 'light':
          sum += reading.light;
          break;
        case 'soilmoisture':
          sum += reading.soilMoisture;
          break;
      }
    }
    return sum / history.length;
  }

  /// Limpa todo o histórico
  void clearHistory() {
    _sensorHistory.clear();
  }

  /// Limpa histórico de uma planta
  void clearPlantHistory(String plantId) {
    _sensorHistory.remove(plantId);
  }
}

/// Representa um cenário especial para simular problemas
class MockScenario {
  final String name;

  /// Multiplicador de temperatura (ex: 0.8 = mais frio)
  final double? temperatureMultiplier;

  /// Multiplicador de umidade
  final double? humidityMultiplier;

  /// Multiplicador de luz
  final double? lightMultiplier;

  /// Multiplicador de umidade do solo
  final double? soilMoistureMultiplier;

  /// Descrição do cenário
  final String description;

  MockScenario({
    required this.name,
    this.temperatureMultiplier,
    this.humidityMultiplier,
    this.lightMultiplier,
    this.soilMoistureMultiplier,
    required this.description,
  });

  /// Cenários pré-definidos
  static final Map<String, MockScenario> presets = {
    'drought': MockScenario(
      name: 'Drought (Seca)',
      soilMoistureMultiplier: 0.4,
      humidityMultiplier: 0.8,
      description: 'Planta está ressecando. Umidade do solo e do ar reduzidas.',
    ),
    'overwatering': MockScenario(
      name: 'Overwatering (Excesso de Água)',
      soilMoistureMultiplier: 1.5,
      humidityMultiplier: 1.2,
      description: 'Planta regada em excesso. Risco de apodrecimento.',
    ),
    'cold': MockScenario(
      name: 'Cold (Frio)',
      temperatureMultiplier: 0.7,
      description: 'Temperatura baixa. Planta em estresse pelo frio.',
    ),
    'heat': MockScenario(
      name: 'Heat (Calor)',
      temperatureMultiplier: 1.3,
      humidityMultiplier: 0.8,
      description: 'Temperatura alta com umidade reduzida.',
    ),
    'low_light': MockScenario(
      name: 'Low Light (Pouca Luz)',
      lightMultiplier: 0.3,
      description: 'Planta recebendo pouca luz solar.',
    ),
    'high_humidity': MockScenario(
      name: 'High Humidity (Umidade Alta)',
      humidityMultiplier: 1.5,
      soilMoistureMultiplier: 1.1,
      description: 'Ambiente muito úmido. Risco de fungos.',
    ),
  };
}
