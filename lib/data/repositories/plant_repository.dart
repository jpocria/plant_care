import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../models/plant_model.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/storage_service.dart';

class PlantRepository extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final StorageService _storageService;

  PlantRepository(this._firestoreService, this._storageService);

  static const String _collection = 'plants';

  final List<PlantModel> _plants = [];
  bool isLoading = false;
  String? error;

  List<PlantModel> get plants => List.unmodifiable(_plants);
  int get healthyCount =>
      _plants.where((plant) => plant.calculatedStatus == PlantStatus.healthy).length;
  int get needsAttentionCount =>
      _plants.where((plant) => plant.calculatedStatus != PlantStatus.healthy).length;

  PlantModel? findPlantById(String plantId) {
    try {
      return _plants.firstWhere((plant) => plant.id == plantId);
    } catch (_) {
      return null;
    }
  }

  Future<void> loadPlants() async {
    if (isLoading) return;
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      _plants.clear();
      _plants.addAll(
        await getPlantsByUser(_firestoreService.currentUserId),
      );
    } catch (e) {
      error = e.toString();
      debugPrint('Erro ao carregar plantas: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Fetch ─────────────────────────────────────────────────────────────────

  Future<List<PlantModel>> getPlantsByUser(String userId) async {
    try {
      final docs = await _firestoreService.getCollection(
        collection: _collection,
        filters: [['userId', '==', userId]],
      );
      return docs.map((d) => PlantModel.fromFirestore(d)).toList();
    } catch (e) {
      debugPrint('Erro ao buscar plantas: $e');
      rethrow;
    }
  }

  Future<PlantModel?> fetchPlantById(String plantId) async {
    try {
      final doc = await _firestoreService.getDocument(
        collection: _collection,
        docId: plantId,
      );
      if (doc == null || !doc.exists) return null;
      return PlantModel.fromFirestore(doc);
    } catch (e) {
      debugPrint('Erro ao buscar planta $plantId: $e');
      rethrow;
    }
  }

  // ── Create ────────────────────────────────────────────────────────────────

  Future<bool> addPlant({
    required String name,
    required PlantType type,
    String? description,
    required double targetHumidity,
    required double targetTemperature,
    required int wateringFrequencyDays,
    String? location,
    String? vegetableId,
    XFile? imageFile,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final userId = _firestoreService.currentUserId;
      final now = DateTime.now();
      final nextWatering = now.add(Duration(days: wateringFrequencyDays));

      final data = {
        'userId': userId,
        'name': name.trim(),
        'type': type.name,
        'description': description?.trim(),
        'location': location?.trim(),
        'targetHumidity': targetHumidity,
        'targetTemperature': targetTemperature,
        'wateringFrequencyDays': wateringFrequencyDays,
        'vegetableId': vegetableId,
        'lastWatered': null,
        'nextWatering': Timestamp.fromDate(nextWatering),
        'status': PlantStatus.healthy.name,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      }..removeWhere((key, value) => value == null);

      final plantId = await _firestoreService.addDocument(
        collection: _collection,
        data: data,
      );

      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _storageService.uploadPlantImage(
          plantId: plantId,
          imageFile: imageFile,
        );
        await _firestoreService.updateDocument(
          collection: _collection,
          docId: plantId,
          data: {'imageUrl': imageUrl},
        );
      }

      final created = PlantModel(
        id: plantId,
        userId: userId,
        name: name.trim(),
        type: type,
        description: description?.trim(),
        imageUrl: imageUrl,
        targetHumidity: targetHumidity,
        targetTemperature: targetTemperature,
        wateringFrequencyDays: wateringFrequencyDays,
        location: location?.trim(),
        vegetableId: vegetableId,
        nextWatering: nextWatering,
        createdAt: now,
        updatedAt: now,
      );

      _plants.insert(0, created);
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      debugPrint('Erro ao adicionar planta: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ── Update ────────────────────────────────────────────────────────────────

  Future<bool> updatePlant({
    required String plantId,
    required Map<String, dynamic> updates,
    XFile? newImageFile,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      if (newImageFile != null) {
        updates['imageUrl'] = await _storageService.uploadPlantImage(
          plantId: plantId,
          imageFile: newImageFile,
        );
      }
      updates['updatedAt'] = Timestamp.fromDate(DateTime.now());

      await _firestoreService.updateDocument(
        collection: _collection,
        docId: plantId,
        data: updates,
      );

      final index = _plants.indexWhere((plant) => plant.id == plantId);
      if (index != -1) {
        final old = _plants[index];
        _plants[index] = old.copyWith(
          name: updates['name'] as String?,
          type: _plantTypeFromString(updates['type'] as String?),
          description: updates['description'] as String?,
          location: updates['location'] as String?,
          targetHumidity: updates['targetHumidity'] as double?,
          targetTemperature: updates['targetTemperature'] as double?,
          wateringFrequencyDays: updates['wateringFrequencyDays'] as int?,
          imageUrl: updates['imageUrl'] as String?,
          vegetableId: updates['vegetableId'] as String?,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      debugPrint('Erro ao atualizar planta $plantId: $e');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  PlantType _plantTypeFromString(String? value) {
    if (value == null) return PlantType.other;
    return PlantType.values.firstWhere(
      (type) => type.name == value,
      orElse: () => PlantType.other,
    );
  }

  /// Registra uma rega: atualiza lastWatered, recalcula nextWatering e salva no histórico.
  Future<bool> waterPlant(String plantId) async {
    try {
      final plant = await fetchPlantById(plantId);
      if (plant == null) return false;

      final now = DateTime.now();
      final nextWatering = now.add(Duration(days: plant.wateringFrequencyDays));

      await _firestoreService.updateDocument(
        collection: _collection,
        docId: plantId,
        data: {
          'lastWatered': Timestamp.fromDate(now),
          'nextWatering': Timestamp.fromDate(nextWatering),
          'updatedAt': Timestamp.fromDate(now),
        },
      );

      // Salva no histórico de regas
      await _firestoreService.db
          .collection(_collection)
          .doc(plantId)
          .collection('watering_history')
          .add({'wateredAt': Timestamp.fromDate(now)});

      final index = _plants.indexWhere((item) => item.id == plantId);
      if (index != -1) {
        _plants[index] = _plants[index].copyWith(
          lastWatered: now,
          nextWatering: nextWatering,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Erro ao regar planta $plantId: $e');
      return false;
    }
  }

  /// Retorna o histórico de regas de uma planta, do mais recente ao mais antigo.
  Future<List<DateTime>> getWateringHistory(String plantId) async {
    try {
      final snap = await _firestoreService.db
          .collection(_collection)
          .doc(plantId)
          .collection('watering_history')
          .orderBy('wateredAt', descending: true)
          .get();
      return snap.docs
          .map((d) => (d['wateredAt'] as Timestamp).toDate())
          .toList();
    } catch (e) {
      debugPrint('Erro ao buscar histórico de regas: $e');
      return [];
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  Future<bool> deletePlant(String plantId) async {
    try {
      await _firestoreService.deleteDocument(
        collection: _collection,
        docId: plantId,
      );
      _plants.removeWhere((plant) => plant.id == plantId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Erro ao deletar planta $plantId: $e');
      return false;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Verifica se o usuário já possui uma planta com o mesmo nome.
  Future<bool> plantNameExists({
    required String userId,
    required String name,
    String? excludeId,
  }) async {
    try {
      final docs = await _firestoreService.getCollection(
        collection: _collection,
        filters: [
          ['userId', '==', userId],
          ['name', '==', name.trim()],
        ],
      );
      if (docs.isEmpty) return false;
      if (excludeId == null) return true;
      return docs.any((d) => d.id != excludeId);
    } catch (e) {
      debugPrint('Erro ao verificar nome da planta: $e');
      return false;
    }
  }
}