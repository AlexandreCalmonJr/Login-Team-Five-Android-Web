import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  Future<DocumentSnapshot> getUserProfile(User user) async {
    return _firestore.collection('users').doc(user.uid).get();
  }

  Future<void> createUserProfile(User user, Map<String, dynamic> data) async {
    return _firestore.collection('users').doc(user.uid).set(data);
  }
  Future<void> updateUserProfile(User user, Map<String, dynamic> data) async {
  return _firestore.collection('users').doc(user.uid).update(data);
}
  Future<String> uploadImage(Uint8List fileBytes) async {
  User? user = _auth.currentUser;
  if (user == null) {
    throw Exception('Usuário não está logado');
  }

  String filePath = 'profile_images/${user.uid}/${DateTime.now().toIso8601String()}.jpeg';
  Reference ref = _storage.ref().child(filePath);
  UploadTask uploadTask = ref.putData(fileBytes, SettableMetadata(contentType: 'image/jpeg'));
  TaskSnapshot taskSnapshot = await uploadTask;
  return await taskSnapshot.ref.getDownloadURL();
}

  Future<String> getUserProfileImageUrl(User user) async {
    DocumentSnapshot userProfile = await getUserProfile(user);
    return userProfile['imageUrl'];
  }
}
