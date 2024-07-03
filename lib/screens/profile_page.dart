import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_login/models/profile_viewmodel.dart';
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
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png', // Substitua pelo caminho da sua logo
                height: 40,
              ),
              const SizedBox(width: 8),
              const Text(
                'Perfil do Usuario',
                style: TextStyle(color: Colors.black),
              ),
              const SizedBox(width: 8),
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
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade700,
                Colors.blue.shade300,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Consumer<ProfileViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.userModel == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ListView(
                    children: <Widget>[
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Provider.of<ProfileViewModel>(context,
                                    listen: false)
                                .pickAndUploadImage();
                          },
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: viewModel.userModel!.imageUrl !=
                                        null &&
                                    viewModel.userModel!.imageUrl!.isNotEmpty
                                ? CachedNetworkImageProvider(
                                    viewModel.userModel!.imageUrl!)
                                : null,
                            child: viewModel.userModel!.imageUrl == null ||
                                    viewModel.userModel!.imageUrl!.isEmpty
                                ? const Icon(Icons.person, size: 50)
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nome'),
                        onChanged: (value) {
                          viewModel.updateUserModel(
                            name: value,
                            email: _emailController.text,
                            phone: _phoneController.text,
                            linkedin: _linkedInController.text,
                            address: _addressController.text,
                          );
                        },
                      ),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        onChanged: (value) {
                          viewModel.updateUserModel(
                            name: _nameController.text,
                            email: value,
                            phone: _phoneController.text,
                            linkedin: _linkedInController.text,
                            address: _addressController.text,
                          );
                        },
                      ),
                      TextFormField(
                        controller: _phoneController,
                        decoration:
                            const InputDecoration(labelText: 'Telefone'),
                        onChanged: (value) {
                          viewModel.updateUserModel(
                            name: _nameController.text,
                            email: _emailController.text,
                            phone: value,
                            linkedin: _linkedInController.text,
                            address: _addressController.text,
                          );
                        },
                      ),
                      TextFormField(
                        controller: _linkedInController,
                        decoration:
                            const InputDecoration(labelText: 'LinkedIn'),
                        onChanged: (value) {
                          viewModel.updateUserModel(
                            name: _nameController.text,
                            email: _emailController.text,
                            phone: _phoneController.text,
                            linkedin: value,
                            address: _addressController.text,
                          );
                        },
                      ),
                      TextFormField(
                        controller: _addressController,
                        decoration:
                            const InputDecoration(labelText: 'Endereço'),
                        onChanged: (value) {
                          viewModel.updateUserModel(
                            name: _nameController.text,
                            email: _emailController.text,
                            phone: _phoneController.text,
                            linkedin: _linkedInController.text,
                            address: value,
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          await viewModel.saveProfile();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(viewModel.saveMessage ?? '')),
                          );
                        },
                        child: const Text('Salvar Perfil'),
                      ),
                      if (viewModel.uploading)
                        const Center(child: CircularProgressIndicator()),
                      if (viewModel.uploadingError != null)
                        Center(
                            child: Text(
                                'Erro ao enviar imagem: ${viewModel.uploadingError}')),
                      if (viewModel.uploadMessage != null)
                        Center(child: Text(viewModel.uploadMessage!)),
                      const SizedBox(height: 20),
                      const Text(
                        'Galeria de Imagens',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: viewModel.userModel!.imageUrls.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl:
                                      viewModel.userModel!.imageUrls[index],
                                  width: 100,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
