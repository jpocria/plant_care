import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../data/repositories/plant_repository.dart';
import '../../../data/models/plant_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/health_widgets.dart';
import '../../../core/services/plant_health_analyzer.dart';
import '../../../core/services/mock_sensor_service.dart';
import 'package:get_it/get_it.dart';

class PlantDetailScreen extends StatefulWidget {
  final String plantId;
  const PlantDetailScreen({super.key, required this.plantId});

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final plantRepo = context.watch<PlantRepository>();
    final plant = plantRepo.findPlantById(widget.plantId);
    final theme = Theme.of(context);

    if (plant == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Planta não encontrada')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            leading: IconButton(
              icon: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha((0.3 * 255).round()),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 18),
              ),
              onPressed: () => context.go('/home'),
            ),
            actions: [
              IconButton(
                icon: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha((0.3 * 255).round()),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(Icons.edit_outlined,
                      color: Colors.white, size: 18),
                ),
                onPressed: () => context.go('/plant/${widget.plantId}/edit'),
              ),
              IconButton(
                icon: Container(
                  decoration: BoxDecoration(
                    color: Colors.red.withAlpha((0.7 * 255).round()),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const Icon(Icons.delete_outline,
                      color: Colors.white, size: 18),
                ),
                onPressed: () =>
                    _confirmDelete(context, plantRepo, plant),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: plant.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: plant.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          _heroPlaceholder(plant.type),
                      errorWidget: (_, __, ___) =>
                          _heroPlaceholder(plant.type),
                    )
                  : _heroPlaceholder(plant.type),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plant.name,
                              style: theme.textTheme.headlineMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Chip(label: Text(plant.type.label)),
                                if (plant.location != null) ...[
                                  const SizedBox(width: 8),
                                  Row(
                                    children: [
                                      Icon(
                                          Icons.location_on_outlined,
                                          size: 14,
                                          color: theme
                                              .colorScheme.onSurface
                                              .withAlpha((0.4 * 255).round())),
                                      Text(
                                        plant.location!,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: theme
                                              .colorScheme.onSurface
                                              .withAlpha((0.5 * 255).round()),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      _StatusBadge(status: plant.calculatedStatus),
                    ],
                  ),
                  if (plant.description != null) ...[
                    const SizedBox(height: 12),
                    Text(plant.description!,
                        style: theme.textTheme.bodyLarge),
                  ],
                  const SizedBox(height: 24),
                  CustomButton(
                    label: plant.needsWatering
                        ? '💧 Regar agora!'
                        : '💧 Registrar rega',
                    onPressed: () async {
                      final bool success =
                          await plantRepo.waterPlant(plant.id);
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                const Text('Rega registrada! 💧'),
                            backgroundColor:
                                const Color(0xFF3B82F6),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12)),
                          ),
                        );
                      }
                    },
                    isFullWidth: true,
                    backgroundColor: plant.needsWatering
                        ? const Color(0xFF3B82F6)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => _showHealthAnalysis(context, plant),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: Colors.green[600],
                    ),
                    child: const Text('🌿 Ver Análise de Saúde'),
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle(title: 'Status atual'),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.6,
                    children: [
                      _InfoCard(
                        icon: '💧',
                        title: 'Última rega',
                        value: plant.lastWatered != null
                            ? DateFormat('dd/MM/yyyy')
                                .format(plant.lastWatered!)
                            : 'Nunca',
                        color: const Color(0xFF3B82F6),
                      ),
                      _InfoCard(
                        icon: '📅',
                        title: 'Próxima rega',
                        value: plant.nextWatering != null
                            ? plant.needsWatering
                                ? 'Hoje!'
                                : 'Em ${plant.daysUntilWatering}d'
                            : 'Não configurado',
                        color: plant.needsWatering
                            ? AppTheme.errorColor
                            : AppTheme.successColor,
                      ),
                      _InfoCard(
                        icon: '🌡️',
                        title: 'Umidade alvo',
                        value: '${plant.targetHumidity.round()}%',
                        color: AppTheme.primaryGreen,
                      ),
                      _InfoCard(
                        icon: '🌡️',
                        title: 'Temperatura alvo',
                        value:
                            '${plant.targetTemperature.round()}°C',
                        color: AppTheme.accentEarth,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle(title: 'Configurações'),
                  const SizedBox(height: 12),
                  _ConfigCard(
                    items: [
                      _ConfigItem(
                          icon: Icons.water_drop_outlined,
                          label: 'Frequência de rega',
                          value:
                              'A cada ${plant.wateringFrequencyDays} dia(s)'),
                      _ConfigItem(
                          icon: Icons.opacity_outlined,
                          label: 'Umidade ideal',
                          value:
                              '${plant.targetHumidity.round()}%'),
                      _ConfigItem(
                          icon: Icons.thermostat_outlined,
                          label: 'Temperatura ideal',
                          value:
                              '${plant.targetTemperature.round()}°C'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Adicionada em ${DateFormat('dd/MM/yyyy').format(plant.createdAt)}',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroPlaceholder(PlantType type) {
    String emoji;
    switch (type) {
      case PlantType.vegetable:
        emoji = '🥬';
        break;
      case PlantType.fruit:
        emoji = '🍓';
        break;
      case PlantType.herb:
        emoji = '🌿';
        break;
      case PlantType.flower:
        emoji = '🌸';
        break;
      case PlantType.succulent:
        emoji = '🌵';
        break;
      case PlantType.tree:
        emoji = '🌳';
        break;
      default:
        emoji = '🪴';
    }
    return Container(
      color: AppTheme.primaryGreen.withAlpha((0.1 * 255).round()),
      child: Center(
          child: Text(emoji, style: const TextStyle(fontSize: 80))),
    );
  }

  void _showHealthAnalysis(BuildContext context, PlantModel plant) {
    final sl = GetIt.instance;
    final analyzer = sl<PlantHealthAnalyzer>();
    final sensorService = sl<MockSensorService>();

    final reading = sensorService.generateReading(plant);
    final analysis = analyzer.analyzeHealth(reading, plant);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (_, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Análise de Saúde',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                HealthStatusCard(
                  plantName: plant.name,
                  analysis: analysis,
                ),
                const SizedBox(height: 16),
                // Leitura de sensores
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Leitura de Sensores',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildSensorRow('🌡️', 'Temperatura', '${reading.temperature.toStringAsFixed(1)}°C'),
                        const Divider(),
                        _buildSensorRow('💧', 'Umidade', '${reading.humidity.toStringAsFixed(1)}%'),
                        const Divider(),
                        _buildSensorRow('☀️', 'Luminosidade', '${reading.light} lux'),
                        const Divider(),
                        _buildSensorRow('🌱', 'Umidade Solo', '${reading.soilMoisture.toStringAsFixed(1)}%'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (analysis.issues.isNotEmpty)
                  Card(
                    color: Colors.red[50],
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '⚠️ Problemas Detectados',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                          ),
                          const SizedBox(height: 8),
                          ...analysis.issues.map((issue) => Text('• $issue')).toList(),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSensorRow(String emoji, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 13)),
          ],
        ),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  void _confirmDelete(BuildContext context, PlantRepository repo,
      PlantModel plant) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Remover planta?',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text(
            'Tem certeza que deseja remover "${plant.name}"? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final bool success = await repo.deletePlant(plant.id);
              if (success && context.mounted) {
                context.go('/home');
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final PlantStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case PlantStatus.healthy:
        color = AppTheme.successColor;
        label = '✅ Saudável';
        break;
      case PlantStatus.needsWater:
        color = const Color(0xFF3B82F6);
        label = '💧 Sede';
        break;
      case PlantStatus.needsAttention:
        color = AppTheme.warningColor;
        label = '⚠️ Atenção';
        break;
      case PlantStatus.critical:
        color = AppTheme.errorColor;
        label = '🚨 Crítico';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha((0.12 * 255).round()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: TextStyle(
              fontWeight: FontWeight.w700, color: color, fontSize: 13)),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800, letterSpacing: -0.2),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String icon, title, value;
  final Color color;
  const _InfoCard(
      {required this.icon,
      required this.title,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: color)),
              Text(title,
                  style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface
                          .withAlpha((0.5 * 255).round()))),
            ],
          ),
        ],
      ),
    );
  }
}

class _ConfigCard extends StatelessWidget {
  final List<_ConfigItem> items;
  const _ConfigCard({required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final item = entry.value;
          final isLast = entry.key == items.length - 1;
          return Column(
            children: [
              ListTile(
                leading: Icon(item.icon,
                    color: AppTheme.primaryGreen, size: 20),
                title: Text(item.label,
                    style: const TextStyle(fontSize: 14)),
                trailing: Text(item.value,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryGreen)),
                dense: true,
              ),
              if (!isLast)
                Divider(
                    height: 1,
                    indent: 52,
                    color: theme.colorScheme.onSurface.withAlpha((0.07 * 255).round())),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _ConfigItem {
  final IconData icon;
  final String label, value;
  _ConfigItem(
      {required this.icon, required this.label, required this.value});
}