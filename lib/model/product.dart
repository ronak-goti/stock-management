import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class Product {
  final String name;
  final String sku;
  final String barcode;
  final double costPrice;
  final double sellingPrice;
  final int quantity;
  final String category;
  final File? image; // For mobile
  final String? webImage; // For web

  Product({
    required this.name,
    required this.sku,
    required this.barcode,
    required this.costPrice,
    required this.sellingPrice,
    required this.quantity,
    required this.category,
    this.image,
    this.webImage,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'sku': sku,
    'barcode': barcode,
    'costPrice': costPrice,
    'sellingPrice': sellingPrice,
    'quantity': quantity,
    'category': category,
    'webImage': webImage,
    'imagePath': image?.path,
  };

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      name: json['name'],
      sku: json['sku'],
      barcode: json['barcode'],
      costPrice: (json['costPrice'] ?? 0).toDouble(),
      sellingPrice: (json['sellingPrice'] ?? 0).toDouble(),
      quantity: (json['quantity'] ?? 0).toInt(),
      category: json['category'] ?? '',
      image: !kIsWeb && json['imagePath'] != null
          ? File(json['imagePath'])
          : null,
      webImage: json['webImage'],
    );
  }
}
