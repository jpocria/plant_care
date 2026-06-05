import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/plant_model.dart';
import '../theme/app_theme.dart';

class PlantCard extends StatelessWidget {
  final PlantModel plant;
  final VoidCallback onTap;
  final VoidCallback onWater;

  const PlantCard({
    super.key,
    required this.plant,
    required this.onTap,
    required this.onWater,
  });

  Color _statusColor(PlantStatus status) {
    switch (status) {
      case PlantStatus.healthy:
        return AppTheme.successColor;
      case PlantStatus.needsWater:
        return const Color(0xFF3B82F6);
      case PlantStatus.needsAttention:
        return AppTheme.warningColor;
      case PlantStatus.critical:
        return AppTheme.errorColor;
    }
  }

  String _statusEmoji(PlantStatus status) {
    switch (status) {
      case PlantStatus.healthy:
        return '✅';
      case PlantStatus.needsWater:
        return '💧';
      case PlantStatus.needsAttention:
        return '⚠️';
      case PlantStatus.critical:
        return '🚨';
    }
  }

  String get _plantEmoji {
    switch (plant.type) {
      case PlantType.vegetable:
        return '🥬';
      case PlantType.fruit:
        return '🍓';
      case PlantType.herb:
        return '🌿';
      case PlantType.flower:
        return '🌸';
      case PlantType.succulent:
        return '🌵';
      case PlantType.tree:
        return '🌳';
      case PlantType.other:
        return '🪴';
    }
  }

  String _wateringInfo() {
    if (plant.nextWatering == null) return 'Sem agenda';
    if (plant.needsWatering) return 'Regar hoje!';
    if (plant.daysUntilWatering == 0) return 'Regar hoje!';
    return 'Em ${plant.daysUntilWatering}d';
  }

  Color _wateringColor() {
    if (plant.needsWatering) return const Color(0xFF3B82F6);
    final d = plant.daysUntilWatering;
    if (d <= 1) return AppTheme.warningColor;
    return AppTheme.successColor;
  }

  String _plantAge() {
    final days = DateTime.now().difference(plant.createdAt).inDays;
    if (days < 1) return 'plantada hoje';
    if (days == 1) return 'há 1 dia';
    if (days < 30) return 'há $days dias';
    final months = (days / 30).floor();
    if (months == 1) return 'há 1 mês';
    return 'há $months meses';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(plant.calculatedStatus);
    final wateringColor = _wateringColor();
    final currentHumidity = plant.currentHumidity;
    final humidityProgress = currentHumidity != null
        ? (currentHumidity / plant.targetHumidity).clamp(0.0, 1.0)
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderDark, width: 1),
        ),
        child: Row(
          children: [
            // Borda colorida lateral (status)
            Container(
              width: 4,
              height: 100,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Linha 1: ícone + nome + status
                    Row(
                      children: [
                        Text(_plantEmoji,
                            style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            plant.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          _statusEmoji(plant.calculatedStatus),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    // Linha 2: tipo + idade
                    Padding(
                      padding: const EdgeInsets.only(left: 30, top: 2),
                      child: Text(
                        '${plant.type.label} · ${_plantAge()}',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Linha 3: próxima rega + umidade + temp. + botão regar
                    Padding(
                      padding: const EdgeInsets.only(left: 30, top: 8),
                      child: Row(
                        children: [
                          // Rega
                          _MiniInfo(
                            icon: '💧',
                            label: plant.needsWatering
                                ? 'Regar hoje!'
                                : 'Em ${plant.daysUntilWatering}d',
                            color: wateringColor,
                          ),
                          const SizedBox(width: 12),
                          // Umidade (se houver)
                          if (currentHumidity != null) ...[
                            _MiniInfo(
                              icon: '💦',
                              label:
                                  '${currentHumidity.round()}/${plant.targetHumidity.round()}%',
                              color: currentHumidity! < plant.targetHumidity * 0.7
                                  ? AppTheme.warningColor
                                  : AppTheme.neonGreen,
                            ),
                            const SizedBox(width: 12),
                          ],
                          // Temperatura (se houver)
                          if (plant.currentTemperature != null) ...[
                            _MiniInfo(
                              icon: '🌡️',
                              label:
                                  '${plant.currentTemperature!.round()}°/${plant.targetTemperature.round()}°',
                              color: AppTheme.amberNeon,
                            ),
                            const SizedBox(width: 12),
                          ],
                          const Spacer(),
                          // Botão regar (se precisar)
                          if (plant.needsWatering)
                            GestureDetector(
                              onTap: onWater,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3B82F6)
                                      .withAlpha((0.18 * 255).round()),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Text('💧',
                                      style: TextStyle(fontSize: 14)),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final String icon, label;
  final Color color;
  const _MiniInfo(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w800, color: color),
        ),
      ],
    );
  }
}
