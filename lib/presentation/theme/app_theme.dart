import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 🌿 Tema "Dark Botânico" + Tema "Light Botânico"
/// Inspirado em estufas noturnas, hortas urbanas sob luz neon e ficção científica
/// botânica. Paleta profunda com acentos em verde neon e âmbar quente para o
/// tema escuro, e uma versão clara luminosa com tons de verde folha.
class AppTheme {
  // === CORES PRIMÁRIAS (assinatura da marca) ===
  static const Color neonGreen = Color(0xFF00C46A); // verde assinatura (ajustado p/ contraste claro)
  static const Color neonGreenDim = Color(0xFF00A85A); // variação mais calma
  static const Color leafGreen = Color(0xFF2EBE73); // verde folha
  static const Color amberNeon = Color(0xFFFFB347); // âmbar quente
  static const Color magenta = Color(0xFFE63F8C); // magenta vibrante
  static const Color cyanNeon = Color(0xFF00E5FF); // ciano elétrico

  // === FUNDOS - TEMA ESCURO ===
  static const Color backgroundDark = Color(0xFF0A0F0D); // quase preto esverdeado
  static const Color surfaceDark = Color(0xFF131A16); // cards
  static const Color surfaceElevatedDark = Color(0xFF1B2520); // cards elevados
  static const Color borderDark = Color(0xFF2A3A30); // bordas sutis

  // === FUNDOS - TEMA CLARO (de verdade!) ===
  static const Color backgroundLight = Color(0xFFF6F8F4); // off-white esverdeado
  static const Color surfaceLight = Color(0xFFFFFFFF); // cards brancos
  static const Color surfaceElevatedLight = Color(0xFFEEF5EC); // cards elevados
  static const Color borderLight = Color(0xFFD9E5DA); // bordas sutis

  // Compatibilidade legada
  static const Color cardDark = surfaceElevatedDark;

  // === TEXTO ===
  static const Color textPrimary = Color(0xFFE8FFF0); // branco-esverdeado (dark)
  static const Color textSecondary = Color(0xFF8FB5A0); // verde-acinzentado (dark)
  static const Color textMuted = Color(0xFF5A7A6A);

  // Texto do tema CLARO
  static const Color textPrimaryLight = Color(0xFF14271B); // verde-escuro para leitura
  static const Color textSecondaryLight = Color(0xFF5A6F60); // verde-acinzentado claro
  static const Color textMutedLight = Color(0xFF8FA595);

  // === ESTADOS ===
  static const Color errorColor = Color(0xFFFF4D6D); // vermelho-rosa neon
  static const Color warningColor = Color(0xFFFFC857); // âmbar alerta
  static const Color successColor = Color(0xFF00C46A); // mesmo do neon
  static const Color infoColor = Color(0xFF00B8E5);

  // Mantidos para compatibilidade (alguns widgets podem referenciar)
  static const Color primaryGreen = neonGreen;
  static const Color primaryGreenLight = neonGreenDim;
  static const Color accentEarth = amberNeon;
  static const Color accentEarthLight = amberNeon;
  static const Color textSecondaryDark = textSecondary;
  static const Color backgroundLightLegacy = backgroundLight;

  // === GRADIENTES ===
  static const LinearGradient neonGradient = LinearGradient(
    colors: [Color(0xFF00C46A), Color(0xFF00E5FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1B2520), Color(0xFF131A16)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradientLight = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFEEF5EC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0A0F0D), Color(0xFF1B3A28)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // === TEMA ESCURO (principal) ===
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  // === TEMA CLARO (legível, com verde folha) ===
  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    // Cores dependentes do tema
    final bg = isDark ? backgroundDark : backgroundLight;
    final surface = isDark ? surfaceDark : surfaceLight;
    final surfaceElev = isDark ? surfaceElevatedDark : surfaceElevatedLight;
    final border = isDark ? borderDark : borderLight;
    final onSurface = isDark ? textPrimary : textPrimaryLight;
    final onSurfaceVariant = isDark ? textSecondary : textSecondaryLight;
    final muted = isDark ? textMuted : textMutedLight;
    final cardGrad =
        isDark ? cardGradient : cardGradientLight;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: neonGreen,
        onPrimary: isDark ? backgroundDark : Colors.white,
        primaryContainer: isDark
            ? neonGreen.withAlpha((0.18 * 255).round())
            : neonGreenDim.withAlpha((0.12 * 255).round()),
        onPrimaryContainer: isDark ? neonGreen : neonGreenDim,
        secondary: amberNeon,
        onSecondary: isDark ? backgroundDark : Colors.white,
        tertiary: cyanNeon,
        onTertiary: isDark ? backgroundDark : Colors.white,
        error: errorColor,
        onError: Colors.white,
        surface: surface,
        onSurface: onSurface,
        surfaceContainerHighest: surfaceElev,
        onSurfaceVariant: onSurfaceVariant,
        outline: border,
        outlineVariant: border,
      ),
      scaffoldBackgroundColor: bg,
      canvasColor: bg,
      splashColor: neonGreen.withAlpha(40),
      highlightColor: neonGreen.withAlpha(20),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 22,
          color: onSurface,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: onSurface),
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceElev,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: neonGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: errorColor, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        labelStyle: TextStyle(color: onSurfaceVariant),
        hintStyle: TextStyle(color: muted),
        prefixIconColor: onSurfaceVariant,
        suffixIconColor: onSurfaceVariant,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neonGreen,
          foregroundColor: isDark ? backgroundDark : Colors.white,
          disabledBackgroundColor: surfaceElev,
          disabledForegroundColor: muted,
          elevation: 0,
          padding:
              const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: 0.3,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: neonGreenDim,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: neonGreenDim,
          side: const BorderSide(color: neonGreen, width: 1.5),
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: neonGreen.withAlpha(30),
        labelStyle: TextStyle(
          color: isDark ? neonGreen : neonGreenDim,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide(color: neonGreen.withAlpha(60)),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: DividerThemeData(
        color: border,
        thickness: 1,
        space: 1,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return neonGreen;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(
            isDark ? backgroundDark : Colors.white),
        side: BorderSide(color: border, width: 1.5),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return neonGreen;
          return onSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return neonGreen.withAlpha(80);
          }
          return surfaceElev;
        }),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: neonGreen,
        linearTrackColor: border,
        circularTrackColor: border,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: neonGreen,
        inactiveTrackColor: border,
        thumbColor: neonGreen,
        overlayColor: neonGreen.withAlpha(40),
        valueIndicatorColor: neonGreen,
        valueIndicatorTextStyle: TextStyle(
            color: isDark ? backgroundDark : Colors.white,
            fontWeight: FontWeight.w700),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceElev,
        contentTextStyle: TextStyle(color: onSurface),
        actionTextColor: neonGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: border),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: neonGreen,
        unselectedItemColor: muted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: border),
        ),
      ),
      iconTheme: IconThemeData(color: onSurface),
      textTheme: TextTheme(
        displayLarge: TextStyle(
            fontWeight: FontWeight.w900,
            color: onSurface,
            letterSpacing: -1.0),
        displayMedium: TextStyle(
            fontWeight: FontWeight.w900,
            color: onSurface,
            letterSpacing: -0.8),
        displaySmall: TextStyle(
            fontWeight: FontWeight.w800,
            color: onSurface,
            letterSpacing: -0.6),
        headlineLarge: TextStyle(
            fontWeight: FontWeight.w800,
            color: onSurface,
            letterSpacing: -0.6),
        headlineMedium: TextStyle(
            fontWeight: FontWeight.w800,
            color: onSurface,
            letterSpacing: -0.4),
        headlineSmall: TextStyle(
            fontWeight: FontWeight.w700,
            color: onSurface,
            letterSpacing: -0.3),
        titleLarge: TextStyle(
            fontWeight: FontWeight.w700, color: onSurface),
        titleMedium: TextStyle(
            fontWeight: FontWeight.w600, color: onSurface),
        titleSmall: TextStyle(
            fontWeight: FontWeight.w600, color: onSurfaceVariant),
        bodyLarge: TextStyle(color: onSurface, height: 1.4),
        bodyMedium: TextStyle(color: onSurfaceVariant, height: 1.4),
        bodySmall: TextStyle(color: muted, height: 1.4),
        labelLarge: TextStyle(
            fontWeight: FontWeight.w700,
            color: onSurface,
            letterSpacing: 0.3),
        labelMedium: TextStyle(
            fontWeight: FontWeight.w600, color: onSurfaceVariant),
        labelSmall: TextStyle(
            fontWeight: FontWeight.w600, color: muted),
      ),
      cardColor: surface,
      // gradient para uso em widgets custom
      extensions: <ThemeExtension<dynamic>>[
        AppThemeExtension(
          cardGradient: cardGrad,
          isDark: isDark,
        ),
      ],
    );
  }
}

/// Extensão de tema para acessar o gradiente do card e um flag isDark
/// sem precisar de Theme.of(context).brightness em todos os lugares.
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final LinearGradient cardGradient;
  final bool isDark;

  const AppThemeExtension({
    required this.cardGradient,
    required this.isDark,
  });

  @override
  ThemeExtension<AppThemeExtension> copyWith({
    LinearGradient? cardGradient,
    bool? isDark,
  }) {
    return AppThemeExtension(
      cardGradient: cardGradient ?? this.cardGradient,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  ThemeExtension<AppThemeExtension> lerp(
      ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      cardGradient: cardGradient,
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}
