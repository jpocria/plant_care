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
        body: Center(child: CircularProgressIndicator()),
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
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.go('/home'),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppTheme.primaryGreen,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(plan.emoji, style: const TextStyle(fontSize: 64)),
                      const SizedBox(height: 8),
                      Text(
                        plan.name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800),
                      ),
                      if (plan.scientificName.isNotEmpty)
                        Text(
                          plan.scientificName,
                          style: TextStyle(
                              color: Colors.white.withAlpha(180),
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
                  _SummaryCard(plan: plan),
                  const SizedBox(height: 16),
                  _Section(
                    icon: '🌱',
                    title: 'Plantio',
                    children: [
                      _Item('Melhor época', plan.planting.bestSeason),
                      _Item('Método', plan.planting.plantingMethod),
                      _Item('Espaçamento', plan.planting.spacing),
                      _Item('Profundidade',
                          '${plan.planting.depthCm.toStringAsFixed(1)} cm'),
                      _Item('Germinação', plan.planting.germinationDays),
                    ],
                  ),
                  _Section(
                    icon: '💧',
                    title: 'Rega',
                    children: [
                      _Item('Frequência',
                          '${plan.watering.frequencyPerWeek}x por semana'),
                      _Item('Quantidade', '${plan.watering.amountMl} ml/vez'),
                      _Item('Melhor horário', plan.watering.bestTime),
                      _Item('Dica', plan.watering.tip, isTip: true),
                    ],
                  ),
                  _Section(
                    icon: '🧪',
                    title: 'Adubação',
                    children: plan.fertilization
                        .map((f) => _Item('•', f))
                        .toList(),
                  ),
                  _Section(
                    icon: '🌡️',
                    title: 'Ambiente',
                    children: [
                      _Item('Temperatura ideal',
                          '${plan.environment.idealTemperatureC}°C'),
                      _Item('Umidade', plan.environment.humidity),
                      _Item('Luz', plan.environment.lightHours),
                      _Item('Tolerância', plan.environment.tolerates),
                    ],
                  ),
                  _Section(
                    icon: '🪨',
                    title: 'Solo',
                    children: [
                      _Item('Tipo', plan.soil.type),
                      _Item('pH ideal', plan.soil.ph),
                      _Item('Preparo', plan.soil.preparation),
                    ],
                  ),
                  _Section(
                    icon: '🐛',
                    title: 'Pragas e doenças',
                    children:
                        plan.pests.map((p) => _Item('•', p)).toList(),
                  ),
                  _Section(
                    icon: '🌾',
                    title: 'Colheita',
                    children: [
                      _Item('Tempo até colheita',
                          '${plan.harvest.daysToHarvest} dias'),
                      _Item('Como colher', plan.harvest.harvestMethod),
                      _Item('Indicadores', plan.harvest.indicators),
                    ],
                  ),
                  _Section(
                    icon: '📅',
                    title: 'Calendário',
                    children: [
                      _Item('Meses de plantio',
                          _monthsToString(plan.calendar.sowingMonths)),
                      _Item('Meses de colheita',
                          _monthsToString(plan.calendar.harvestMonths)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Plano gerado para: ${widget.plantName}',
                      style: const TextStyle(
                          fontSize: 12, fontStyle: FontStyle.italic),
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
      'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
      'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'
    ];
    return months.map((m) => names[m - 1]).join(', ');
  }
}

class _SummaryCard extends StatelessWidget {
  final CarePlanModel plan;
  const _SummaryCard({required this.plan});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppTheme.primaryGreen.withAlpha(80), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Stat('🌡️', '${plan.environment.idealTemperatureC}°C', 'Temp.'),
          _Stat('💧', '${plan.watering.frequencyPerWeek}x', 'Rega/sem'),
          _Stat('🌾', '${plan.harvest.daysToHarvest}d', 'Colheita'),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String emoji, value, label;
  const _Stat(this.emoji, this.value, this.label);
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String icon, title;
  final List<Widget> children;
  const _Section(
      {required this.icon, required this.title, required this.children});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppTheme.cardDark
                : Colors.white,
            borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                children: [
                  Text(icon, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16)),
                ],
              ),
            ),
            const Divider(height: 1),
            ...children,
          ],
        ),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontStyle: isTip ? FontStyle.italic : FontStyle.normal,
                color: isTip ? AppTheme.primaryGreen : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
