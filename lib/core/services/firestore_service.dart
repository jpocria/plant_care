import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger();

  FirebaseFirestore get db => _db;

  CollectionReference get usersCollection => _db.collection('users');
  CollectionReference get plantsCollection => _db.collection('plants');
  CollectionReference get alertsCollection => _db.collection('alerts');
  CollectionReference get sensorDataCollection => _db.collection('sensor_data');

  String get currentUserId {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Usuário não autenticado');
    return uid;
  }

  Future<void> setDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
    bool merge = true,
  }) async {
    try {
      await _db.collection(collection).doc(docId).set(
        {...data, 'updatedAt': FieldValue.serverTimestamp()},
        SetOptions(merge: merge),
      );
    } catch (e) {
      _logger.e('Erro ao salvar documento', error: e);
      rethrow;
    }
  }

  Future<String> addDocument({
    required String collection,
    required Map<String, dynamic> data,
  }) async {
    try {
      final reference = await _db.collection(collection).add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return reference.id;
    } catch (e) {
      _logger.e('Erro ao adicionar documento', error: e);
      rethrow;
    }
  }

  Future<List<QueryDocumentSnapshot>> getCollection({
    required String collection,
    List<List<dynamic>>? filters,
    String? orderBy,
    bool descending = true,
    int? limit,
  }) async {
    Query query = _db.collection(collection);

    if (filters != null) {
      for (final filter in filters) {
        final field = filter[0] as String;
        final operator = filter[1] as String;
        final value = filter[2];

        switch (operator) {
          case '==':
            query = query.where(field, isEqualTo: value);
            break;
          case '<':
            query = query.where(field, isLessThan: value);
            break;
          case '<=':
            query = query.where(field, isLessThanOrEqualTo: value);
            break;
          case '>':
            query = query.where(field, isGreaterThan: value);
            break;
          case '>=':
            query = query.where(field, isGreaterThanOrEqualTo: value);
            break;
          default:
            throw ArgumentError('Operador de filtro não suportado: $operator');
        }
      }
    }

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs;
  }

  Future<DocumentSnapshot?> getDocument({
    required String collection,
    required String docId,
  }) async {
    try {
      final doc = await _db.collection(collection).doc(docId).get();
      return doc.exists ? doc : null;
    } catch (e) {
      _logger.e('Erro ao buscar documento', error: e);
      rethrow;
    }
  }

  Future<void> updateDocument({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _db.collection(collection).doc(docId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _logger.e('Erro ao atualizar documento', error: e);
      rethrow;
    }
  }

  Future<void> deleteDocument({
    required String collection,
    required String docId,
  }) async {
    try {
      await _db.collection(collection).doc(docId).delete();
    } catch (e) {
      _logger.e('Erro ao deletar documento', error: e);
      rethrow;
    }
  }

  Stream<QuerySnapshot> streamUserDocuments({
    required String collection,
    String? orderBy,
    bool descending = true,
    int? limit,
  }) {
    Query query = _db
        .collection(collection)
        .where('userId', isEqualTo: currentUserId);

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }
    if (limit != null) {
      query = query.limit(limit);
    }
    return query.snapshots();
  }

  Future<void> runBatch(void Function(WriteBatch batch) operations) async {
    final batch = _db.batch();
    operations(batch);
    await batch.commit();
  }

  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) handler,
  ) async {
    return await _db.runTransaction(handler);
  }
}