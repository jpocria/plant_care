import 'package:plant_care/core/services/plant_health_analyzer.dart';
import 'package:plant_care/core/services/plant_knowledge_base.dart';
import 'package:plant_care/core/services/mock_sensor_service.dart';
import 'package:plant_care/data/models/plant_health_analysis.dart';
import 'package:plant_care/data/models/sensor_reading.dart';
import 'package:plant_care/data/models/plant_model.dart';

/// Tipo de alerta gerado
enum AlertType {
  /// Saúde crítica - ação imediata necessária
  critical,

  /// Saúde ruim - ação necessária
  warning,

  /// Saúde justa - monitorar
  info,

  /// Recomendação de rega
  wateringNeeded,

  /// Recomendação geral
  maintenance,
}

/// Modelo de alerta gerado
class PlantAlert {
  final String id;
  final String plantId;
  final String plantName;
  final AlertType type;
  final String title;
  final String message;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final int healthScore; // Score quando alerta foi gerado

  const PlantAlert({
    required this.id,
    required this.plantId,
    required this.plantName,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.resolvedAt,
    required this.healthScore,
  });

  /// Converte para Map para salvar em Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plantId': plantId,
      'plantName': plantName,
      'type': type.toString().split('.').last,
      'title': title,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'healthScore': healthScore,
      'resolved': resolvedAt != null,
    };
  }

  /// Cria alertas a partir de um Map (Firestore)
  factory PlantAlert.fromMap(Map<String, dynamic> map) {
    return PlantAlert(
      id: map['id'] as String,
      plantId: map['plantId'] as String,
      plantName: map['plantName'] as String,
      type: AlertType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'],
        orElse: () => AlertType.info,
      ),
      title: map['title'] as String,
      message: map['message'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      resolvedAt: map['resolvedAt'] != null
          ? DateTime.parse(map['resolvedAt'] as String)
          : null,
      healthScore: map['healthScore'] as int? ?? 0,
    );
  }

  /// Verifica se alerta ainda é ativo
  bool get isActive => resolvedAt == null;

  /// Tempo desde que alerta foi gerado
  Duration get age => DateTime.now().difference(createdAt);
}

/// Gera alertas baseado na análise de saúde das plantas
class AlertGeneratorService {
  final PlantHealthAnalyzer analyzer;
  final PlantKnowledgeBase knowledgeBase;
  final MockSensorService sensorService;

  /// Mapa de alertas ativos por plantId
  final Map<String, List<PlantAlert>> _activeAlerts = {};

  /// Histórico de todos os alertas
  final List<PlantAlert> _alertHistory = [];

  AlertGeneratorService({
    required this.analyzer,
    required this.knowledgeBase,
    required this.sensorService,
  });

  /// Gera alertas para uma planta baseado em leitura de sensor
  Future<List<PlantAlert>> generateAlertsForPlant(
    PlantModel plant,
    SensorReading reading,
  ) async {
    final analysis = analyzer.analyzeHealth(reading, plant);
    final alerts = <PlantAlert>[];

    // Limpa alertas resolvidos (score melhorou)
    _clearResolvedAlerts(plant.id, analysis.healthScore);

    if (analysis.healthScore < 40) {
      // Alerta crítico
      alerts.add(_createCriticalAlert(plant, analysis));
    } else if (analysis.healthScore < 55) {
      // Alerta de aviso
      alerts.add(_createWarningAlert(plant, analysis));
    } else if (analysis.healthScore < 70) {
      // Alerta informativo
      alerts.add(_createInfoAlert(plant, analysis));
    }

    // Alerta de rega se necessário
    if (analysis.needsWatering) {
      alerts.add(_createWateringAlert(plant, analysis));
    }

    // Armazena novos alertas
    _activeAlerts.putIfAbsent(plant.id, () => []);
    for (final alert in alerts) {
      // Evita duplicatas: verifica se alerta similar já existe
      final exists = _activeAlerts[plant.id]!.any(
        (a) => a.title == alert.title && a.type == alert.type,
      );

      if (!exists) {
        _activeAlerts[plant.id]!.add(alert);
        _alertHistory.add(alert);
      }
    }

    return alerts;
  }

  /// Gera alertas para múltiplas plantas
  Future<List<PlantAlert>> generateAlertsForPlants(
    List<PlantModel> plants,
  ) async {
    final allAlerts = <PlantAlert>[];

    for (final plant in plants) {
      final reading = sensorService.generateReading(plant);
      final alerts = await generateAlertsForPlant(plant, reading);
      allAlerts.addAll(alerts);
    }

    return allAlerts;
  }

  /// Retorna todos os alertas ativos
  List<PlantAlert> getActiveAlerts() {
    final allActive = <PlantAlert>[];
    _activeAlerts.forEach((_, alerts) {
      allActive.addAll(alerts.where((a) => a.isActive));
    });
    return allActive;
  }

  /// Retorna alertas de uma planta específica
  List<PlantAlert> getAlertsForPlant(String plantId) {
    return _activeAlerts[plantId]?.where((a) => a.isActive).toList() ?? [];
  }

  /// Marca um alerta como resolvido
  void resolveAlert(String alertId) {
    for (final alerts in _activeAlerts.values) {
      final index = alerts.indexWhere((a) => a.id == alertId);
      if (index != -1) {
        final resolved = PlantAlert(
          id: alerts[index].id,
          plantId: alerts[index].plantId,
          plantName: alerts[index].plantName,
          type: alerts[index].type,
          title: alerts[index].title,
          message: alerts[index].message,
          createdAt: alerts[index].createdAt,
          resolvedAt: DateTime.now(),
          healthScore: alerts[index].healthScore,
        );
        alerts[index] = resolved;
        break;
      }
    }
  }

  /// Retorna histórico de alertas
  List<PlantAlert> getAlertHistory({int limit = 100}) {
    return _alertHistory.reversed.take(limit).toList();
  }

  /// Limpa alertas resolvidos se score melhorou significativamente
  void _clearResolvedAlerts(String plantId, int currentScore) {
    final alerts = _activeAlerts[plantId];
    if (alerts == null) return;

    // Se score melhorou mais de 15 pontos, resolve alertas de warning/critical
    for (final alert in alerts) {
      if (alert.isActive && currentScore > alert.healthScore + 15) {
        if (alert.type == AlertType.critical || alert.type == AlertType.warning) {
          resolveAlert(alert.id);
        }
      }
    }
  }

  /// Cria alerta crítico
  PlantAlert _createCriticalAlert(
    PlantModel plant,
    PlantHealthAnalysis analysis,
  ) {
    return PlantAlert(
      id: 'alert_${plant.id}_${DateTime.now().millisecondsSinceEpoch}',
      plantId: plant.id,
      plantName: plant.name,
      type: AlertType.critical,
      title: '🚨 Alerta Crítico - Ação Imediata',
      message:
          'Sua ${plant.name} está com saúde crítica (${analysis.healthScore}%). '
          '${analysis.recommendations.isNotEmpty ? analysis.recommendations.first : "Verifique condições urgentemente."}',
      createdAt: DateTime.now(),
      healthScore: analysis.healthScore,
    );
  }

  /// Cria alerta de aviso
  PlantAlert _createWarningAlert(
    PlantModel plant,
    PlantHealthAnalysis analysis,
  ) {
    return PlantAlert(
      id: 'alert_${plant.id}_${DateTime.now().millisecondsSinceEpoch}',
      plantId: plant.id,
      plantName: plant.name,
      type: AlertType.warning,
      title: '⚠️ Alerta - Atenção Necessária',
      message:
          'Sua ${plant.name} precisa de atenção (saúde: ${analysis.healthScore}%). '
          '${analysis.recommendations.isNotEmpty ? analysis.recommendations.first : "Monitore as condições."}',
      createdAt: DateTime.now(),
      healthScore: analysis.healthScore,
    );
  }

  /// Cria alerta informativo
  PlantAlert _createInfoAlert(
    PlantModel plant,
    PlantHealthAnalysis analysis,
  ) {
    return PlantAlert(
      id: 'alert_${plant.id}_${DateTime.now().millisecondsSinceEpoch}',
      plantId: plant.id,
      plantName: plant.name,
      type: AlertType.info,
      title: 'ℹ️ Informação - Monitorar',
      message:
          'Sua ${plant.name} está numa situação justa (${analysis.healthScore}%). '
          'Continue monitorando.',
      createdAt: DateTime.now(),
      healthScore: analysis.healthScore,
    );
  }

  /// Cria alerta de rega
  PlantAlert _createWateringAlert(
    PlantModel plant,
    PlantHealthAnalysis analysis,
  ) {
    final daysStr = analysis.daysUntilNextWatering > 0
        ? 'em ${analysis.daysUntilNextWatering.toStringAsFixed(0)} dias'
        : 'AGORA';

    return PlantAlert(
      id: 'alert_watering_${plant.id}_${DateTime.now().millisecondsSinceEpoch}',
      plantId: plant.id,
      plantName: plant.name,
      type: AlertType.wateringNeeded,
      title: '💧 Hora de Regar',
      message: 'Sua ${plant.name} precisa ser regada $daysStr.',
      createdAt: DateTime.now(),
      healthScore: analysis.healthScore,
    );
  }

  /// Retorna estatísticas de alertas
  Map<String, dynamic> getAlertStats() {
    final active = getActiveAlerts();
    final critical = active.where((a) => a.type == AlertType.critical).length;
    final warnings = active.where((a) => a.type == AlertType.warning).length;
    final info = active.where((a) => a.type == AlertType.info).length;

    return {
      'totalActive': active.length,
      'critical': critical,
      'warnings': warnings,
      'info': info,
      'totalHistory': _alertHistory.length,
    };
  }
}
