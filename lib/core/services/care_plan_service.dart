import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:logger/logger.dart';
import '../../data/models/care_plan_model.dart';

/// Carrega e consulta os planos de cuidados de hortaliças.
class CarePlanService {
  final Logger _logger = Logger();
  List<CarePlanModel>? _cache;

  /// Carrega o JSON de hortaliças (apenas uma vez, depois usa cache).
  Future<List<CarePlanModel>> loadAll() async {
    if (_cache != null) return _cache!;
    try {
      final raw = await rootBundle.loadString('assets/data/vegetables.json');
      final list = (json.decode(raw) as List<dynamic>)
          .map((e) => CarePlanModel.fromJson(e as Map<String, dynamic>))
          .toList();
      _cache = list;
      return list;
    } catch (e) {
      _logger.e('Erro ao carregar planos de cuidados', error: e);
      return [];
    }
  }

  /// Retorna o plano pelo id, ou null se não existir.
  Future<CarePlanModel?> findById(String id) async {
    final all = await loadAll();
    try {
      return all.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
