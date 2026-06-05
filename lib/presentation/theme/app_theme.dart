import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 🌿 Tema "Dark Botânico"
/// Inspirado em estufas noturnas, hortas urbanas sob luz neon e ficção científica
/// botânica. Paleta profunda com acentos em verde neon e âmbar quente.
class AppTheme {
  // === CORES PRIMÁRIAS ===
  static const Color neonGreen = Color(0xFF00FF88); // verde neon assinatura
  static const Color neonGreenDim = Color(0xFF00C46A); // variação mais calma
  static const Color leafGreen = Color(0xFF2EBE73); // verde folha
  static const Color amberNeon = Color(0xFFFFB347); // âmbar quente
  static const Color magenta = Color(0xFFE63F8C); // magenta vibrante
  static const Color cyanNeon = Color(0xFF00E5FF); // ciano elétrico

  // === FUNDOS (dark first) ===
  static const Color backgroundDark = Color(0xFF0A0F0D); // quase preto esverdeado
  static const Color surfaceDark = Color(0xFF131A16); // cards
  static const Color surfaceElevatedDark = Color(0xFF1B2520); // cards elevados
  static const Color borderDark = Color(0xFF2A3A30); // bordas sutis

  // Light mode também escuro pra consistência
  static const Color backgroundLight = Color(0xFF0E1411);
  static const Color surfaceLight = Color(0xFF131A16);
  static const Color cardDark = Color(0xFF1B2520);

  // === TEXTO ===
  static const Color textPrimary = Color(0xFFE8FFF0); // branco-esverdeado
  static const Color textSecondary = Color(0xFF8FB5A0); // verde-acinzentado
  static const Color textMuted = Color(0xFF5A7A6A);

  // === ESTADOS ===
  static const Color errorColor = Color(0xFFFF4D6D); // vermelho-rosa neon
  static const Color warningColor = Color(0xFFFFC857); // âmbar alerta
  static const Color successColor = Color(0xFF00FF88); // mesmo do neon
  static const Color infoColor = Color(0xFF00E5FF);

  // Mantidos para compatibilidade (alguns widgets podem referenciar)
  static const Color primaryGreen = neonGreenDim;
  static const Color primaryGreenLight = neonGreen;
  static const Color accentEarth = amberNeon;
  static const Color accentEarthLight = amberNeon;
  static const Color textPrimaryLight = textPrimary;
  static const Color textSecondaryLight = textSecondary;
  static const Color textPrimaryDark = textPrimary;
  static const Color textSecondaryDark = textSecondary;
  static const Color backgroundLightLegacy = backgroundLight;

  // === GRADIENTES ===
  static const LinearGradient neonGradient = LinearGradient(
    colors: [Color(0xFF00FF88), Color(0xFF00E5FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1B2520), Color(0xFF131A16)],
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

  // === TEMA "CLARO" (também escuro, só com leves diferenças) ===
  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final base = isDark ? backgroundDark : backgroundLight;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: neonGreen,
        onPrimary: backgroundDark,
        secondary: amberNeon,
        onSecondary: backgroundDark,
        tertiary: cyanNeon,
        onTertiary: backgroundDark,
        error: errorColor,
        onError: Colors.white,
        surface: surfaceDark,
        onSurface: textPrimary,
        surfaceContainerHighest: surfaceElevatedDark,
        outline: borderDark,
        outlineVariant: borderDark,
      ),
      scaffoldBackgroundColor: base,
      canvasColor: base,
      splashColor: neonGreen.withAlpha(40),
      highlightColor: neonGreen.withAlpha(20),
      appBarTheme: AppBarTheme(
        backgroundColor: base,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 22,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderDark, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceElevatedDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderDark, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: borderDark, width: 1),
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
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textMuted),
        prefixIconColor: textSecondary,
        suffixIconColor: textSecondary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neonGreen,
          foregroundColor: backgroundDark,
          disabledBackgroundColor: surfaceElevatedDark,
          disabledForegroundColor: textMuted,
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
          foregroundColor: neonGreen,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: neonGreen,
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
        labelStyle: const TextStyle(
          color: neonGreen,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide(color: neonGreen.withAlpha(60)),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: const DividerThemeData(
        color: borderDark,
        thickness: 1,
        space: 1,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return neonGreen;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(backgroundDark),
        side: const BorderSide(color: borderDark, width: 1.5),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return neonGreen;
          return textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return neonGreen.withAlpha(80);
          }
          return surfaceElevatedDark;
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: neonGreen,
        linearTrackColor: borderDark,
        circularTrackColor: borderDark,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: neonGreen,
        inactiveTrackColor: borderDark,
        thumbColor: neonGreen,
        overlayColor: neonGreen.withAlpha(40),
        valueIndicatorColor: neonGreen,
        valueIndicatorTextStyle:
            const TextStyle(color: backgroundDark, fontWeight: FontWeight.w700),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceElevatedDark,
        contentTextStyle: const TextStyle(color: textPrimary),
        actionTextColor: neonGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: borderDark),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surfaceDark,
        selectedItemColor: neonGreen,
        unselectedItemColor: textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceDark,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderDark),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
            fontWeight: FontWeight.w900,
            color: textPrimary,
            letterSpacing: -1.0),
        displayMedium: TextStyle(
            fontWeight: FontWeight.w900,
            color: textPrimary,
            letterSpacing: -0.8),
        displaySmall: TextStyle(
            fontWeight: FontWeight.w800,
            color: textPrimary,
            letterSpacing: -0.6),
        headlineLarge: TextStyle(
            fontWeight: FontWeight.w800,
            color: textPrimary,
            letterSpacing: -0.6),
        headlineMedium: TextStyle(
            fontWeight: FontWeight.w800,
            color: textPrimary,
            letterSpacing: -0.4),
        headlineSmall: TextStyle(
            fontWeight: FontWeight.w700,
            color: textPrimary,
            letterSpacing: -0.3),
        titleLarge: TextStyle(
            fontWeight: FontWeight.w700, color: textPrimary),
        titleMedium: TextStyle(
            fontWeight: FontWeight.w600, color: textPrimary),
        titleSmall: TextStyle(
            fontWeight: FontWeight.w600, color: textSecondary),
        bodyLarge: TextStyle(color: textPrimary, height: 1.4),
        bodyMedium: TextStyle(color: textSecondary, height: 1.4),
        bodySmall: TextStyle(color: textMuted, height: 1.4),
        labelLarge: TextStyle(
            fontWeight: FontWeight.w700,
            color: textPrimary,
            letterSpacing: 0.3),
        labelMedium: TextStyle(
            fontWeight: FontWeight.w600, color: textSecondary),
        labelSmall: TextStyle(
            fontWeight: FontWeight.w600, color: textMuted),
      ),
    );
  }
}
