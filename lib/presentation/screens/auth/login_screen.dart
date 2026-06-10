import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/services/theme_service.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/plant_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authRepo = context.read<AuthRepository>();
    final success = await authRepo.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (success && mounted) {
      context.go('/home');
    } else if (mounted) {
      _showError(authRepo.error ?? 'Erro ao fazer login');
    }
  }

  Future<void> _signInWithGoogle() async {
    final authRepo = context.read<AuthRepository>();
    final success = await authRepo.signInWithGoogle();

    if (success && mounted) {
      context.go('/home');
    } else if (mounted && authRepo.error != null) {
      _showError(authRepo.error!);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showForgotPassword() {
    final emailController =
        TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Redefinir senha',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Digite seu email para receber um link de redefinição.'),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final authRepo = context.read<AuthRepository>();
              final success =
                  await authRepo.sendPasswordReset(emailController.text);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Email de redefinição enviado!'
                        : authRepo.error ?? 'Erro'),
                    backgroundColor: success
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }

  /// Mostra um seletor rápido de tema (claro/escuro/sistema).
  void _showThemePicker() {
    final themeService = context.read<ThemeService>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.outline,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text('Escolha um tema',
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        )),
                const SizedBox(height: 6),
                Text(
                  'A escolha fica salva no seu dispositivo.',
                  style: Theme.of(ctx).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                _themeOption(
                  ctx: ctx,
                  icon: Icons.wb_sunny_rounded,
                  title: 'Claro',
                  subtitle: 'Visual luminoso e suave',
                  isSelected: themeService.isLightMode,
                  onTap: () async {
                    await themeService.setLightMode();
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: 10),
                _themeOption(
                  ctx: ctx,
                  icon: Icons.nightlight_round,
                  title: 'Escuro',
                  subtitle: 'Visual com fundo escuro',
                  isSelected: themeService.isDarkMode,
                  onTap: () async {
                    await themeService.setDarkMode();
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
                const SizedBox(height: 10),
                _themeOption(
                  ctx: ctx,
                  icon: Icons.settings_suggest_rounded,
                  title: 'Sistema',
                  subtitle: 'Segue a preferência do dispositivo',
                  isSelected: themeService.isSystemMode,
                  onTap: () async {
                    await themeService.setSystemMode();
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _themeOption({
    required BuildContext ctx,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(ctx);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: isSelected ? 1.5 : 1,
          ),
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 26),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded,
                  color: theme.colorScheme.primary, size: 22),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authRepo = context.watch<AuthRepository>();
    final theme = Theme.of(context);

    return LoadingOverlay(
      isLoading: authRepo.isLoading,
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              // Botao de escolha de tema no canto superior direito
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  tooltip: 'Escolher tema',
                  onPressed: _showThemePicker,
                  icon: Icon(
                    Icons.brightness_6_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      Center(
                        child: Column(
                          children: [
                            // === LOGO OFICIAL PLANTCARE ===
                            const PlantLogo(size: 117),
                            const SizedBox(height: 20),
                            Text('Bem-vindo!',
                                style: theme.textTheme.headlineLarge
                                    ?.copyWith(letterSpacing: -0.5)),
                            const SizedBox(height: 6),
                            Text('Entre para cuidar das suas plantas',
                                style: theme.textTheme.bodyMedium),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                      CustomTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'seu@email.com',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Digite seu email';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                            return 'Email inválido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _passwordController,
                        label: 'Senha',
                        hint: '••••••••',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _signIn(),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Digite sua senha';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _showForgotPassword,
                          child: const Text('Esqueceu a senha?'),
                        ),
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        label: 'Entrar',
                        onPressed: _signIn,
                        isFullWidth: true,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child:
                                Text('ou', style: theme.textTheme.bodyMedium),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton(
                        onPressed: _signInWithGoogle,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          side: BorderSide(
                              color: theme.colorScheme.outline),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('G',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF4285F4))),
                            const SizedBox(width: 12),
                            Text('Entrar com Google',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: theme.colorScheme.onSurface,
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // === SELETOR RÁPIDO DE TEMA (claro/escuro/sistema) ===
                      _LoginThemeChooser(),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Não tem conta?',
                              style: theme.textTheme.bodyMedium),
                          TextButton(
                            onPressed: () => context.go('/auth/register'),
                            child: const Text('Criar conta'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pílulas horizontais: "Claro" / "Escuro" / "Sistema" para o usuário
/// escolher já na primeira tela do app.
class _LoginThemeChooser extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: _pill(
              ctx: context,
              label: 'Claro',
              icon: Icons.wb_sunny_rounded,
              isSelected: themeService.isLightMode,
              onTap: () => themeService.setLightMode(),
            ),
          ),
          Expanded(
            child: _pill(
              ctx: context,
              label: 'Escuro',
              icon: Icons.nightlight_round,
              isSelected: themeService.isDarkMode,
              onTap: () => themeService.setDarkMode(),
            ),
          ),
          Expanded(
            child: _pill(
              ctx: context,
              label: 'Sistema',
              icon: Icons.settings_suggest_rounded,
              isSelected: themeService.isSystemMode,
              onTap: () => themeService.setSystemMode(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill({
    required BuildContext ctx,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(ctx);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
