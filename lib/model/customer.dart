import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class Customer {
  final String name;
  final String phone;
  final String email;
  final File? image;      // for mobile/desktop platforms
  final String? webImage; // for web (base64 image data)

  Customer({
    required this.name,
    required this.phone,
    required this.email,
    this.image,
    this.webImage,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'image': !kIsWeb && image != null
          ? base64Encode(image!.readAsBytesSync())
          : null,
      'webImage': webImage,
    };
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    File? file;
    if (!kIsWeb && json['image'] != null) {
      try {
        final bytes = base64Decode(json['image']);
        final tempDir = Directory.systemTemp;
        final filePath =
            '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.png';
        file = File(filePath)..writeAsBytesSync(bytes);
      } catch (_) {}
    }

    return Customer(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      image: file,
      webImage: json['webImage'],
    );
  }
}
