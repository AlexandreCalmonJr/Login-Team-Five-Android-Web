import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';

class ProfileRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  Future<DocumentSnapshot> getUserProfile(User user) async {
    return await _firestore.collection('users').doc(user.uid).get();
  }

  Future<void> createUserProfile(User user, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(user.uid).set(data);
  }

  Future<void> updateUserProfile(User user, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(user.uid).update(data);
  }

  Future<FilePickerResult?> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'], // Tipos de arquivos permitidos
    );
    return result;
  }

  Future<String> uploadImage(FilePickerResult pickedFile) async {
    if (kIsWeb) {
      // Para web, converte para Uint8List
      final bytes = pickedFile.files.single.bytes!;
      final blob = Uint8List.fromList(bytes);

      final ref = _storage.ref('profile_images/${_auth.currentUser!.uid}/${DateTime.now().toString()}.jpeg');
      final uploadTask = ref.putData(blob);

      try {
        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();
        return downloadUrl;
      } catch (e) {
        print('Erro ao fazer upload da imagem: $e');
        throw e;
      }
    } else {
      // Para outras plataformas (mobile), continuar usando putFile
      final file = File(pickedFile.files.single.path!);
      final ref = _storage.ref('profile_images/${_auth.currentUser!.uid}/${DateTime.now().toString()}.jpeg');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    }
  }

  Future<bool> checkImageUrlValidity(String? url) async {
    if (url == null || url.isEmpty) {
      return false;
    }
    try {
      final uri = Uri.parse(url);
      final request = await HttpClient().getUrl(uri);
      final response = await request.close();
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
