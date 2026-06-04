import 'package:flutter/material.dart';
import 'package:plant_care/data/models/plant_model.dart';
import 'package:plant_care/data/models/sensor_reading.dart';
import 'package:plant_care/core/services/plant_health_analyzer.dart';
import 'package:plant_care/core/services/mock_sensor_service.dart';
import 'package:plant_care/presentation/widgets/health_widgets.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

class PlantHealthDetailScreen extends StatefulWidget {
  final PlantModel plant;

  const PlantHealthDetailScreen({
    Key? key,
    required this.plant,
  }) : super(key: key);

  @override
  State<PlantHealthDetailScreen> createState() =>
      _PlantHealthDetailScreenState();
}

class _PlantHealthDetailScreenState extends State<PlantHealthDetailScreen> {
  late PlantHealthAnalyzer analyzer;
  late MockSensorService sensorService;

  late SensorReading? currentReading;
  late var currentAnalysis;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    analyzer = sl<PlantHealthAnalyzer>();
    sensorService = sl<MockSensorService>();
    _loadAnalysis();
  }

  void _loadAnalysis() {
    setState(() {
      isLoading = true;
    });

    try {
      // Gera leitura de sensor
      currentReading = sensorService.generateReading(widget.plant);

      // Analisa saúde
      currentAnalysis = analyzer.analyzeHealth(currentReading!, widget.plant);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao analisar saúde: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saúde de ${widget.plant.name}'),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Status principal
                  HealthStatusCard(
                    plantName: widget.plant.name,
                    analysis: currentAnalysis,
                  ),
                  const SizedBox(height: 16),

                  // Detalhes de sensores
                  _buildSensorDetails(),

                  // Problemas detectados
                  if (currentAnalysis.issues.isNotEmpty)
                    _buildIssuesList(),

                  // Recomendações
                  if (currentAnalysis.recommendations.isNotEmpty)
                    _buildRecommendations(),

                  // Tendências (simuladas)
                  _buildTrends(),

                  const SizedBox(height: 24),

                  // Botão para atualizar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton.icon(
                      onPressed: _loadAnalysis,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Atualizar Análise'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildSensorDetails() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Leitura de Sensores',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSensorRow(
              icon: '🌡️',
              label: 'Temperatura',
              value: currentReading!.temperature,
              unit: '°C',
              color: Colors.orange,
            ),
            const Divider(),
            _buildSensorRow(
              icon: '💧',
              label: 'Umidade do Ar',
              value: currentReading!.humidity,
              unit: '%',
              color: Colors.blue,
            ),
            const Divider(),
            _buildSensorRow(
              icon: '☀️',
              label: 'Luminosidade',
              value: currentReading!.light.toDouble(),
              unit: 'lux',
              color: Colors.amber,
            ),
            const Divider(),
            _buildSensorRow(
              icon: '🌱',
              label: 'Umidade do Solo',
              value: currentReading!.soilMoisture.toDouble(),
              unit: '%',
              color: Colors.brown,
            ),
            const SizedBox(height: 8),
            Text(
              'Fonte: ${currentReading!.source} | ${currentReading!.timestamp.hour.toString().padLeft(2, '0')}:${currentReading!.timestamp.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorRow({
    required String icon,
    required String label,
    required double value,
    required String unit,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 4),
              ],
            ),
          ],
        ),
        Text(
          '${value.toStringAsFixed(1)} $unit',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildIssuesList() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text(
                  '⚠️ Problemas Detectados',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...currentAnalysis.issues.map<Widget>((issue) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('•', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(issue),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text(
                  '✅ Recomendações',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...currentAnalysis.recommendations.map<Widget>((rec) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('✓', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(rec),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrends() {
    // Simula tendências de 7 dias
    final tempTrend = List.generate(7, (i) {
      return 20.0 + (5.0 * (i % 2 == 0 ? 1 : -1)) + (i * 0.2);
    });

    final humidityTrend = List.generate(7, (i) {
      return 60.0 + (15.0 * (i % 2 == 0 ? 1 : -1));
    });

    return Column(
      children: [
        TrendChart(
          title: 'Tendência de Temperatura (7 dias)',
          values: tempTrend,
          unit: '°C',
          color: Colors.orange,
        ),
        TrendChart(
          title: 'Tendência de Umidade (7 dias)',
          values: humidityTrend,
          unit: '%',
          color: Colors.blue,
        ),
      ],
    );
  }
}
