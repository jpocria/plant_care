import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/plant_repository.dart';
import '../../../data/repositories/alert_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/plant_card.dart';
import '../../widgets/plant_logo.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/theme_fab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasLoadedPlants = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedPlants) {
      final plantRepo = context.read<PlantRepository>();
      if (plantRepo.plants.isEmpty && !plantRepo.isLoading) {
        plantRepo.loadPlants();
      }
      _hasLoadedPlants = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authRepo = context.watch<AuthRepository>();
    final plantRepo = context.watch<PlantRepository>();
    final alertRepo = context.watch<AlertRepository>();
    final theme = Theme.of(context);
    final userName =
        authRepo.currentUser?.name.split(' ').first ?? 'Usuário';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: theme.scaffoldBackgroundColor,
            // === LOGO OFICIAL NO LEADING DA SLIVERAPPBAR ===
            // Única instância do logo na home (sempre visível).
            leadingWidth: 64,
            leading: const Padding(
              padding: EdgeInsets.only(left: 12, top: 8, bottom: 8),
              child: PlantLogo(size: 47, glow: true),
            ),
            title: const SizedBox.shrink(),
            actions: [
              // === TOGGLE SOL/LUA NO CANTINHO DA TELA ===
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Center(child: ThemeFab(size: 40)),
              ),
              Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () => context.go('/alerts'),
                  ),
                  if (alertRepo.unreadCount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppTheme.errorColor,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${alertRepo.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              IconButton(
                icon: const CircleAvatar(
                  radius: 15,
                  backgroundColor: AppTheme.primaryGreen,
                  child: Icon(Icons.person_outline,
                      size: 16, color: Colors.white),
                ),
                onPressed: () => context.go('/profile'),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Olá, $userName 👋',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Confira como estão suas plantas hoje',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: '🌱',
                      label: 'Total',
                      value: '${plantRepo.plants.length}',
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      icon: '✅',
                      label: 'Saudáveis',
                      value: '${plantRepo.healthyCount}',
                      color: AppTheme.successColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      icon: '⚠️',
                      label: 'Atenção',
                      value: '${plantRepo.needsAttentionCount}',
                      color: AppTheme.warningColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (alertRepo.unresolvedAlerts.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withAlpha((0.12 * 255).round()),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppTheme.warningColor.withAlpha((0.3 * 255).round())),
                  ),
                  child: Row(
                    children: [
                      const Text('⚠️',
                          style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                      '${alertRepo.unresolvedAlerts.length} alerta(s) pendente(s)',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.warningColor,
                      ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/alerts'),
                        child: const Text('Ver'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Minhas Plantas',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (plantRepo.plants.isNotEmpty)
                    Text('${plantRepo.plants.length} plantas',
                        style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
          plantRepo.plants.isEmpty
              ? SliverFillRemaining(
                  child: _EmptyState(
                      onAdd: () => context.go('/plant/add')),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == plantRepo.plants.length) {
                          return const SizedBox(height: 120);
                        }
                        final plant = plantRepo.plants[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: PlantCard(
                            plant: plant,
                            onTap: () =>
                                context.go('/plant/${plant.id}'),
                            onWater: () => context
                                .read<PlantRepository>()
                                .waterPlant(plant.id),
                          ),
                        );
                      },
                      childCount: plantRepo.plants.length + 1,
                    ),
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/plant/add'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nova planta',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo ornamental no estado vazio, deixando claro a identidade
            // da marca mesmo sem plantas cadastradas.
            const PlantLogoImage.square(96),
            const SizedBox(height: 20),
            Text('Nenhuma planta cadastrada',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
                textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(
                'Adicione sua primeira planta e comece a monitorá-la!',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Adicionar planta'),
            ),
          ],
        ),
      ),
    );
  }
}
