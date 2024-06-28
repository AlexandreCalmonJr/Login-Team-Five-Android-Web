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

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      linkedin: map['linkedin'] ?? '',
      address: map['address'] ?? '',
      imageUrl: map['imageUrl'],
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
    );
  }
}
