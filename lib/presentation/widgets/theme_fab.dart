import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/theme_service.dart';
import '../theme/app_theme.dart';

/// Botao flutuante compacto (sol/lua) que alterna o tema da aplicacao.
///
/// Foi projetado para ficar no "canto" da tela (canto superior direito, por
/// exemplo) e oferecer uma forma rapida de alternar entre tema claro e escuro
/// sem precisar abrir configuracoes.
///
/// Quando o modo "sistema" estiver ativo, o icone reflete o tema efetivo
/// atual; ao tocar, ele alterna explicitamente para o oposto.
class ThemeFab extends StatelessWidget {
  /// Tamanho do botao. Padrao compacto.
  final double size;

  /// Cor de fundo do botao. Se nula, usa surfaceContainerHighest do tema.
  final Color? background;

  /// Cor do icone. Se nula, usa onSurfaceVariant do tema.
  final Color? iconColor;

  /// Borda do botao. Padrao sutil, baseada em outlineVariant.
  final Color? borderColor;

  const ThemeFab({
    super.key,
    this.size = 40,
    this.background,
    this.iconColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        // Determina o icone a ser exibido
        // - Se o modo e "sistema", refletimos o tema efetivo
        // - Caso contrario, mostramos o tema atual
        final currentlyDark = themeService.isSystemMode
            ? isDark
            : themeService.isDarkMode;

        final IconData icon = currentlyDark
            ? Icons.wb_sunny_rounded // mostra sol (vamos mudar para claro)
            : Icons.nightlight_round; // mostra lua (vamos mudar para escuro)

        final Color bg = background ??
            theme.colorScheme.surfaceContainerHighest.withAlpha(220);
        final Color ic = iconColor ??
            (currentlyDark
                ? AppTheme.amberNeon
                : theme.colorScheme.primary);
        final Color border = borderColor ?? theme.colorScheme.outline;

        return Tooltip(
          message: currentlyDark
              ? 'Mudar para tema claro'
              : 'Mudar para tema escuro',
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(size),
              onTap: () => themeService.toggleTheme(),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: bg,
                  shape: BoxShape.circle,
                  border: Border.all(color: border, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(isDark ? 60 : 12),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, anim) => RotationTransition(
                    turns: Tween<double>(begin: 0.85, end: 1.0).animate(anim),
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: Icon(
                    icon,
                    key: ValueKey<bool>(currentlyDark),
                    size: size * 0.55,
                    color: ic,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
