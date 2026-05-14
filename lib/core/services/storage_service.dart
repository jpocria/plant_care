import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  final Logger _logger = Logger();
  final Uuid _uuid = const Uuid();

  static const List<String> _allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];
  static const int _maxFileSizeBytes = 5 * 1024 * 1024;

  String get _currentUserId {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Usuário não autenticado');
    return uid;
  }

  Future<XFile?> pickImage({
    required ImageSource source,
    int maxWidth = 1024,
    int maxHeight = 1024,
    int quality = 85,
  }) async {
    try {
      return await _picker.pickImage(
        source: source,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: quality,
      );
    } catch (e) {
      _logger.e('Erro ao selecionar imagem', error: e);
      rethrow;
    }
  }

  Future<String> uploadPlantImage({
    required String plantId,
    required XFile imageFile,
  }) async {
    final extension = _extractExtension(imageFile.name);
    _validateExtension(extension);
    final rawBytes = await imageFile.readAsBytes();
    final bytes = Uint8List.fromList(rawBytes);
    _validateFileSize(bytes.length);

    try {
      final fileName = '${_uuid.v4()}.$extension';
      final ref = _storage.ref('users/$_currentUserId/plants/$plantId/$fileName');
      final metadata = SettableMetadata(
        contentType: 'image/$extension',
        customMetadata: {'uploadedBy': _currentUserId, 'plantId': plantId},
      );
      final snapshot = await ref.putData(bytes, metadata);
      final url = await snapshot.ref.getDownloadURL();
      _logger.i('Imagem da planta enviada: $url');
      return url;
    } catch (e) {
      _logger.e('Erro ao enviar imagem da planta', error: e);
      rethrow;
    }
  }

  /// Aceita [File] (dart:io) ou [XFile] (image_picker).
  Future<String> uploadProfileImage({
    required String uid,
    File? file,
    XFile? xFile,
  }) async {
    assert(file != null || xFile != null, 'Forneça file ou xFile');

    final String fileName;
    final Uint8List bytes;

    if (xFile != null) {
      fileName = xFile.name;
      bytes = Uint8List.fromList(await xFile.readAsBytes());
    } else {
      fileName = file!.path.split(Platform.pathSeparator).last;
      bytes = await file.readAsBytes();
    }

    final extension = _extractExtension(fileName);
    _validateExtension(extension);
    _validateFileSize(bytes.length);

    try {
      final ref = _storage.ref('users/$uid/profile/avatar.$extension');
      final metadata = SettableMetadata(
        contentType: 'image/$extension',
        customMetadata: {'uploadedBy': uid},
      );
      final snapshot = await ref.putData(bytes, metadata);
      final url = await snapshot.ref.getDownloadURL();
      _logger.i('Foto de perfil enviada: $url');
      return url;
    } catch (e) {
      _logger.e('Erro ao enviar foto de perfil', error: e);
      rethrow;
    }
  }

  Future<void> deleteFile(String downloadUrl) async {
    try {
      await _storage.refFromURL(downloadUrl).delete();
    } catch (e) {
      _logger.e('Erro ao deletar arquivo', error: e);
      rethrow;
    }
  }

  Future<void> deletePlantImages(String plantId) async {
    try {
      final ref = _storage.ref('users/$_currentUserId/plants/$plantId');
      final list = await ref.listAll();
      await Future.wait(list.items.map((i) => i.delete()));
    } catch (e) {
      _logger.e('Erro ao deletar imagens da planta', error: e);
      rethrow;
    }
  }

  String _extractExtension(String fileName) {
    final parts = fileName.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : 'jpg';
  }

  void _validateExtension(String ext) {
    if (!_allowedExtensions.contains(ext)) {
      throw Exception('Tipo não permitido. Use JPG, PNG ou WebP.');
    }
  }

  void _validateFileSize(int size) {
    if (size > _maxFileSizeBytes) {
      throw Exception('Arquivo maior que ${_maxFileSizeBytes ~/ (1024 * 1024)} MB.');
    }
  }
}