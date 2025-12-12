// lib/gallery/models/lapangan_detail.dart
import 'package:flutter/foundation.dart';
import 'package:lapangin_mobile/review/models/review_entry.dart';

class LapanganDetail {
  final int id;
  final String name;
  final String type;
  final String location;
  final int price;
  final double rating;
  final String? image; // main image (nullable)
  final int reviewCount;
  final String? deskripsi;
  final List<String> fasilitas;
  final List<String> galleryImages;
  final List<ReviewEntry> reviews;

  LapanganDetail({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.price,
    required this.rating,
    required this.image,
    required this.reviewCount,
    required this.deskripsi,
    required this.fasilitas,
    required this.galleryImages,
    required this.reviews,
  });

  factory LapanganDetail.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? rawGallery = json['gallery_images'] as List<dynamic>?;
    final List<dynamic>? rawFas = json['fasilitas'] as List<dynamic>?;
    final List<dynamic>? rawReviews = json['reviews'] as List<dynamic>?;

    return LapanganDetail(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type']?.toString() ?? '',
      location: json['location'] ?? '',
      price: (json['price'] is int) ? json['price'] as int : int.tryParse('${json['price']}') ?? 0,
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : double.tryParse('${json['rating']}') ?? 0.0,
      image: json['image'] as String?,
      reviewCount: (json['review_count'] is int) ? json['review_count'] as int : int.tryParse('${json['review_count']}') ?? 0,
      deskripsi: json['deskripsi'] as String?,
      fasilitas: rawFas != null ? rawFas.map((e) => e.toString()).where((s) => s.isNotEmpty).toList() : <String>[],
      galleryImages: rawGallery != null ? rawGallery.map((e) => e.toString()).where((s) => s.isNotEmpty).toList() : <String>[],
      reviews: rawReviews != null
          ? rawReviews
              .where((e) => e != null)
              .map((e) => ReviewEntry.fromJson(
                    Map<String, dynamic>.from(e as Map),
                  ))
              .toList()
          : <ReviewEntry>[],
          );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'location': location,
        'price': price,
        'rating': rating,
        'image': image,
        'review_count': reviewCount,
        'deskripsi': deskripsi,
        'fasilitas': fasilitas,
        'gallery_images': galleryImages,
        'reviews': reviews.map((r) => r.toJson()).toList(),
      };
}

class GReview {
  final String user;
  final double rating;
  final String content;
  final String createdAt;

  GReview({
    required this.user,
    required this.rating,
    required this.content,
    required this.createdAt,
  });

  factory GReview.fromJson(Map<String, dynamic> json) {
    return GReview(
      user: json['user']?.toString() ?? 'anonymous',
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : double.tryParse('${json['rating']}') ?? 0.0,
      content: json['content']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'user': user,
        'rating': rating,
        'content': content,
        'created_at': createdAt,
      };
}
