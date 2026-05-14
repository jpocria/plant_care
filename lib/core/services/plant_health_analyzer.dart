import 'package:plant_care/core/services/plant_knowledge_base.dart';
import 'package:plant_care/core/services/mock_sensor_service.dart';
import 'package:plant_care/data/models/plant_health_analysis.dart';
import 'package:plant_care/data/models/sensor_reading.dart';
import 'package:plant_care/data/models/plant_model.dart';

/// Serviço que analisa a saúde de uma planta baseado em leituras de sensores
/// Usa a base de conhecimento para comparar valores ideais vs reais
class PlantHealthAnalyzer {
  final PlantKnowledgeBase knowledgeBase;
  final MockSensorService mockSensorService;

  PlantHealthAnalyzer(this.knowledgeBase, this.mockSensorService);

  /// Analisa a saúde completa de uma planta
  PlantHealthAnalysis analyzeHealth(
    SensorReading reading,
    PlantModel plant,
  ) {
    final plantInfo = knowledgeBase.getPlantInfoByType(plant.type);
    
    if (plantInfo == null) {
      return PlantHealthAnalysis.empty();
    }

    // Calcula scores individuais (0-100)
    final temperatureScore = _calculateTemperatureScore(reading.temperature, plantInfo);
    final humidityScore = _calculateHumidityScore(reading.humidity, plantInfo);
    final lightScore = _calculateLightScore(reading.light, plantInfo);
    final soilMoistureScore = _calculateSoilMoistureScore(reading.soilMoisture, plantInfo);

    // Score geral é média ponderada
    final healthScore = (
      temperatureScore * 0.25 +
      humidityScore * 0.25 +
      lightScore * 0.25 +
      soilMoistureScore * 0.25
    ).round();

    // Determina status
    final status = _scoreToStatus(healthScore);

    // Detecta problemas
    final issues = _detectIssues(reading, plantInfo, plant);

    // Gera recomendações
    final recommendations = _generateRecommendations(
      reading,
      plantInfo,
      plant,
      issues,
    );

    // Calcula necessidade de rega
    final nextWatering = plant.nextWatering ?? DateTime.now().add(Duration(days: 3));
    final needsWatering = nextWatering.isBefore(DateTime.now());
    final daysUntilWatering = nextWatering.difference(DateTime.now()).inDays.toDouble();

    return PlantHealthAnalysis(
      healthScore: healthScore,
      status: status,
      recommendations: recommendations,
      issues: issues,
      temperatureScore: temperatureScore.toDouble(),
      humidityScore: humidityScore.toDouble(),
      lightScore: lightScore.toDouble(),
      soilMoistureScore: soilMoistureScore.toDouble(),
      analyzedAt: DateTime.now(),
      needsWatering: needsWatering,
      daysUntilNextWatering: daysUntilWatering,
    );
  }

  /// Calcula score de temperatura (0-100)
  int _calculateTemperatureScore(double temp, PlantCareInfo plantInfo) {
    if (plantInfo.temperatureRange.isInRange(temp)) {
      return 100; // Perfeito
    }

    final deviation = plantInfo.temperatureRange.deviationPercent(temp);
    return (100 - deviation).clamp(0, 100).toInt();
  }

  /// Calcula score de umidade do ar (0-100)
  int _calculateHumidityScore(double humidity, PlantCareInfo plantInfo) {
    if (plantInfo.humidityRange.isInRange(humidity)) {
      return 100;
    }

    final deviation = plantInfo.humidityRange.deviationPercent(humidity);
    return (100 - deviation).clamp(0, 100).toInt();
  }

  /// Calcula score de luz (0-100)
  int _calculateLightScore(int light, PlantCareInfo plantInfo) {
    if (plantInfo.lightRange.isInRange(light.toDouble())) {
      return 100;
    }

    final deviation = plantInfo.lightRange.deviationPercent(light.toDouble());
    return (100 - deviation).clamp(0, 100).toInt();
  }

  /// Calcula score de umidade do solo (0-100)
  int _calculateSoilMoistureScore(int moisture, PlantCareInfo plantInfo) {
    if (plantInfo.soilMoistureRange.isInRange(moisture.toDouble())) {
      return 100;
    }

    final deviation = plantInfo.soilMoistureRange.deviationPercent(moisture.toDouble());
    return (100 - deviation).clamp(0, 100).toInt();
  }

  /// Converte score para status textual
  String _scoreToStatus(int score) {
    if (score >= 85) return 'excellent';
    if (score >= 70) return 'good';
    if (score >= 55) return 'fair';
    if (score >= 40) return 'poor';
    return 'critical';
  }

  /// Detecta problemas específicos
  List<String> _detectIssues(
    SensorReading reading,
    PlantCareInfo plantInfo,
    PlantModel plant,
  ) {
    final List<String> issues = [];

    // Problema de temperatura
    if (reading.temperature < plantInfo.temperatureRange.min - 5) {
      issues.add('🥶 Temperatura MUITO baixa (${reading.temperature.toStringAsFixed(1)}°C)');
    } else if (reading.temperature > plantInfo.temperatureRange.max + 5) {
      issues.add('🔥 Temperatura MUITO alta (${reading.temperature.toStringAsFixed(1)}°C)');
    } else if (!plantInfo.temperatureRange.isInRange(reading.temperature)) {
      issues.add('⚠️ Temperatura fora do ideal');
    }

    // Problema de umidade do ar
    if (reading.humidity < plantInfo.humidityRange.min - 15) {
      issues.add('🏜️ Ar MUITO seco (${reading.humidity.toStringAsFixed(1)}%)');
    } else if (reading.humidity > plantInfo.humidityRange.max + 15) {
      issues.add('💧 Ar MUITO úmido (${reading.humidity.toStringAsFixed(1)}%) - Risco de mofo');
    } else if (!plantInfo.humidityRange.isInRange(reading.humidity)) {
      issues.add('⚠️ Umidade do ar fora do ideal');
    }

    // Problema de luz
    if (reading.light < plantInfo.lightRange.min * 0.5) {
      issues.add('🌑 LUZ INSUFICIENTE (${reading.light} lux)');
    } else if (reading.light > plantInfo.lightRange.max * 1.5) {
      issues.add('🌞 Luz EXCESSIVA');
    } else if (!plantInfo.lightRange.isInRange(reading.light.toDouble())) {
      issues.add('⚠️ Luminosidade fora do ideal');
    }

    // Problema de solo
    if (reading.soilMoisture < plantInfo.soilMoistureRange.min - 20) {
      issues.add('💀 Solo MUITO seco - REGUE COM URGÊNCIA');
    } else if (reading.soilMoisture > plantInfo.soilMoistureRange.max + 20) {
      issues.add('🌊 Solo MUITO úmido - Risco de apodrecimento');
    } else if (!plantInfo.soilMoistureRange.isInRange(reading.soilMoisture.toDouble())) {
      issues.add('⚠️ Umidade do solo fora do ideal');
    }

    // Problema de rega
    final nextWatering = plant.nextWatering ?? DateTime.now().add(Duration(days: 3));
    if (nextWatering.isBefore(DateTime.now().subtract(Duration(days: 2)))) {
      issues.add('🚨 REGA ATRASADA há ${DateTime.now().difference(nextWatering).inDays} dias!');
    } else if (nextWatering.isBefore(DateTime.now())) {
      issues.add('💧 Hora de regar');
    }

    return issues;
  }

  /// Gera recomendações baseadas nos problemas
  List<String> _generateRecommendations(
    SensorReading reading,
    PlantCareInfo plantInfo,
    PlantModel plant,
    List<String> issues,
  ) {
    final List<String> recommendations = [];

    if (issues.isEmpty) {
      recommendations.add('✅ Perfeito! Continue cuidando assim.');
      return recommendations;
    }

    // Recomendações por temperatura
    if (reading.temperature < plantInfo.temperatureRange.min - 5) {
      recommendations.add(
        'Mova a planta para local mais quente. '
        'Evite correntes de ar frio.',
      );
    } else if (reading.temperature > plantInfo.temperatureRange.max + 5) {
      recommendations.add(
        'Mova a planta para local mais fresco. '
        'Aumente ventilação.',
      );
    }

    // Recomendações por umidade
    if (reading.humidity < plantInfo.humidityRange.min - 15) {
      recommendations.add(
        'Aumente umidade: coloque um umidificador, '
        'um prato com água próximo, ou pulverize folhagem 1x por dia.',
      );
    } else if (reading.humidity > plantInfo.humidityRange.max + 15) {
      recommendations.add(
        'Reduza umidade: melhore ventilação, '
        'não pulverize, reduza rega.',
      );
    }

    // Recomendações por luz
    if (reading.light < plantInfo.lightRange.min * 0.5) {
      recommendations.add(
        'AUMENTE LUZ: mude para perto de janela ou '
        'use lâmpada de crescimento (LED 40W mínimo).',
      );
    }

    // Recomendações por solo
    if (reading.soilMoisture < plantInfo.soilMoistureRange.min - 20) {
      recommendations.add(
        'REGUE AGORA! Solo muito seco. '
        'Regue até água drenar dos furos de drenagem.',
      );
    } else if (reading.soilMoisture > plantInfo.soilMoistureRange.max + 20) {
      recommendations.add(
        'Reduza rega: deixe solo secar entre regas. '
        'Certifique-se que há furos de drenagem no vaso.',
      );
    }

    // Dica geral se muitos problemas
    if (issues.length > 3) {
      recommendations.add(
        '🆘 Múltiplos problemas detectados! '
        'Considere revisar localização, tipo de solo e frequência de rega.',
      );
    }

    return recommendations;
  }

  /// Analisa tendência nos últimos N horas
  Map<String, String> analyzeTrends(
    String plantId, {
    int hours = 24,
  }) {
    final history = mockSensorService.getHistory(plantId, hours: hours);

    if (history.isEmpty) {
      return {'status': 'Sem dados de histórico'};
    }

    final tempAvg = mockSensorService.getAverageMetric(plantId, 'temperature', hours: hours);
    final humidityAvg = mockSensorService.getAverageMetric(plantId, 'humidity', hours: hours);
    final lightAvg = mockSensorService.getAverageMetric(plantId, 'light', hours: hours);
    final moistureAvg = mockSensorService.getAverageMetric(plantId, 'soilmoisture', hours: hours);

    return {
      'temperatura_media': '${tempAvg.toStringAsFixed(1)}°C',
      'umidade_media': '${humidityAvg.toStringAsFixed(1)}%',
      'luz_media': '${lightAvg.toStringAsFixed(0)} lux',
      'umidade_solo_media': '${moistureAvg.toStringAsFixed(0)}%',
      'leituras_total': '${history.length}',
    };
  }
}
