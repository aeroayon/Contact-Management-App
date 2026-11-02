
class Contact {
  final int? id;
  final String name;
  final String phone;
  final String email;
  final String address;
  final bool isFavorite;

  Contact({
    this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String,
      address: map['address'] as String,
      isFavorite: map['isFavorite'] == 1,
    );
  }

  Contact copyWith({bool? isFavorite}) {
    return Contact(
      id: id,
      name: name,
      phone: phone,
      email: email,
      address: address,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
