import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/plant_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/loading_overlay.dart';
import '../../widgets/theme_toggle_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  late AuthRepository _authRepository;
  late PlantRepository _plantRepository;
  late StorageService _storageService;

  UserModel? _currentUser;
  int _plantCount = 0;

  bool _isLoading = false;
  bool _isEditing = false;
  File? _pickedImage;

  @override
  void initState() {
    super.initState();
    _authRepository = context.read<AuthRepository>();
    _plantRepository = context.read<PlantRepository>();
    _storageService = context.read<StorageService>();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // ── Data loading ──────────────────────────────────────────────────────────

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final uid = context.read<AuthService>().currentUser?.uid;
      if (uid == null) return;

      final user = await _authRepository.getUserById(uid);
      final plants = await _plantRepository.getPlantsByUser(uid);

      setState(() {
        _currentUser = user;
        _plantCount = plants.length;
        _nameController.text = user?.name ?? '';
        _emailController.text = user?.email ?? '';
      });
    } catch (e) {
      _showSnackBar('Erro ao carregar perfil: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── Image picker ──────────────────────────────────────────────────────────

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
    }
  }

  // ── Save profile ──────────────────────────────────────────────────────────

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authService = context.read<AuthService>();
    setState(() => _isLoading = true);
    try {
      final uid = authService.currentUser?.uid;
      if (uid == null) {
        return;
      }

      String? photoUrl = _currentUser?.photoUrl;

      if (_pickedImage != null) {
        // StorageService.uploadProfileImage aceita File via parâmetro nomeado
        photoUrl = await _storageService.uploadProfileImage(
          uid: uid,
          file: _pickedImage,
        );
      }

      final updatedUser = _currentUser!.copyWith(
        name: _nameController.text.trim(),
        photoUrl: photoUrl,
      );

      await _authRepository.updateUser(updatedUser);
      await authService.updateDisplayName(
            _nameController.text.trim(),
          );

      setState(() {
        _currentUser = updatedUser;
        _isEditing = false;
        _pickedImage = null;
      });

      _showSnackBar('Perfil atualizado com sucesso!');
    } catch (e) {
      _showSnackBar('Erro ao salvar perfil: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── Password reset ────────────────────────────────────────────────────────

  Future<void> _sendPasswordReset() async {
    final email = _currentUser?.email;
    if (email == null) {
      return;
    }
    final authService = context.read<AuthService>();
    setState(() => _isLoading = true);
    try {
      await authService.sendPasswordResetEmail(email);
      _showSnackBar('E-mail de redefinição enviado para $email');
    } catch (e) {
      _showSnackBar('Erro: $e', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── Sign out ──────────────────────────────────────────────────────────────

  Future<void> _confirmSignOut() async {
    final authService = context.read<AuthService>();
    final confirmed = await _showConfirmDialog(
      title: 'Sair da conta',
      message: 'Tem certeza que deseja sair?',
      confirmLabel: 'Sair',
      isDestructive: false,
    );
    if (confirmed == true) {
      await authService.signOut();
      if (mounted) {
        context.go('/auth/login');
      }
    }
  }

  // ── Delete account ────────────────────────────────────────────────────────

  Future<void> _confirmDeleteAccount() async {
    final authService = context.read<AuthService>();
    final confirmed = await _showConfirmDialog(
      title: 'Excluir conta',
      message:
          'Esta ação é irreversível. Todos os seus dados serão permanentemente excluídos.',
      confirmLabel: 'Excluir',
      isDestructive: true,
    );
    if (confirmed != true) {
      return;
    }

    // Re-autenticação: solicita a senha atual
    final password = await _promptPassword();
    if (password == null || password.isEmpty) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      final uid = authService.currentUser?.uid;
      if (uid != null) {
        await _authRepository.deleteUser(uid);
      }
      // deleteAccount(password) faz reauthenticate internamente
      await authService.deleteAccount(password: password);
      if (mounted) {
        context.go('/auth/login');
      }
    } catch (e) {
      _showSnackBar('Erro ao excluir conta: $e', isError: true);
      setState(() => _isLoading = false);
    }
  }

  // ── Dialog helpers ────────────────────────────────────────────────────────

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    required bool isDestructive,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          isDestructive
              ? ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text(confirmLabel),
                )
              : TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  style:
                      TextButton.styleFrom(foregroundColor: Colors.orange),
                  child: Text(confirmLabel),
                ),
        ],
      ),
    );
  }

  Future<String?> _promptPassword() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirme sua senha'),
        content: TextField(
          controller: controller,
          obscureText: true,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Digite sua senha atual',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  /// "Sobre o app" customizado, com o logotipo (PNG oficial) em destaque.
  void _showCustomAbout() {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Dialog(
          backgroundColor: theme.colorScheme.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Círculo ornamental com o PNG oficial
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.surfaceContainerHighest
                        .withAlpha((0.3 * 255).round()),
                    border: Border.all(
                      color:
                          AppTheme.neonGreen.withAlpha((0.45 * 255).round()),
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Image.asset(
                      'assets/logo-plantcare.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Monitoramento inteligente de plantas',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.neonGreen.withAlpha((0.15 * 255).round()),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Versão 1.0.0',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.neonGreenDim,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Suas plantas, sempre saudáveis. 🌱',
                  style: theme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '© 2025 PlantCare Biotech',
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface
                        .withAlpha((0.5 * 255).round()),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Fechar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez',
    ];
    return '${date.day} de ${months[date.month - 1]}. de ${date.year}';
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          // === LOGOTIPO OFICIAL (PNG) NO APPBAR ===
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Image.asset(
              'assets/logo-plantcare.png',
              width: 36,
              height: 36,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: colorScheme.surface,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            tooltip: 'Voltar',
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
          actions: [
            if (!_isEditing)
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Editar perfil',
                onPressed: () => setState(() => _isEditing = true),
              )
            else
              TextButton(
                onPressed: () => setState(() {
                  _isEditing = false;
                  _pickedImage = null;
                  _nameController.text = _currentUser?.name ?? '';
                }),
                child: const Text('Cancelar'),
              ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _loadUserData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildBrandBanner(theme),
                const SizedBox(height: 20),
                _buildAvatar(colorScheme),
                const SizedBox(height: 24),
                _buildStatsRow(),
                const SizedBox(height: 28),
                _isEditing ? _buildEditForm() : _buildInfoCard(theme),
                const SizedBox(height: 28),
                const ThemeToggleWidget(isCompact: false),
                const SizedBox(height: 28),
                _buildSettingsSection(theme),
                const SizedBox(height: 16),
                _buildDangerZone(theme),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Brand banner ──────────────────────────────────────────────────────────
  // Faixa com gradiente + logotipo PNG oficial + tagline, ancorando a marca
  // no topo do perfil (sem repetir o nome "PlantCare" por já estar na logo).
  Widget _buildBrandBanner(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.neonGreen.withAlpha((0.22 * 255).round()),
            AppTheme.cyanNeon.withAlpha((0.10 * 255).round()),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.neonGreen.withAlpha((0.35 * 255).round()),
        ),
      ),
      child: Row(
        children: [
          Image.asset('assets/logo-plantcare.png', width: 68, height: 68),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Cuidando das suas plantas com inteligência',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  // ── Avatar ────────────────────────────────────────────────────────────────

  Widget _buildAvatar(ColorScheme colorScheme) {
    const double radius = 52;
    final hasNewImage = _pickedImage != null;
    final hasRemoteImage =
        _currentUser?.photoUrl != null && _currentUser!.photoUrl!.isNotEmpty;

    Widget avatar;
    if (hasNewImage) {
      avatar = CircleAvatar(
        radius: radius,
        backgroundImage: FileImage(_pickedImage!),
      );
    } else if (hasRemoteImage) {
      avatar = CachedNetworkImage(
        imageUrl: _currentUser!.photoUrl!,
        imageBuilder: (_, img) =>
            CircleAvatar(radius: radius, backgroundImage: img),
        placeholder: (_, __) => CircleAvatar(
          radius: radius,
          backgroundColor: colorScheme.primaryContainer,
          child: const CircularProgressIndicator(strokeWidth: 2),
        ),
        errorWidget: (_, __, ___) => _defaultAvatar(colorScheme, radius),
      );
    } else {
      avatar = _defaultAvatar(colorScheme, radius);
    }

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: colorScheme.primary.withAlpha((0.3 * 255).round()),
              width: 3,
            ),
          ),
          child: avatar,
        ),
        if (_isEditing)
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child:
                  const Icon(Icons.camera_alt, size: 18, color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _defaultAvatar(ColorScheme colorScheme, double radius) {
    final initial = (_currentUser?.name.isNotEmpty == true)
        ? _currentUser!.name[0].toUpperCase()
        : '?';
    return CircleAvatar(
      radius: radius,
      backgroundColor: colorScheme.primaryContainer,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: radius * 0.8,
          fontWeight: FontWeight.bold,
          color: colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  // ── Stats ─────────────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    return _StatChip(
      icon: Icons.eco_outlined,
      label: 'Plantas cadastradas',
      value: '$_plantCount',
      color: Colors.green,
    );
  }

  // ── Info card ─────────────────────────────────────────────────────────────

  Widget _buildInfoCard(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _InfoRow(
              icon: Icons.person_outline,
              label: 'Nome',
              value: _currentUser?.name ?? '—',
            ),
            const Divider(height: 24),
            _InfoRow(
              icon: Icons.email_outlined,
              label: 'E-mail',
              value: _currentUser?.email ?? '—',
            ),
            const Divider(height: 24),
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Membro desde',
              value: _formatDate(_currentUser?.createdAt ?? DateTime.now()),
            ),
          ],
        ),
      ),
    );
  }

  // ── Edit form ─────────────────────────────────────────────────────────────

  Widget _buildEditForm() {
    final colorScheme = Theme.of(context).colorScheme;
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            controller: _nameController,
            label: 'Nome completo',
            prefixIcon: Icons.person_outline,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Informe seu nome';
              if (v.trim().length < 2) return 'Nome muito curto';
              return null;
            },
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _emailController,
            label: 'E-mail',
            prefixIcon: Icons.email_outlined,
            readOnly: true,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Para alterar o e-mail, entre em contato com o suporte.',
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 20),
          CustomButton(
            onPressed: _saveProfile,
            label: 'Salvar alterações',
            icon: Icons.check,
          ),
        ],
      ),
    );
  }

  // ── Settings section ──────────────────────────────────────────────────────

  Widget _buildSettingsSection(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.lock_outline,
            title: 'Alterar senha',
            subtitle: 'Enviar e-mail de redefinição',
            onTap: _sendPasswordReset,
          ),
          const Divider(height: 0, indent: 56),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'Sobre o app',
            subtitle: 'PlantCare v1.0.0',
            onTap: _showCustomAbout,
          ),
          const Divider(height: 0, indent: 56),
          _SettingsTile(
            icon: Icons.logout,
            title: 'Sair da conta',
            iconColor: Colors.orange,
            onTap: _confirmSignOut,
          ),
        ],
      ),
    );
  }

  // ── Danger zone ───────────────────────────────────────────────────────────

  Widget _buildDangerZone(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.red, width: 0.8),
      ),
      child: _SettingsTile(
        icon: Icons.delete_forever_outlined,
        title: 'Excluir conta',
        subtitle: 'Remove permanentemente seus dados',
        iconColor: Colors.red,
        titleColor: Colors.red,
        onTap: _confirmDeleteAccount,
      ),
    );
  }
}

// ─── Private helper widgets ─────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha((0.3 * 255).round())),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style:
                    TextStyle(fontSize: 11, color: color.withAlpha((0.8 * 255).round())),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final Color? titleColor;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: iconColor ?? theme.colorScheme.primary),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w500, color: titleColor),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}