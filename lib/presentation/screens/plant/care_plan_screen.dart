import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/care_plan_model.dart';
import '../../../core/services/care_plan_service.dart';
import '../../theme/app_theme.dart';

class CarePlanScreen extends StatefulWidget {
  final String vegetableId;
  final String plantName;
  const CarePlanScreen(
      {super.key, required this.vegetableId, required this.plantName});

  @override
  State<CarePlanScreen> createState() => _CarePlanScreenState();
}

class _CarePlanScreenState extends State<CarePlanScreen> {
  final _service = CarePlanService();
  CarePlanModel? _plan;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final plan = await _service.findById(widget.vegetableId);
    if (mounted) {
      setState(() {
        _plan = plan;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.neonGreen)),
      );
    }
    if (_plan == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Plano não encontrado')),
      );
    }
    final plan = _plan!;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(plan.emoji, style: const TextStyle(fontSize: 64)),
                      const SizedBox(height: 8),
                      Text(
                        plan.name,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4),
                      ),
                      if (plan.scientificName.isNotEmpty)
                        Text(
                          plan.scientificName,
                          style: TextStyle(
                              color: AppTheme.textPrimary.withAlpha(180),
                              fontSize: 12,
                              fontStyle: FontStyle.italic),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Resumo: 3 colunas
                  _RowCol3([
                    _MiniStat(
                        icon: '🌡️',
                        label: 'Temp.',
                        value: '${plan.environment.idealTemperatureC}°C',
                        color: AppTheme.amberNeon),
                    _MiniStat(
                        icon: '💧',
                        label: 'Rega/sem',
                        value: '${plan.watering.frequencyPerWeek}x',
                        color: const Color(0xFF3B82F6)),
                    _MiniStat(
                        icon: '🌾',
                        label: 'Colheita',
                        value: '${plan.harvest.daysToHarvest}d',
                        color: AppTheme.neonGreen),
                  ]),
                  const SizedBox(height: 16),

                  // Plantio + Rega (2 colunas)
                  _Row2([
                    _SectionCard(
                        title: 'Plantio',
                        emoji: '🌱',
                        items: [
                          _Item('Época', plan.planting.bestSeason),
                          _Item('Método', plan.planting.plantingMethod),
                          _Item('Espaçamento', plan.planting.spacing),
                          _Item('Profundidade',
                              '${plan.planting.depthCm.toStringAsFixed(1)} cm'),
                          _Item('Germinação', plan.planting.germinationDays),
                        ]),
                    _SectionCard(
                        title: 'Rega',
                        emoji: '💧',
                        items: [
                          _Item('Frequência',
                              '${plan.watering.frequencyPerWeek}x por semana'),
                          _Item('Quantidade',
                              '${plan.watering.amountMl} ml/vez'),
                          _Item('Horário', plan.watering.bestTime),
                          _Item('Dica', plan.watering.tip, isTip: true),
                        ]),
                  ]),
                  const SizedBox(height: 12),

                  // Adubação + Pragas (2 colunas)
                  _Row2([
                    _SectionCard(
                        title: 'Adubação',
                        emoji: '🧪',
                        items: plan.fertilization
                            .map((f) => _Item('•', f))
                            .toList()),
                    _SectionCard(
                        title: 'Pragas',
                        emoji: '🐛',
                        items: plan.pests.map((p) => _Item('•', p)).toList()),
                  ]),
                  const SizedBox(height: 12),

                  // Ambiente + Solo (2 colunas)
                  _Row2([
                    _SectionCard(
                        title: 'Ambiente',
                        emoji: '🌡️',
                        items: [
                          _Item('Temperatura',
                              '${plan.environment.idealTemperatureC}°C'),
                          _Item('Umidade', plan.environment.humidity),
                          _Item('Luz', plan.environment.lightHours),
                          _Item('Tolerância', plan.environment.tolerates),
                        ]),
                    _SectionCard(
                        title: 'Solo',
                        emoji: '🪨',
                        items: [
                          _Item('Tipo', plan.soil.type),
                          _Item('pH ideal', plan.soil.ph),
                          _Item('Preparo', plan.soil.preparation),
                        ]),
                  ]),
                  const SizedBox(height: 12),

                  // Colheita + Calendário (2 colunas)
                  _Row2([
                    _SectionCard(
                        title: 'Colheita',
                        emoji: '🌾',
                        items: [
                          _Item('Tempo',
                              '${plan.harvest.daysToHarvest} dias'),
                          _Item('Como', plan.harvest.harvestMethod),
                          _Item('Indicador', plan.harvest.indicators),
                        ]),
                    _SectionCard(
                        title: 'Calendário',
                        emoji: '📅',
                        items: [
                          _Item('Plantio',
                              _monthsToString(plan.calendar.sowingMonths)),
                          _Item('Colheita',
                              _monthsToString(plan.calendar.harvestMonths)),
                        ]),
                  ]),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Plano gerado para: ${widget.plantName}',
                      style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: AppTheme.textMuted),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _monthsToString(List<int> months) {
    const names = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez'
    ];
    return months.map((m) => names[m - 1]).join(', ');
  }
}

/// Linha de 2 colunas
class _Row2 extends StatelessWidget {
  final List<Widget> children;
  const _Row2(this.children);
  @override
  Widget build(BuildContext context) => IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (int i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(child: children[i]),
            ],
          ],
        ),
      );
}

/// Linha de 3 colunas
class _RowCol3 extends StatelessWidget {
  final List<Widget> children;
  const _RowCol3(this.children);
  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            children[i],
          ],
        ],
      );
}

/// Card de seção completo: header + lista de itens
class _SectionCard extends StatelessWidget {
  final String title;
  final String emoji;
  final List<_Item> items;
  const _SectionCard({
    required this.title,
    required this.emoji,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderDark, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.neonGreen,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (int i = 0; i < items.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: items[i],
            ),
            if (i < items.length - 1)
              const Divider(
                  height: 1, thickness: 1, color: AppTheme.borderDark),
          ],
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final String label;
  final String value;
  final bool isTip;
  const _Item(this.label, this.value, {this.isTip = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: label == '•' ? 14 : 90,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: label == '•'
                  ? AppTheme.neonGreen
                  : AppTheme.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: isTip ? AppTheme.neonGreen : AppTheme.textPrimary,
              fontStyle: isTip ? FontStyle.italic : FontStyle.normal,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String icon, label, value;
  final Color color;
  const _MiniStat(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderDark, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textMuted,
                      fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: -0.3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
