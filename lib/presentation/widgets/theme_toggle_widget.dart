import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:plant_care/core/services/theme_service.dart';

/// Widget para alternar entre tema claro/escuro/sistema
class ThemeToggleWidget extends StatelessWidget {
  final bool isCompact;
  final VoidCallback? onThemeChanged;

  const ThemeToggleWidget({
    Key? key,
    this.isCompact = false,
    this.onThemeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        if (isCompact) {
          return _buildCompactToggle(context, themeService);
        }
        return _buildFullToggle(context, themeService);
      },
    );
  }

  /// Versão compacta com apenas botão de alternância
  Widget _buildCompactToggle(BuildContext context, ThemeService themeService) {
    return IconButton(
      icon: Icon(
        themeService.isDarkMode ? Icons.light_mode : Icons.dark_mode,
        size: 24,
      ),
      onPressed: () async {
        await themeService.toggleTheme();
        onThemeChanged?.call();
      },
      tooltip: 'Alternar tema',
    );
  }

  /// Versão completa com seletor de tema
  Widget _buildFullToggle(BuildContext context, ThemeService themeService) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 12),
                Text(
                  'Tema da Aplicação',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _themeOption(
                    context: context,
                    title: 'Claro',
                    icon: Icons.light_mode,
                    isSelected: themeService.isLightMode,
                    onTap: () async {
                      await themeService.setLightMode();
                      onThemeChanged?.call();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _themeOption(
                    context: context,
                    title: 'Escuro',
                    icon: Icons.dark_mode,
                    isSelected: themeService.isDarkMode,
                    onTap: () async {
                      await themeService.setDarkMode();
                      onThemeChanged?.call();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _themeOption(
                    context: context,
                    title: 'Sistema',
                    icon: Icons.settings_suggest,
                    isSelected: themeService.isSystemMode,
                    onTap: () async {
                      await themeService.setSystemMode();
                      onThemeChanged?.call();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Opção individual de tema
  Widget _themeOption({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? primaryColor.withOpacity(isDark ? 0.15 : 0.1)
              : Colors.transparent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? primaryColor : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? primaryColor : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
