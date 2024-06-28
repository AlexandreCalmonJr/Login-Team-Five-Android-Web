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

  Future<void> createUserProfile(User user, Map<String, dynamic> data) {
    return _firestore.collection('users').doc(user.uid).set(data);
  }

  Future<void> updateUserProfile(User user, Map<String, dynamic> data) {
    return _firestore.collection('users').doc(user.uid).update(data);
  }

  Future<String> uploadImage(Uint8List fileBytes, String fileName) async {
    String contentType = 'image/${fileName.split('.').last}';
    Reference ref = _storage.ref().child('user_images').child(fileName);
    UploadTask uploadTask = ref.putData(fileBytes, SettableMetadata(contentType: contentType));
    TaskSnapshot snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> deleteImage(String imageUrl) async {
    Reference ref = _storage.refFromURL(imageUrl);
    await ref.delete();
  }
}
