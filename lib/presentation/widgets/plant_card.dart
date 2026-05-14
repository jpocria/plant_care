import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

  String _statusLabel(PlantStatus status) {
    switch (status) {
      case PlantStatus.healthy:
        return 'Saudável';
      case PlantStatus.needsWater:
        return 'Precisa de água';
      case PlantStatus.needsAttention:
        return 'Atenção necessária';
      case PlantStatus.critical:
        return 'Situação crítica';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statusColor = _statusColor(plant.calculatedStatus);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((isDark ? 0.3 : 0.06 * 255).round()),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: plant.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: plant.imageUrl!,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                _placeholder(),
                            errorWidget: (_, __, ___) =>
                                _placeholder(),
                          )
                        : _placeholder(),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                plant.name,
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w800,
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
                        const SizedBox(height: 4),
                        Text(plant.type.label,
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontSize: 13)),
                        if (plant.location != null) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 12,
                                  color: theme.colorScheme.onSurface
                                      .withAlpha((0.4 * 255).round())),
                              const SizedBox(width: 2),
                              Text(
                                plant.location!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface
                                      .withAlpha((0.5 * 255).round()),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color:
                                    statusColor.withAlpha((0.12 * 255).round()),
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                              child: Text(
                                _statusLabel(
                                    plant.calculatedStatus),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: statusColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (plant.nextWatering != null)
                              Text(
                                plant.needsWatering
                                    ? '💧 Regar hoje!'
                                    : '💧 ${plant.daysUntilWatering}d',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: plant.needsWatering
                                      ? const Color(0xFF3B82F6)
                                      : theme.colorScheme.onSurface
                                          .withAlpha((0.5 * 255).round()),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (plant.needsWatering)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: GestureDetector(
                        onTap: onWater,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3B82F6)
                                .withAlpha((0.12 * 255).round()),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text('💧',
                                style: TextStyle(fontSize: 18)),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withAlpha((0.08 * 255).round()),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
          child: Text(_plantEmoji,
              style: const TextStyle(fontSize: 32))),
    );
  }
}