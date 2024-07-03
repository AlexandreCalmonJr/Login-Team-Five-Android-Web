import 'package:firebase_login/models/user_model.dart';
import 'package:firebase_login/repository/profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _profileRepository = ProfileRepository();
  User? user;
  UserModel? userModel;
  bool uploading = false;
  String? uploadingError;
  String? saveMessage;
  String? uploadMessage;

  ProfileViewModel() {
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userProfile = await _profileRepository.getUserProfile(user!);
        if (userProfile.exists) {
          userModel = UserModel.fromMap(userProfile.data() as Map<String, dynamic>);
        } else {
          userModel = UserModel(
            name: user!.displayName ?? 'Novo Usuário',
            email: user!.email ?? 'email@example.com',
            phone: '',
            linkedin: '',
            address: '',
            imageUrl: user!.photoURL ?? '',
            imageUrls: [],
          );
          await _profileRepository.createUserProfile(user!, userModel!.toMap());
        }
        notifyListeners();
      } catch (e) {
        print('Erro ao carregar o perfil do usuário: $e');
      }
    }
  }

  Future<void> saveProfile() async {
    if (user != null && userModel != null) {
      try {
        await _profileRepository.updateUserProfile(user!, userModel!.toMap());
        saveMessage = 'Perfil salvo com sucesso!';
        notifyListeners();
      } catch (e) {
        saveMessage = 'Erro ao salvar o perfil do usuário: $e';
        notifyListeners();
      }
    }
  }

  Future<void> pickAndUploadImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null) {
        Uint8List? fileBytes = result.files.first.bytes;
        String fileName = result.files.first.name;
        if (fileBytes != null) {
          uploading = true;
          uploadingError = null;
          uploadMessage = null;
          notifyListeners();
          try {
            String downloadUrl = await _profileRepository.uploadImage(fileBytes, fileName);
            userModel!.imageUrl = downloadUrl;
            userModel!.imageUrls.add(downloadUrl);
            await saveProfile();
            uploadMessage = 'Imagem enviada com sucesso!';
          } catch (e) {
            uploadingError = 'Erro ao fazer upload da imagem: $e';
          } finally {
            uploading = false;
            notifyListeners();
          }
        }
      }
    } catch (e) {
      print('Erro ao selecionar a imagem: $e');
    }
  }

  Future<void> removeGalleryImage(int index) async {
    if (userModel != null && index >= 0 && index < userModel!.imageUrls.length) {
      try {
        await _profileRepository.deleteImage(userModel!.imageUrls[index]);
        userModel!.imageUrls.removeAt(index);
        await saveProfile();
      } catch (e) {
        print('Erro ao remover a imagem: $e');
      }
    }
  }

  void updateUserModel({
    required String name,
    required String email,
    required String phone,
    required String linkedin,
    required String address,
  }) {
    if (userModel != null) {
      userModel = UserModel(
        name: name,
        email: email,
        phone: phone,
        linkedin: linkedin,
        address: address,
        imageUrl: userModel!.imageUrl,
        imageUrls: userModel!.imageUrls,
      );
      notifyListeners();
    }
  }
}
