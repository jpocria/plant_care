import 'package:flutter/material.dart';
import 'package:plant_care/data/models/plant_health_analysis.dart';

/// Widget que exibe o status de saúde da planta em card compacto
class HealthStatusCard extends StatelessWidget {
  final String plantName;
  final PlantHealthAnalysis analysis;
  final VoidCallback? onTap;

  const HealthStatusCard({
    Key? key,
    required this.plantName,
    required this.analysis,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(analysis.status);
    final statusEmoji = _getStatusEmoji(analysis.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho com nome e status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plantName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          analysis.statusDescription,
                          style: TextStyle(
                            fontSize: 14,
                            color: statusColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    statusEmoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Score visual
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: analysis.healthScore / 100,
                  minHeight: 8,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Saúde: ${analysis.healthScore}%',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              // Mini scores dos sensores
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MiniScoreIndicator(
                    icon: '🌡️',
                    label: 'Temp',
                    score: analysis.temperatureScore.toInt(),
                  ),
                  _MiniScoreIndicator(
                    icon: '💧',
                    label: 'Umidade',
                    score: analysis.humidityScore.toInt(),
                  ),
                  _MiniScoreIndicator(
                    icon: '☀️',
                    label: 'Luz',
                    score: analysis.lightScore.toInt(),
                  ),
                  _MiniScoreIndicator(
                    icon: '🌱',
                    label: 'Solo',
                    score: analysis.soilMoistureScore.toInt(),
                  ),
                ],
              ),
              // Ícone de rega se necessário
              if (analysis.needsWatering) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Text('💧', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Hora de regar!',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'excellent':
        return Colors.green;
      case 'good':
        return Colors.lightGreen;
      case 'fair':
        return Colors.orange;
      case 'poor':
        return Colors.deepOrange;
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusEmoji(String status) {
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
}

/// Mini indicador de score para cada sensor
class _MiniScoreIndicator extends StatelessWidget {
  final String icon;
  final String label;
  final int score;

  const _MiniScoreIndicator({
    required this.icon,
    required this.label,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    final scoreColor = score > 70
        ? Colors.green
        : score > 50
            ? Colors.orange
            : Colors.red;

    return Column(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 4),
        Container(
          width: 40,
          height: 3,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            widthFactor: score / 100,
            child: Container(
              decoration: BoxDecoration(
                color: scoreColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$score%',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: scoreColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 9),
        ),
      ],
    );
  }
}

/// Chart simples mostrando tendência de 7 dias
class TrendChart extends StatelessWidget {
  final String title;
  final List<double> values;
  final String unit;
  final Color color;

  const TrendChart({
    Key? key,
    required this.title,
    required this.values,
    required this.unit,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (values.isEmpty) {
      return Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              'Sem dados para $title',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ),
      );
    }

    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;
    final normalizedRange = range == 0 ? 1.0 : range;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: CustomPaint(
                painter: _TrendPainter(
                  values: values,
                  color: color,
                  minValue: minValue,
                  normalizedRange: normalizedRange,
                ),
                size: const Size(double.infinity, 100),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Min: ${minValue.toStringAsFixed(1)}$unit',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  'Máx: ${maxValue.toStringAsFixed(1)}$unit',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  final List<double> values;
  final Color color;
  final double minValue;
  final double normalizedRange;

  _TrendPainter({
    required this.values,
    required this.color,
    required this.minValue,
    required this.normalizedRange,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final pointSpacing = size.width / (values.length - 1);

    for (int i = 0; i < values.length - 1; i++) {
      final x1 = i * pointSpacing;
      final y1 = size.height -
          ((values[i] - minValue) / normalizedRange) * size.height;

      final x2 = (i + 1) * pointSpacing;
      final y2 = size.height -
          ((values[i + 1] - minValue) / normalizedRange) * size.height;

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }

    // Draw points
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (int i = 0; i < values.length; i++) {
      final x = i * pointSpacing;
      final y = size.height -
          ((values[i] - minValue) / normalizedRange) * size.height;
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(_TrendPainter oldDelegate) => true;
}
