import 'package:cloud_firestore/cloud_firestore.dart';

enum AlertType {
  water('💧', 'Precisa de água'),
  humidity('🌡️', 'Umidade baixa'),
  temperature('🔥', 'Temperatura'),
  disease('🍂', 'Doença detectada'),
  sensor('📡', 'Sensor'),
  general('📢', 'Aviso geral');

  final String emoji;
  final String label;
  const AlertType(this.emoji, this.label);
}

enum AlertSeverity { low, medium, high, critical }

class AlertModel {
  final String id;
  final String userId;
  final String plantId;
  final String plantName;
  final AlertType type;
  final AlertSeverity severity;
  final String message;
  final bool isRead;
  final bool isResolved;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  AlertModel({
    required this.id,
    required this.userId,
    required this.plantId,
    required this.plantName,
    required this.type,
    required this.severity,
    required this.message,
    this.isRead = false,
    this.isResolved = false,
    required this.createdAt,
    this.resolvedAt,
  });

  factory AlertModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AlertModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      plantId: data['plantId'] as String? ?? '',
      plantName: data['plantName'] as String? ?? '',
      type: AlertType.values.firstWhere(
        (e) => e.name == (data['type'] as String?),
        orElse: () => AlertType.general,
      ),
      severity: AlertSeverity.values.firstWhere(
        (e) => e.name == (data['severity'] as String?),
        orElse: () => AlertSeverity.low,
      ),
      message: data['message'] as String? ?? '',
      isRead: data['isRead'] as bool? ?? false,
      isResolved: data['isResolved'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      resolvedAt: (data['resolvedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'plantId': plantId,
      'plantName': plantName,
      'type': type.name,
      'severity': severity.name,
      'message': message,
      'isRead': isRead,
      'isResolved': isResolved,
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
    };
  }

  AlertModel copyWith({
    bool? isRead,
    bool? isResolved,
    DateTime? resolvedAt,
  }) {
    return AlertModel(
      id: id,
      userId: userId,
      plantId: plantId,
      plantName: plantName,
      type: type,
      severity: severity,
      message: message,
      isRead: isRead ?? this.isRead,
      isResolved: isResolved ?? this.isResolved,
      createdAt: createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}