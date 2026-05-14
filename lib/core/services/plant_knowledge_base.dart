import 'package:plant_care/data/models/sensor_reading.dart';
import 'package:plant_care/data/models/plant_model.dart';

/// Informações de cuidado de uma planta específica
class PlantCareInfo {
  final String commonName;
  final String scientificName;
  final String plantType; // indoor, outdoor, herb, vegetable, etc
  
  /// Frequência de rega em dias
  final int wateringFrequencyDays;
  
  /// Range de temperatura ideal em Celsius
  final NumericRange temperatureRange;
  
  /// Range de umidade do ar ideal (%)
  final NumericRange humidityRange;
  
  /// Range de luminosidade ideal (lux)
  final NumericRange lightRange;
  
  /// Range de umidade do solo ideal (%)
  final NumericRange soilMoistureRange;
  
  /// Nível de dificuldade: beginner, intermediate, advanced
  final String difficulty;
  
  /// Altura mínima da planta em cm
  final int minHeight;
  
  /// Altura máxima da planta em cm
  final int maxHeight;
  
  /// Descrição curta de cuidados
  final String careDescription;
  
  /// Problemas comuns e como lidar
  final Map<String, String> commonIssues;

  const PlantCareInfo({
    required this.commonName,
    required this.scientificName,
    required this.plantType,
    required this.wateringFrequencyDays,
    required this.temperatureRange,
    required this.humidityRange,
    required this.lightRange,
    required this.soilMoistureRange,
    required this.difficulty,
    required this.minHeight,
    required this.maxHeight,
    required this.careDescription,
    required this.commonIssues,
  });

  /// Recomendação baseada em uma leitura de sensor
  String getRecommendation(SensorReading reading) {
    final List<String> recommendations = [];

    if (!temperatureRange.isInRange(reading.temperature)) {
      if (reading.temperature < temperatureRange.min) {
        recommendations.add(
          'Temperatura muito baixa (${reading.temperature.toStringAsFixed(1)}°C). '
          'Ideal: ${temperatureRange.min.toStringAsFixed(1)}-${temperatureRange.max.toStringAsFixed(1)}°C. '
          'Mova para local mais quente.',
        );
      } else {
        recommendations.add(
          'Temperatura muito alta (${reading.temperature.toStringAsFixed(1)}°C). '
          'Ideal: ${temperatureRange.min.toStringAsFixed(1)}-${temperatureRange.max.toStringAsFixed(1)}°C. '
          'Mova para local mais fresco.',
        );
      }
    }

    if (!humidityRange.isInRange(reading.humidity)) {
      if (reading.humidity < humidityRange.min) {
        recommendations.add(
          'Umidade muito baixa (${reading.humidity.toStringAsFixed(1)}%). '
          'Ideal: ${humidityRange.min.toStringAsFixed(1)}-${humidityRange.max.toStringAsFixed(1)}%. '
          'Coloque um umidificador ou pulverize a folhagem.',
        );
      } else {
        recommendations.add(
          'Umidade muito alta (${reading.humidity.toStringAsFixed(1)}%). '
          'Risco de mofo. Melhore ventilação.',
        );
      }
    }

    if (!lightRange.isInRange(reading.light.toDouble())) {
      if (reading.light < lightRange.min) {
        recommendations.add(
          'Luminosidade muito baixa (${reading.light} lux). '
          'Ideal: ${lightRange.min.toInt()}-${lightRange.max.toInt()} lux. '
          'Mude para perto de uma janela ou use luz artificial.',
        );
      }
    }

    if (!soilMoistureRange.isInRange(reading.soilMoisture.toDouble())) {
      if (reading.soilMoisture < soilMoistureRange.min) {
        recommendations.add(
          'Solo muito seco (${reading.soilMoisture}%). '
          'Regue com urgência para evitar murcha.',
        );
      } else {
        recommendations.add(
          'Solo muito úmido (${reading.soilMoisture}%). '
          'Risco de apodrecimento de raízes. Deixe secar um pouco.',
        );
      }
    }

    return recommendations.isEmpty
        ? '✅ Tudo ótimo! Continue com os cuidados atuais.'
        : recommendations.join('\n');
  }
}

/// Base de conhecimento com informações de plantas
class PlantKnowledgeBase {
  static const Map<String, PlantCareInfo> _plants = {
    'cebolinha': PlantCareInfo(
      commonName: 'Cebolinha',
      scientificName: 'Allium schoenoprasum',
      plantType: 'herb',
      wateringFrequencyDays: 2,
      temperatureRange: NumericRange(min: 15, max: 25),
      humidityRange: NumericRange(min: 40, max: 65),
      lightRange: NumericRange(min: 200, max: 800),
      soilMoistureRange: NumericRange(min: 40, max: 70),
      difficulty: 'beginner',
      minHeight: 15,
      maxHeight: 40,
      careDescription: 'Erva aromática fácil de cultivar. Gosta de luz abundante e solo úmido.',
      commonIssues: {
        'Folhas amareladas': 'Reduza a frequência de rega',
        'Crescimento lento': 'Aumente a exposição à luz',
        'Mofo na base': 'Melhore circulação de ar',
      },
    ),
    'tomate': PlantCareInfo(
      commonName: 'Tomate',
      scientificName: 'Solanum lycopersicum',
      plantType: 'vegetable',
      wateringFrequencyDays: 3,
      temperatureRange: NumericRange(min: 18, max: 28),
      humidityRange: NumericRange(min: 50, max: 75),
      lightRange: NumericRange(min: 500, max: 2000),
      soilMoistureRange: NumericRange(min: 50, max: 75),
      difficulty: 'intermediate',
      minHeight: 40,
      maxHeight: 200,
      careDescription: 'Requer muita luz solar e solo rico. Suporte para crescimento vertical.',
      commonIssues: {
        'Frutos com manchas': 'Aumentar umidade e evitar molhar folhas',
        'Crescimento fraco': 'Aumentar exposição solar',
        'Nenhum fruto': 'Pode ser falta de polinização, agite suavemente as flores',
      },
    ),
    'suculenta': PlantCareInfo(
      commonName: 'Suculenta',
      scientificName: 'Echeveria sp.',
      plantType: 'indoor',
      wateringFrequencyDays: 14,
      temperatureRange: NumericRange(min: 15, max: 27),
      humidityRange: NumericRange(min: 20, max: 40),
      lightRange: NumericRange(min: 300, max: 5000),
      soilMoistureRange: NumericRange(min: 10, max: 30),
      difficulty: 'beginner',
      minHeight: 5,
      maxHeight: 30,
      careDescription: 'Planta resistente. Prefere seco. Pouca rega e muita luz.',
      commonIssues: {
        'Folhas blandas': 'Excesso de água, reduza rega',
        'Estiolamento': 'Pouca luz, mude para local mais iluminado',
        'Apodrecimento': 'Solo muito úmido, mude para solo bem drenado',
      },
    ),
    'pothos': PlantCareInfo(
      commonName: 'Pothos',
      scientificName: 'Epipremnum aureum',
      plantType: 'indoor',
      wateringFrequencyDays: 4,
      temperatureRange: NumericRange(min: 15, max: 30),
      humidityRange: NumericRange(min: 50, max: 75),
      lightRange: NumericRange(min: 100, max: 1000),
      soilMoistureRange: NumericRange(min: 40, max: 65),
      difficulty: 'beginner',
      minHeight: 20,
      maxHeight: 300,
      careDescription: 'Planta muito resistente. Tolera baixa luz. Ótima para iniciantes.',
      commonIssues: {
        'Folhas amarelas': 'Possível excesso de rega',
        'Crescimento lento': 'Aumente frequência de adubação',
        'Folhas pequenas': 'Ofereça mais luz indireta',
      },
    ),
    'rosa': PlantCareInfo(
      commonName: 'Rosa',
      scientificName: 'Rosa sp.',
      plantType: 'outdoor',
      wateringFrequencyDays: 2,
      temperatureRange: NumericRange(min: 15, max: 25),
      humidityRange: NumericRange(min: 50, max: 70),
      lightRange: NumericRange(min: 800, max: 3000),
      soilMoistureRange: NumericRange(min: 50, max: 75),
      difficulty: 'intermediate',
      minHeight: 30,
      maxHeight: 300,
      careDescription: 'Flor clássica. Requer muita luz, solo fértil e boa drenagem.',
      commonIssues: {
        'Pulgões': 'Pulverize com água com sabão',
        'Mofo cinzento': 'Melhore ventilação e reduza rega',
        'Sem floração': 'Certifique-se de luz suficiente (6+ horas)',
      },
    ),
    'orquidea': PlantCareInfo(
      commonName: 'Orquídea',
      scientificName: 'Orchidaceae',
      plantType: 'indoor',
      wateringFrequencyDays: 7,
      temperatureRange: NumericRange(min: 18, max: 28),
      humidityRange: NumericRange(min: 60, max: 80),
      lightRange: NumericRange(min: 200, max: 1000),
      soilMoistureRange: NumericRange(min: 20, max: 50),
      difficulty: 'advanced',
      minHeight: 20,
      maxHeight: 100,
      careDescription: 'Flor elegante. Requer umidade alta e ar circulando. Substrato especial.',
      commonIssues: {
        'Sem flores': 'Pode precisar de período de dormência ou mais luz',
        'Raízes apodrecidas': 'Reduza rega, mude para substrato bem drenado',
        'Folhas enrugadas': 'Aumente umidade',
      },
    ),
    'espada-de-sao-jorge': PlantCareInfo(
      commonName: 'Espada-de-São-Jorge',
      scientificName: 'Sansevieria trifasciata',
      plantType: 'indoor',
      wateringFrequencyDays: 10,
      temperatureRange: NumericRange(min: 13, max: 27),
      humidityRange: NumericRange(min: 30, max: 50),
      lightRange: NumericRange(min: 50, max: 2000),
      soilMoistureRange: NumericRange(min: 10, max: 30),
      difficulty: 'beginner',
      minHeight: 20,
      maxHeight: 100,
      careDescription: 'Planta muito resistente. Tolera baixa luz e pouca água. Ideal para descuido.',
      commonIssues: {
        'Podridão': 'Excesso de água, reduza rega drasticamente',
        'Crescimento lento': 'Normal, é uma planta de crescimento lento',
      },
    ),
    'coloeus': PlantCareInfo(
      commonName: 'Coleus',
      scientificName: 'Plectranthus scutellarioides',
      plantType: 'indoor',
      wateringFrequencyDays: 2,
      temperatureRange: NumericRange(min: 18, max: 28),
      humidityRange: NumericRange(min: 50, max: 70),
      lightRange: NumericRange(min: 300, max: 1500),
      soilMoistureRange: NumericRange(min: 50, max: 75),
      difficulty: 'beginner',
      minHeight: 20,
      maxHeight: 80,
      careDescription: 'Planta colorida. Gosta de umidade e luz. Belíssima por suas cores.',
      commonIssues: {
        'Cores pálidas': 'Aumente exposição à luz',
        'Crescimento fraco': 'Aumente frequência de adubação',
      },
    ),
    'bambu-da-sorte': PlantCareInfo(
      commonName: 'Bambu-da-Sorte',
      scientificName: 'Dracaena sanderiana',
      plantType: 'indoor',
      wateringFrequencyDays: 3,
      temperatureRange: NumericRange(min: 18, max: 28),
      humidityRange: NumericRange(min: 50, max: 75),
      lightRange: NumericRange(min: 100, max: 1000),
      soilMoistureRange: NumericRange(min: 40, max: 65),
      difficulty: 'beginner',
      minHeight: 20,
      maxHeight: 150,
      careDescription: 'Símbolo de sorte e prosperidade. Fácil de cuidar. Pode crescer em água.',
      commonIssues: {
        'Água com cloro': 'Use água filtrada ou deixe repouso 24h',
        'Folhas marrons': 'Pode ser cloro ou seca demais',
      },
    ),
    'manjericao': PlantCareInfo(
      commonName: 'Manjericão',
      scientificName: 'Ocimum basilicum',
      plantType: 'herb',
      wateringFrequencyDays: 2,
      temperatureRange: NumericRange(min: 20, max: 28),
      humidityRange: NumericRange(min: 50, max: 70),
      lightRange: NumericRange(min: 600, max: 2000),
      soilMoistureRange: NumericRange(min: 50, max: 70),
      difficulty: 'beginner',
      minHeight: 20,
      maxHeight: 60,
      careDescription: 'Erva aromática. Gosta de calor e luz. Ótimo para culinária.',
      commonIssues: {
        'Hastes longas': 'Pode podar para induzir crescimento mais frondoso',
        'Floração': 'Remova flores para manter folhas tenras',
      },
    ),
  };

  /// Obtém informações de uma planta pelo tipo (PlantType enum)
  PlantCareInfo? getPlantInfoByType(PlantType plantType) {
    // Mapeia PlantType para chave de lookup na base de conhecimento
    const Map<PlantType, String> typeMap = {
      PlantType.vegetable: 'tomate',
      PlantType.fruit: 'tomate',
      PlantType.herb: 'cebolinha',
      PlantType.flower: 'rosa',
      PlantType.succulent: 'suculenta',
      PlantType.tree: 'bambu-da-sorte',
      PlantType.other: 'pothos',
    };

    final key = typeMap[plantType];
    return key != null ? _plants[key] : null;
  }

  /// Obtém informações de uma planta pelo ID (lowercase)
  PlantCareInfo? getPlantInfo(String plantId) {
    return _plants[plantId.toLowerCase()];
  }

  /// Lista todos os IDs de plantas disponíveis
  List<String> getAvailablePlants() {
    return _plants.keys.toList();
  }

  /// Obtém info por nome comum
  PlantCareInfo? findByCommonName(String name) {
    for (final entry in _plants.entries) {
      if (entry.value.commonName.toLowerCase() == name.toLowerCase()) {
        return entry.value;
      }
    }
    return null;
  }

  /// Retorna lista de plantas fáceis para iniciantes
  List<PlantCareInfo> getBeginnerFriendly() {
    return _plants.values
        .where((plant) => plant.difficulty == 'beginner')
        .toList();
  }

  /// Retorna plantas por tipo
  List<PlantCareInfo> getByType(String type) {
    return _plants.values
        .where((plant) => plant.plantType == type)
        .toList();
  }

  /// Valida se uma leitura está segura para a planta
  bool isHealthy(SensorReading reading, String plantId) {
    final info = getPlantInfo(plantId);
    if (info == null) return true;

    return info.temperatureRange.isInRange(reading.temperature) &&
        info.humidityRange.isInRange(reading.humidity) &&
        info.lightRange.isInRange(reading.light.toDouble()) &&
        info.soilMoistureRange.isInRange(reading.soilMoisture.toDouble());
  }
}
