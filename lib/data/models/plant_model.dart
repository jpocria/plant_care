import 'package:cloud_firestore/cloud_firestore.dart';

enum PlantStatus { healthy, needsWater, needsAttention, critical }

enum PlantType {
  vegetable('Verdura/Legume'),
  fruit('Fruta'),
  herb('Erva aromática'),
  flower('Flor'),
  succulent('Suculenta/Cacto'),
  tree('Árvore'),
  other('Outro');

  final String label;
  const PlantType(this.label);
}

class PlantModel {
  final String id;
  final String userId;
  final String name;
  final PlantType type;
  final String? description;
  final String? imageUrl;
  final double targetHumidity;
  final double targetTemperature;
  final int wateringFrequencyDays;
  final DateTime? lastWatered;
  final DateTime? nextWatering;
  final PlantStatus status;
  final double? currentHumidity;
  final double? currentTemperature;
  final String? location;
  final Map<String, dynamic>? sensorConfig;
  final String? vegetableId; // id da hortaliça base (care plan)
  final DateTime createdAt;
  final DateTime updatedAt;

  PlantModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    this.description,
    this.imageUrl,
    this.targetHumidity = 60.0,
    this.targetTemperature = 22.0,
    this.wateringFrequencyDays = 3,
    this.lastWatered,
    this.nextWatering,
    this.status = PlantStatus.healthy,
    this.currentHumidity,
    this.currentTemperature,
    this.location,
    this.sensorConfig,
    this.vegetableId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlantModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PlantModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      name: data['name'] as String? ?? 'Planta sem nome',
      type: PlantType.values.firstWhere(
        (e) => e.name == (data['type'] as String?),
        orElse: () => PlantType.other,
      ),
      description: data['description'] as String?,
      imageUrl: data['imageUrl'] as String?,
      targetHumidity: (data['targetHumidity'] as num?)?.toDouble() ?? 60.0,
      targetTemperature: (data['targetTemperature'] as num?)?.toDouble() ?? 22.0,
      wateringFrequencyDays: data['wateringFrequencyDays'] as int? ?? 3,
      lastWatered: (data['lastWatered'] as Timestamp?)?.toDate(),
      nextWatering: (data['nextWatering'] as Timestamp?)?.toDate(),
      status: PlantStatus.values.firstWhere(
        (e) => e.name == (data['status'] as String?),
        orElse: () => PlantStatus.healthy,
      ),
      currentHumidity: (data['currentHumidity'] as num?)?.toDouble(),
      currentTemperature: (data['currentTemperature'] as num?)?.toDouble(),
      location: data['location'] as String?,
      sensorConfig: data['sensorConfig'] as Map<String, dynamic>?,
      vegetableId: data['vegetableId'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name.trim(),
      'type': type.name,
      'description': description?.trim(),
      'imageUrl': imageUrl,
      'targetHumidity': targetHumidity,
      'targetTemperature': targetTemperature,
      'wateringFrequencyDays': wateringFrequencyDays,
      'lastWatered': lastWatered != null ? Timestamp.fromDate(lastWatered!) : null,
      'nextWatering': nextWatering != null ? Timestamp.fromDate(nextWatering!) : null,
      'status': status.name,
      'currentHumidity': currentHumidity,
      'currentTemperature': currentTemperature,
      'location': location?.trim(),
      'sensorConfig': sensorConfig,
      'vegetableId': vegetableId,
    };
  }

  PlantModel copyWith({
    String? name,
    PlantType? type,
    String? description,
    String? imageUrl,
    double? targetHumidity,
    double? targetTemperature,
    int? wateringFrequencyDays,
    DateTime? lastWatered,
    DateTime? nextWatering,
    PlantStatus? status,
    double? currentHumidity,
    double? currentTemperature,
    String? location,
    Map<String, dynamic>? sensorConfig,
    String? vegetableId,
  }) {
    return PlantModel(
      id: id,
      userId: userId,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      targetHumidity: targetHumidity ?? this.targetHumidity,
      targetTemperature: targetTemperature ?? this.targetTemperature,
      wateringFrequencyDays: wateringFrequencyDays ?? this.wateringFrequencyDays,
      lastWatered: lastWatered ?? this.lastWatered,
      nextWatering: nextWatering ?? this.nextWatering,
      status: status ?? this.status,
      currentHumidity: currentHumidity ?? this.currentHumidity,
      currentTemperature: currentTemperature ?? this.currentTemperature,
      location: location ?? this.location,
      sensorConfig: sensorConfig ?? this.sensorConfig,
      vegetableId: vegetableId ?? this.vegetableId,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  bool get needsWatering {
    if (nextWatering == null) return false;
    return DateTime.now().isAfter(nextWatering!);
  }

  int get daysUntilWatering {
    if (nextWatering == null) return 0;
    return nextWatering!.difference(DateTime.now()).inDays;
  }

  PlantStatus get calculatedStatus {
    if (needsWatering) return PlantStatus.needsWater;
    if (currentHumidity != null && currentHumidity! < targetHumidity * 0.5) {
      return PlantStatus.critical;
    }
    if (currentHumidity != null && currentHumidity! < targetHumidity * 0.7) {
      return PlantStatus.needsAttention;
    }
    return PlantStatus.healthy;
  }
}