import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_login/repository/profile_repository.dart';

class ProfilePage extends StatefulWidget {
  final String username;
  final String email;
  final String phoneNumber;
  final String address;
  final String profileImage;

  const ProfilePage({
    super.key,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.profileImage,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileRepository _profileRepository = ProfileRepository();
  User? user;
  String? imageUrl;
  List<String> imageUrls = []; // Lista para armazenar URLs das imagens carregadas

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController linkedinController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  bool _silentMode = false;
  bool _darkMode = false;
  bool uploading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    user = await _profileRepository.getCurrentUser();
    if (user != null) {
      DocumentSnapshot userProfile = await _profileRepository.getUserProfile(user!);
      if (userProfile.exists) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          setState(() {
            nameController.text = userProfile['name'];
            emailController.text = userProfile['email'];
            phoneController.text = userProfile['phone'];
            linkedinController.text = userProfile['linkedin'];
            addressController.text = userProfile['address'];
            imageUrl = userProfile['imageUrl'];
            imageUrls = List<String>.from(userProfile['imageUrls'] ?? []);
          });
        });
      } else {
        await _profileRepository.createUserProfile(user!, {
          'name': 'Novo Usuário',
          'email': user!.email,
          'phone': '',
          'linkedin': '',
          'address': '',
          'imageUrl': '',
          'imageUrls': [],
        });
        SchedulerBinding.instance.addPostFrameCallback((_) {
          setState(() {
            nameController.text = 'Novo Usuário';
            emailController.text = user!.email!;
          });
        });
      }
    }
  }
  Future<void> saveProfile() async {
  try {
    await _profileRepository.updateUserProfile(user!, {
      'name': nameController.text,
      'email': emailController.text,
      'phone': phoneController.text,
      'linkedin': linkedinController.text,
      'address': addressController.text,
      'imageUrl': imageUrl?? '',
      'imageUrls': imageUrls,
    });
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perfil atualizado com sucesso!'),
      ),
    );
  } catch (e) {
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erro ao atualizar o perfil: $e'),
      ),
    );
  }
}
  Future<void> pickAndUploadImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null) {
        Uint8List? fileBytes = result.files.first.bytes;
        if (fileBytes != null) {
          setState(() {
            uploading = true;
          });
          try {
            String downloadUrl = await _profileRepository.uploadImage(fileBytes);
            SchedulerBinding.instance.addPostFrameCallback((_) {
              setState(() {
                imageUrl = downloadUrl;
                imageUrls.add(downloadUrl);
                uploading = false;
              });
            });
            await _profileRepository.updateUserProfile(user!, {
              'imageUrl': downloadUrl,
              'imageUrls': imageUrls,
            });
          } catch (e) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              setState(() {
                uploading = false;
              });
            });
            // ignore: avoid_print
            print('Erro ao fazer upload da imagem: $e');
          }
        }
      }
    } catch (e) {
      // ignore: avoid_print
      print('Erro ao selecionar a imagem: $e');
    }
  }

  Future<void> updateAndSaveProfile() async {
  try {
    await _profileRepository.updateUserProfile(user!, {
      'name': nameController.text,
      'email': emailController.text,
      'phone': phoneController.text,
      'linkedin': linkedinController.text,
      'address': addressController.text,
      'imageUrl': imageUrl?? '',
      'imageUrls': imageUrls,
    });
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Perfil atualizado com sucesso!'),
      ),
    );
  } catch (e) {
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Erro ao atualizar o perfil: $e'),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: uploading ? const Text('Enviando...') : const Text('Perfil'),
        actions: [
          uploading
              ? const Padding(
                  padding: EdgeInsets.only(right: 12.0),
                  child: Center(
                    child: SizedBox(
                      width: 20.0,
                      height: 20.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.upload),
                  onPressed: pickAndUploadImage,
                ),
          IconButton(
            onPressed: () {
              // Ação para o ícone de ajuda
            },
            icon: const Icon(Icons.help),
          ),
        ],
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.blue],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: imageUrl != null
                        ? CachedNetworkImageProvider(imageUrl!)
                        : const AssetImage('assets/default_profile_image.png') as ImageProvider,
                    onBackgroundImageError: (exception, stackTrace) {
                      SchedulerBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          imageUrl = null;
                        });
                      });
                    },
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: pickAndUploadImage,
                    child: const Text(
                      'Mudar Imagem do Perfil',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                _buildTextFieldWithIcon(nameController, Icons.person, 'Username'),
                const SizedBox(height: 16.0),
                _buildTextFieldWithIcon(emailController, Icons.email, 'Email'),
                const SizedBox(height: 16.0),
                _buildTextFieldWithIcon(phoneController, Icons.phone, 'Phone'),
                const SizedBox(height: 16.0),
                _buildTextFieldWithIcon(linkedinController, Icons.link, 'LinkedIn'),
                const SizedBox(height: 16.0),
                _buildTextFieldWithIcon(addressController, Icons.location_on, 'Address'),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Modo Silencioso',
                      style: TextStyle(color: Colors.white),
                    ),
                    Switch(
                      value: _silentMode,
                      onChanged: (bool value) {
                        setState(() {
                          _silentMode = value;
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Modo Noturno',
                      style: TextStyle(color: Colors.white),
                    ),
                    Switch(
                      value: _darkMode,
                      onChanged: (bool value) {
                        setState(() {
                          _darkMode = value;
                        });
                      },
                    ),
                  ],
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: updateAndSaveProfile,
                    child: const Text('Salvar'),
                  ),
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Galeria de Imagens',
                  style: TextStyle(color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 8.0,
                  ),
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    return CachedNetworkImage(
                      imageUrl: imageUrls[index],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Icon(Icons.error),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldWithIcon(
      TextEditingController controller, IconData icon, String label) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        filled: true,
        fillColor: Colors.grey[800],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30.0),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
