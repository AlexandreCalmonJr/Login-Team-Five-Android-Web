class UserModel {
  String name;
  String email;
  String phone;
  String linkedin;
  String address;
  String? imageUrl;
  List<String> imageUrls;

  UserModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.linkedin,
    required this.address,
    this.imageUrl,
    required this.imageUrls,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      name: data['name'],
      email: data['email'],
      phone: data['phone'],
      linkedin: data['linkedin'],
      address: data['address'],
      imageUrl: data['imageUrl'],
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'linkedin': linkedin,
      'address': address,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
    };
  }
}