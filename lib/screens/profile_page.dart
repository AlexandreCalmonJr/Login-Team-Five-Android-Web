import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_login/datasources/profile_viewmodel.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_login/screens/chat_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _linkedInController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfile();
    });
  }

  Future<void> _loadUserProfile() async {
    await Provider.of<ProfileViewModel>(context, listen: false)
        .loadUserProfile();
    _updateTextControllers();
  }

  void _updateTextControllers() {
    final viewModel = Provider.of<ProfileViewModel>(context, listen: false);
    _nameController.text = viewModel.userModel?.name ?? '';
    _emailController.text = viewModel.userModel?.email ?? '';
    _phoneController.text = viewModel.userModel?.phone ?? '';
    _linkedInController.text = viewModel.userModel?.linkedin ?? '';
    _addressController.text = viewModel.userModel?.address ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Consumer<ProfileViewModel>(
            builder: (context, viewModel, child) {
              return viewModel.uploading
                  ? const Text('Enviando...', style: TextStyle(color: Color.fromARGB(255, 7, 6, 6)))
                  : const Text('Perfil', style: TextStyle(color: Color.fromARGB(255, 20, 16, 16)));
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.upload),
              onPressed: () {
                Provider.of<ProfileViewModel>(context, listen: false)
                    .pickAndUploadImage();
              },
            ),
            IconButton(
              icon: const Icon(Icons.chat),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChatPage()),
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black, Colors.blue],
              ),
            ),
            child: Consumer<ProfileViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.userModel == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Provider.of<ProfileViewModel>(context, listen: false)
                                .pickAndUploadImage();
                          },
                          child: Center(
                            child: CircleAvatar(
                              radius: 50.0,
                              backgroundImage: viewModel.userModel?.imageUrl != null &&
                                      viewModel.userModel!.imageUrl!.isNotEmpty
                                  ? CachedNetworkImageProvider(
                                      viewModel.userModel!.imageUrl!)
                                  : null,
                              child: viewModel.userModel?.imageUrl == null ||
                                      viewModel.userModel!.imageUrl!.isEmpty
                                  ? const Icon(Icons.person, size: 50.0)
                                  : null,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Nome',
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              labelText: 'Telefone',
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: TextFormField(
                            controller: _linkedInController,
                            decoration: const InputDecoration(
                              labelText: 'LinkedIn',
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: TextFormField(
                            controller: _addressController,
                            decoration: const InputDecoration(
                              labelText: 'Endereço',
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              viewModel.updateUserModel(
                                name: _nameController.text,
                                email: _emailController.text,
                                phone: _phoneController.text,
                                linkedin: _linkedInController.text,
                                address: _addressController.text,
                              );
                              await viewModel.saveProfile();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Perfil salvo com sucesso!'),
                                ),
                              );
                            }
                          },
                          child: const Text('Salvar'),
                        ),
                        const SizedBox(height: 20.0),
                        const Text(
                          'Galeria de Imagens',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8.0,
                            mainAxisSpacing: 8.0,
                          ),
                          itemCount: viewModel.userModel!.imageUrls.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                CachedNetworkImage(
                                  imageUrl: viewModel.userModel!.imageUrls[index],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: IconButton(
                                    icon: const Icon(Icons.remove_circle,
                                        color: Colors.red),
                                    onPressed: () async {
                                      await viewModel.removeGalleryImage(index);
                                    },
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

