import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../data/repositories/alert_repository.dart';
import '../../../data/models/alert_model.dart';
import '../../theme/app_theme.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alertRepo = context.watch<AlertRepository>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Alertas'),
        actions: [
          if (alertRepo.unreadCount > 0)
            TextButton(
              onPressed: alertRepo.markAllAsRead,
              child: const Text('Marcar todos como lidos',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 12)),
            ),
        ],
      ),
      body: alertRepo.alerts.isEmpty
          ? _EmptyAlerts()
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: alertRepo.alerts.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final alert = alertRepo.alerts[index];
                return _AlertCard(
                  alert: alert,
                  onRead: () => alertRepo.markAsRead(alert.id),
                  onResolve: () =>
                      alertRepo.resolveAlert(alert.id),
                  onDelete: () =>
                      alertRepo.deleteAlert(alert.id),
                );
              },
            ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final AlertModel alert;
  final VoidCallback onRead;
  final VoidCallback onResolve;
  final VoidCallback onDelete;

  const _AlertCard({
    required this.alert,
    required this.onRead,
    required this.onResolve,
    required this.onDelete,
  });

  Color _severityColor() {
    switch (alert.severity) {
      case AlertSeverity.low:
        return const Color(0xFF6B7280);
      case AlertSeverity.medium:
        return AppTheme.warningColor;
      case AlertSeverity.high:
        return const Color(0xFFEF6C00);
      case AlertSeverity.critical:
        return AppTheme.errorColor;
    }
  }

  String _severityLabel() {
    switch (alert.severity) {
      case AlertSeverity.low:
        return 'Baixo';
      case AlertSeverity.medium:
        return 'Médio';
      case AlertSeverity.high:
        return 'Alto';
      case AlertSeverity.critical:
        return 'Crítico';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = _severityColor();
    final isUnread = !alert.isRead;

    return Dismissible(
      key: Key(alert.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.errorColor.withAlpha((0.1 * 255).round()),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline,
            color: AppTheme.errorColor),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: isUnread ? onRead : null,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isUnread
                ? (isDark ? AppTheme.cardDark : Colors.white)
                : (isDark
                    ? AppTheme.cardDark.withAlpha((0.5 * 255).round())
                    : Colors.grey[50]),
            borderRadius: BorderRadius.circular(16),
            border: isUnread
                ? Border.all(
                    color: color.withAlpha((0.3 * 255).round()), width: 1.5)
                : null,
            boxShadow: isUnread
                ? [
                    BoxShadow(
                        color: Colors.black.withAlpha((0.05 * 255).round()),
                        blurRadius: 10,
                        offset: const Offset(0, 3))
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (isUnread)
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle),
                    ),
                  Text(alert.type.emoji,
                      style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      alert.plantName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isUnread
                            ? null
                            : theme.colorScheme.onSurface
                                .withAlpha((0.6 * 255).round()),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withAlpha((0.12 * 255).round()),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _severityLabel(),
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: color),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                alert.message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isUnread
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withAlpha((0.5 * 255).round()),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.access_time_outlined,
                      size: 12,
                      color: theme.colorScheme.onSurface
                          .withAlpha((0.4 * 255).round())),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd/MM/yyyy HH:mm')
                        .format(alert.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface
                          .withAlpha((0.4 * 255).round()),
                    ),
                  ),
                  const Spacer(),
                  if (!alert.isResolved)
                    TextButton(
                      onPressed: onResolve,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Resolver',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13)),
                    )
                  else
                    Row(
                      children: [
                        const Icon(Icons.check_circle_outline,
                            size: 14,
                            color: AppTheme.successColor),
                        const SizedBox(width: 4),
                        Text('Resolvido',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.successColor,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyAlerts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 20),
            Text('Nenhum alerta!',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
                'Suas plantas estão todas bem. Continue assim!',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}