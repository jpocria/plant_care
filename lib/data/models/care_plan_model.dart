/// Modelo que representa o planejamento de cuidados completo de uma hortaliça.
class CarePlanModel {
  final String id;
  final String name;
  final String emoji;
  final String scientificName;
  final PlantingInfo planting;
  final WateringInfo watering;
  final List<String> fertilization;
  final List<String> pests;
  final HarvestInfo harvest;
  final EnvironmentInfo environment;
  final SoilInfo soil;
  final CalendarInfo calendar;

  const CarePlanModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.scientificName,
    required this.planting,
    required this.watering,
    required this.fertilization,
    required this.pests,
    required this.harvest,
    required this.environment,
    required this.soil,
    required this.calendar,
  });

  factory CarePlanModel.fromJson(Map<String, dynamic> json) {
    return CarePlanModel(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String? ?? '🌱',
      scientificName: json['scientificName'] as String? ?? '',
      planting: PlantingInfo.fromJson(
          json['planting'] as Map<String, dynamic>),
      watering: WateringInfo.fromJson(
          json['watering'] as Map<String, dynamic>),
      fertilization: (json['fertilization'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      pests:
          (json['pests'] as List<dynamic>).map((e) => e as String).toList(),
      harvest:
          HarvestInfo.fromJson(json['harvest'] as Map<String, dynamic>),
      environment: EnvironmentInfo.fromJson(
          json['environment'] as Map<String, dynamic>),
      soil: SoilInfo.fromJson(json['soil'] as Map<String, dynamic>),
      calendar: CalendarInfo.fromJson(
          json['calendar'] as Map<String, dynamic>),
    );
  }
}

class PlantingInfo {
  final String bestSeason;
  final String plantingMethod;
  final String spacing;
  final double depthCm;
  final String germinationDays;
  const PlantingInfo({
    required this.bestSeason,
    required this.plantingMethod,
    required this.spacing,
    required this.depthCm,
    required this.germinationDays,
  });
  factory PlantingInfo.fromJson(Map<String, dynamic> j) => PlantingInfo(
        bestSeason: j['bestSeason'] as String,
        plantingMethod: j['plantingMethod'] as String,
        spacing: j['spacing'] as String,
        depthCm: (j['depthCm'] as num).toDouble(),
        germinationDays: j['germinationDays'] as String,
      );
}

class WateringInfo {
  final int frequencyPerWeek;
  final int amountMl;
  final String bestTime;
  final String tip;
  const WateringInfo({
    required this.frequencyPerWeek,
    required this.amountMl,
    required this.bestTime,
    required this.tip,
  });
  factory WateringInfo.fromJson(Map<String, dynamic> j) => WateringInfo(
        frequencyPerWeek: j['frequencyPerWeek'] as int,
        amountMl: j['amountMl'] as int,
        bestTime: j['bestTime'] as String,
        tip: j['tip'] as String,
      );
}

class HarvestInfo {
  final int daysToHarvest;
  final String harvestMethod;
  final String indicators;
  const HarvestInfo({
    required this.daysToHarvest,
    required this.harvestMethod,
    required this.indicators,
  });
  factory HarvestInfo.fromJson(Map<String, dynamic> j) => HarvestInfo(
        daysToHarvest: j['daysToHarvest'] as int,
        harvestMethod: j['harvestMethod'] as String,
        indicators: j['indicators'] as String,
      );
}

class EnvironmentInfo {
  final String idealTemperatureC;
  final String humidity;
  final String lightHours;
  final String tolerates;
  const EnvironmentInfo({
    required this.idealTemperatureC,
    required this.humidity,
    required this.lightHours,
    required this.tolerates,
  });
  factory EnvironmentInfo.fromJson(Map<String, dynamic> j) => EnvironmentInfo(
        idealTemperatureC: j['idealTemperatureC'] as String,
        humidity: j['humidity'] as String,
        lightHours: j['lightHours'] as String,
        tolerates: j['tolerates'] as String,
      );
}

class SoilInfo {
  final String type;
  final String ph;
  final String preparation;
  const SoilInfo({required this.type, required this.ph, required this.preparation});
  factory SoilInfo.fromJson(Map<String, dynamic> j) => SoilInfo(
        type: j['type'] as String,
        ph: j['ph'] as String,
        preparation: j['preparation'] as String,
      );
}

class CalendarInfo {
  final List<int> sowingMonths;
  final List<int> harvestMonths;
  const CalendarInfo({required this.sowingMonths, required this.harvestMonths});
  factory CalendarInfo.fromJson(Map<String, dynamic> j) => CalendarInfo(
        sowingMonths: (j['sowingMonths'] as List<dynamic>).cast<int>(),
        harvestMonths: (j['harvestMonths'] as List<dynamic>).cast<int>(),
      );
}
