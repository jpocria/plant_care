import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Serviço para gerenciar tema (claro/escuro) da aplicação
class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';

  late SharedPreferences _prefs;
  late ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isSystemMode => _themeMode == ThemeMode.system;

  /// Inicializar o serviço
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _loadThemeMode();
      debugPrint('✅ ThemeService inicializado');
    } catch (e) {
      debugPrint('❌ Erro ao inicializar ThemeService: $e');
      _themeMode = ThemeMode.system;
    }
  }

  /// Carregar tema do SharedPreferences
  void _loadThemeMode() {
    final savedTheme = _prefs.getString(_themeKey) ?? 'system';
    _themeMode = _stringToThemeMode(savedTheme);
    debugPrint('📱 Tema carregado: $savedTheme');
  }

  /// Converter String para ThemeMode
  ThemeMode _stringToThemeMode(String value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  /// Converter ThemeMode para String
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.light:
        return 'light';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// Definir tema como claro
  Future<void> setLightMode() async {
    _themeMode = ThemeMode.light;
    await _saveThemeMode();
    notifyListeners();
    debugPrint('🌞 Tema alterado para: CLARO');
  }

  /// Definir tema como escuro
  Future<void> setDarkMode() async {
    _themeMode = ThemeMode.dark;
    await _saveThemeMode();
    notifyListeners();
    debugPrint('🌙 Tema alterado para: ESCURO');
  }

  /// Definir tema como sistema (segue preferência do SO)
  Future<void> setSystemMode() async {
    _themeMode = ThemeMode.system;
    await _saveThemeMode();
    notifyListeners();
    debugPrint('🔄 Tema alterado para: SISTEMA');
  }

  /// Alternar entre tema claro e escuro
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      await setLightMode();
    } else {
      await setDarkMode();
    }
  }

  /// Salvar tema no SharedPreferences
  Future<void> _saveThemeMode() async {
    try {
      await _prefs.setString(_themeKey, _themeModeToString(_themeMode));
      debugPrint('💾 Tema salvo: ${_themeModeToString(_themeMode)}');
    } catch (e) {
      debugPrint('❌ Erro ao salvar tema: $e');
    }
  }

  /// Obter descrição do tema atual
  String getThemeDescription() {
    switch (_themeMode) {
      case ThemeMode.dark:
        return 'Escuro 🌙';
      case ThemeMode.light:
        return 'Claro ☀️';
      case ThemeMode.system:
        return 'Sistema 🔄';
    }
  }
}
