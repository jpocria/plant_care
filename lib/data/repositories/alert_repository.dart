import 'package:flutter/foundation.dart';
import '../models/alert_model.dart';
import '../../core/services/firestore_service.dart';

class AlertRepository extends ChangeNotifier {
  final FirestoreService _firestoreService;
  List<AlertModel> _alerts = [];
  bool _isLoading = false;

  AlertRepository(this._firestoreService) {
    _listenToAlerts();
  }

  List<AlertModel> get alerts => List.unmodifiable(_alerts);
  List<AlertModel> get unreadAlerts => _alerts.where((a) => !a.isRead).toList();
  List<AlertModel> get unresolvedAlerts =>
      _alerts.where((a) => !a.isResolved).toList();
  int get unreadCount => unreadAlerts.length;
  bool get isLoading => _isLoading;

  void _listenToAlerts() {
    try {
      _firestoreService
          .streamUserDocuments(
        collection: 'alerts',
        orderBy: 'createdAt',
        descending: true,
        limit: 50,
      )
          .listen(
        (snapshot) {
          _alerts = snapshot.docs
              .map((doc) => AlertModel.fromFirestore(doc))
              .toList();
          notifyListeners();
        },
        onError: (e) => debugPrint('Erro ao ouvir alertas: $e'),
      );
    } catch (_) {
      _alerts = [];
    }
  }

  Future<void> markAsRead(String alertId) async {
    try {
      await _firestoreService.updateDocument(
        collection: 'alerts',
        docId: alertId,
        data: {'isRead': true},
      );
    } catch (e) {
      debugPrint('Erro ao marcar como lido: $e');
    }
  }

  Future<void> markAllAsRead() async {
    final unread = _alerts.where((a) => !a.isRead).toList();
    if (unread.isEmpty) return;

    await _firestoreService.runBatch((batch) {
      for (final alert in unread) {
        final ref =
            _firestoreService.db.collection('alerts').doc(alert.id);
        batch.update(ref, {'isRead': true});
      }
    });
  }

  Future<void> resolveAlert(String alertId) async {
    try {
      await _firestoreService.updateDocument(
        collection: 'alerts',
        docId: alertId,
        data: {
          'isResolved': true,
          'isRead': true,
          'resolvedAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('Erro ao resolver alerta: $e');
    }
  }

  Future<void> deleteAlert(String alertId) async {
    try {
      final alert = _alerts.firstWhere((a) => a.id == alertId);
      if (alert.userId != _firestoreService.currentUserId) return;

      await _firestoreService.deleteDocument(
        collection: 'alerts',
        docId: alertId,
      );
    } catch (e) {
      debugPrint('Erro ao deletar alerta: $e');
    }
  }
}