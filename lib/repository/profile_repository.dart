import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

class ProfileRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<DocumentSnapshot> getUserProfile(User user) {
    return _firestore.collection('users').doc(user.uid).get();
  }

  Future<void> createUserProfile(User user, Map<String, dynamic> userProfile) {
    return _firestore.collection('users').doc(user.uid).set(userProfile);
  }

  Future<void> updateUserProfile(User user, Map<String, dynamic> userProfile) {
    return _firestore.collection('users').doc(user.uid).update(userProfile);
  }

  Future<String> uploadImage(Uint8List fileBytes, String fileName) async {
    // Determina o tipo MIME com base na extensão do arquivo
    String contentType;
    if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')) {
      contentType = 'image/jpeg';
    } else if (fileName.endsWith('.png')) {
      contentType = 'image/png';
    } else {
      throw Exception('Unsupported file type');
    }

    final storageRef = _storage.ref().child('user_images/$fileName');
    final uploadTask = storageRef.putData(
      fileBytes,
      SettableMetadata(contentType: contentType),
    );
    final snapshot = await uploadTask.whenComplete(() {});
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> deleteImage(String imageUrl) async {
    final ref = _storage.refFromURL(imageUrl);
    await ref.delete();
  }
}
