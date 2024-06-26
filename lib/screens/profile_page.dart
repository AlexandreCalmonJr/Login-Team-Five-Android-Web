import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/src/file_picker_result.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_login/repository/profile_repository.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart'; // Importar kIsWeb

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
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileRepository _profileRepository = ProfileRepository();
  User? user;
  String? imageUrl;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController linkedinController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  bool _silentMode = false;
  bool _darkMode = false;
  bool uploading = false;
  double total = 0;
  List<String> arquivos = [];
  List<Reference> refs = [];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    loadImages();
  }

  Future<void> _loadUserProfile() async {
    user = await _profileRepository.getCurrentUser();
    if (user != null) {
      DocumentSnapshot userProfile = await _profileRepository.getUserProfile(user!);
      if (userProfile.exists) {
        setState(() {
          nameController.text = userProfile['name'];
          emailController.text = userProfile['email'];
          phoneController.text = userProfile['phone'];
          linkedinController.text = userProfile['linkedin'];
          addressController.text = userProfile['address'];
          imageUrl = userProfile['imageUrl'];
        });
      } else {
        await _profileRepository.createUserProfile(user!, {
          'name': 'Novo Usuário',
          'email': user!.email,
          'phone': '',
          'linkedin': '',
          'address': '',
          'imageUrl': '',
        });
        setState(() {
          nameController.text = 'Novo Usuário';
          emailController.text = user!.email!;
        });
      }
    }
  }

  Future<void> pickAndUploadImage() async {
    FilePickerResult? file = await _profileRepository.pickImage();
    if (file != null) {
      setState(() {
        uploading = true;
      });
      try {
        String downloadUrl = await _profileRepository.uploadImage(file.paths as FilePickerResult);
        setState(() {
          imageUrl = downloadUrl;
          uploading = false;
        });
        await _profileRepository.updateUserProfile(user!, {'imageUrl': downloadUrl});
      } catch (e) {
        setState(() {
          uploading = false;
        });
        print('Erro ao fazer upload da imagem: $e');
      }
    }
  }

  Future<void> loadImages() async {
    refs = (await FirebaseStorage.instance.ref('images').listAll()).items;
    for (var ref in refs) {
      final arquivo = await ref.getDownloadURL();
      arquivos.add(arquivo);
    }
    setState(() => uploading = false);
  }

  Future<void> deleteImage(int index) async {
    await FirebaseStorage.instance.ref(refs[index].fullPath).delete();
    arquivos.removeAt(index);
    refs.removeAt(index);
    setState(() {});
  }

  Widget _buildProfileImage() {
    return FutureBuilder<bool>(
      future: _profileRepository.checkImageUrlValidity(imageUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircleAvatar(
            radius: 50,
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError || !snapshot.data!) {
          return CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage('assets/default_profile_image.png'),
          );
        } else {
          return CircleAvatar(
            radius: 50,
            backgroundImage: imageUrl != null
                ? NetworkImage(imageUrl!)
                : AssetImage('assets/default_profile_image.png'),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: uploading
            ? Text('${total.round()}% enviado')
            : const Text('Perfil Team 5'),
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
              // Adicionar ação para o ícone de ponto de interrogação
              // Exemplo: Mostrar um diálogo com informações sobre a página ou a ajuda do usuário
            },
            icon: const Icon(Icons.help),
          ),
        ],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
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
                  child: _buildProfileImage(),
                ),
                Center(
                  child: TextButton(
                    onPressed: pickAndUploadImage,
                    child: Text(
                      'Change Profile Image',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                _buildTextFieldWithIcon(
                    nameController, Icons.person, 'Username'),
                const SizedBox(height: 16.0),
                _buildTextFieldWithIcon(emailController, Icons.email, 'Email'),
                const SizedBox(height: 16.0),
                _buildTextFieldWithIcon(phoneController, Icons.phone, 'Phone'),
                const SizedBox(height: 16.0),
                _buildTextFieldWithIcon(
                    linkedinController, Icons.link, 'LinkedIn'),
                const SizedBox(height: 16.0),
                _buildTextFieldWithIcon(
                    addressController, Icons.location_on, 'Address'),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Silent Mode', style: TextStyle(color: Colors.white)),
                    Switch(
                      value: _silentMode,
                      onChanged: (value) {
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
                    Text('Dark Mode', style: TextStyle(color: Colors.white)),
                    Switch(
                      value: _darkMode,
                      onChanged: (value) {
                        setState(() {
                          _darkMode = value;
                        });
                      },
                    ),
                  ],
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await _profileRepository.updateUserProfile(user!, {
                          'name': nameController.text,
                          'email': emailController.text,
                          'phone': phoneController.text,
                          'linkedin': linkedinController.text,
                          'address': addressController.text,
                          'imageUrl': imageUrl,
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Perfil atualizado com sucesso!'),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erro ao atualizar o perfil: $e'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    ),
                    child:
                        Text('Salvar', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 32.0),
                Text(
                  'Suas Imagens:',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                uploading
                    ? Center(child: CircularProgressIndicator())
                    : arquivos.isEmpty
                        ? Center(
                            child: Text('Não há imagens ainda.',
                                style: TextStyle(color: Colors.white)))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: arquivos.length,
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                leading: SizedBox(
                                  width: 60,
                                  height: 40,
                                  child: Image(
                                    image: CachedNetworkImageProvider(
                                        arquivos[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text('Image $index',
                                    style: TextStyle(color: Colors.white)),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.white),
                                  onPressed: () => deleteImage(index),
                                ),
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
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white),
        labelText: label,
        labelStyle: TextStyle(color: Colors.white),
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
