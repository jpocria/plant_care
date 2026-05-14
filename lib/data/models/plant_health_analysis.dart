/// Resultado da análise de saúde de uma planta
class PlantHealthAnalysis {
  /// Score de saúde de 0-100
  final int healthScore;
  
  /// Status: 'excellent', 'good', 'fair', 'poor', 'critical'
  final String status;
  
  /// Recomendações específicas
  final List<String> recommendations;
  
  /// Problemas detectados
  final List<String> issues;
  
  /// Componentes do score
  final double temperatureScore;
  final double humidityScore;
  final double lightScore;
  final double soilMoistureScore;
  
  /// Quando foi a análise
  final DateTime analyzedAt;
  
  /// Deveria regar?
  final bool needsWatering;
  
  /// Dias até próxima rega ideal
  final double daysUntilNextWatering;

  PlantHealthAnalysis({
    required this.healthScore,
    required this.status,
    required this.recommendations,
    required this.issues,
    required this.temperatureScore,
    required this.humidityScore,
    required this.lightScore,
    required this.soilMoistureScore,
    required this.analyzedAt,
    required this.needsWatering,
    required this.daysUntilNextWatering,
  });

  /// Determina status baseado no score
  static String _scoreToStatus(int score) {
    if (score >= 85) return 'excellent';
    if (score >= 70) return 'good';
    if (score >= 55) return 'fair';
    if (score >= 40) return 'poor';
    return 'critical';
  }

  /// Factory para criar análise vazia/padrão
  factory PlantHealthAnalysis.empty() {
    return PlantHealthAnalysis(
      healthScore: 0,
      status: 'unknown',
      recommendations: [],
      issues: [],
      temperatureScore: 0,
      humidityScore: 0,
      lightScore: 0,
      soilMoistureScore: 0,
      analyzedAt: DateTime.now(),
      needsWatering: false,
      daysUntilNextWatering: 0,
    );
  }

  /// Emoji para o status
  String get statusEmoji {
    switch (status) {
      case 'excellent':
        return '🌿';
      case 'good':
        return '✅';
      case 'fair':
        return '⚠️';
      case 'poor':
        return '❌';
      case 'critical':
        return '🚨';
      default:
        return '❓';
    }
  }

  /// Descrição do status
  String get statusDescription {
    switch (status) {
      case 'excellent':
        return 'Excelente! Sua planta está muito saudável.';
      case 'good':
        return 'Ótimo! Sua planta está bem de saúde.';
      case 'fair':
        return 'Razoável. Sua planta precisa de atenção.';
      case 'poor':
        return 'Ruim. Sua planta está em risco.';
      case 'critical':
        return 'Crítico! Ação imediata necessária.';
      default:
        return 'Status desconhecido.';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'healthScore': healthScore,
      'status': status,
      'recommendations': recommendations,
      'issues': issues,
      'temperatureScore': temperatureScore,
      'humidityScore': humidityScore,
      'lightScore': lightScore,
      'soilMoistureScore': soilMoistureScore,
      'analyzedAt': analyzedAt.toIso8601String(),
      'needsWatering': needsWatering,
      'daysUntilNextWatering': daysUntilNextWatering,
    };
  }

  @override
  String toString() {
    return 'PlantHealthAnalysis('
        'score: $healthScore, '
        'status: $status, '
        'issues: ${issues.length}'
        ')';
  }
}
