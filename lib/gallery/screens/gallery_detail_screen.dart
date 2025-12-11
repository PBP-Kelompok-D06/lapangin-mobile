// lib/gallery/screens/gallery_detail_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/lapangan_detail.dart';

/// NOTE:
/// - ganti BASE_URL sesuai environment kamu (emulator android: 10.0.2.2)
/// - tambahkan permission Internet di AndroidManifest jika perlu
const String BASE_URL = 'http://10.0.2.2:8000';

class GalleryDetailScreen extends StatefulWidget {
  final int lapanganId;

  const GalleryDetailScreen({Key? key, required this.lapanganId}) : super(key: key);

  @override
  _GalleryDetailScreenState createState() => _GalleryDetailScreenState();
}

class _GalleryDetailScreenState extends State<GalleryDetailScreen> {
  late Future<LapanganDetail> _futureDetail;
  String? _currentHero;

  @override
  void initState() {
    super.initState();
    _futureDetail = fetchLapanganDetail(widget.lapanganId);
  }

  Future<LapanganDetail> fetchLapanganDetail(int id) async {
    final uri = Uri.parse('$BASE_URL/api/lapangan/$id/');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(res.body);
      final detail = LapanganDetail.fromJson(data);
      // set initial hero (use first galleryImage or image)
      _currentHero ??= (detail.galleryImages.isNotEmpty ? detail.galleryImages[0] : detail.image);
      return detail;
    } else {
      throw Exception('Failed to load detail (status ${res.statusCode})');
    }
  }

  void _setHero(String url) {
    setState(() => _currentHero = url);
  }

  String formatRupiah(int value) {
    final s = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final pos = s.length - i;
      buffer.write(s[i]);
      if (pos > 1 && pos % 3 == 1) buffer.write('.');
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery'),
      ),
      body: FutureBuilder<LapanganDetail>(
        future: _futureDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final detail = snapshot.data!;
          // ensure hero is set
          _currentHero ??= (detail.galleryImages.isNotEmpty ? detail.galleryImages[0] : detail.image);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HERO IMAGE
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: _currentHero != null
                        ? Image.network(
                            _currentHero!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            loadingBuilder: (ctx, child, progress) {
                              if (progress == null) return child;
                              final pct = progress.cumulativeBytesLoaded / (progress.expectedTotalBytes ?? 1);
                              return Stack(
                                fit: StackFit.expand,
                                children: [
                                  Container(color: Colors.grey.shade200),
                                  Center(child: CircularProgressIndicator(value: pct)),
                                ],
                              );
                            },
                            errorBuilder: (ctx, err, stack) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: const Center(child: Icon(Icons.broken_image, size: 48)),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey.shade200,
                            child: const Center(child: Icon(Icons.image, size: 48)),
                          ),
                  ),

                  const SizedBox(height: 12),

                  // THUMBNAILS (scroll horizontal)
                  SizedBox(
                    height: 88,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        // combine galleryImages + fallback image
                        ...{
                          if (detail.galleryImages.isNotEmpty) ...detail.galleryImages else if (detail.image != null) detail.image!
                        }.map((img) {
                          final bool isActive = img == _currentHero;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: GestureDetector(
                              onTap: () => _setHero(img),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                curve: Curves.easeOut,
                                width: isActive ? 110 : 88,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: isActive ? Colors.green : Colors.white, width: 3),
                                  boxShadow: isActive ? [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0,4))] : null,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    img,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (ctx, child, progress) {
                                      if (progress == null) return child;
                                      return Container(
                                        color: Colors.grey.shade200,
                                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                      );
                                    },
                                    errorBuilder: (ctx, _, __) => Container(
                                      color: Colors.grey.shade200,
                                      child: const Center(child: Icon(Icons.broken_image)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // TITLE & PRICE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(detail.name, style: Theme.of(context).textTheme.titleLarge)),
                      Text('Rp ${formatRupiah(detail.price)}',style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // RATING & LOCATION
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text('${detail.rating}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 12),
                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(child: Text(detail.location, style: const TextStyle(color: Colors.grey))),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // FASILITAS chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: detail.fasilitas.isNotEmpty
                        ? detail.fasilitas.map((f) => Chip(label: Text(f))).toList()
                        : [const Text('Tidak ada fasilitas terdaftar.', style: TextStyle(color: Colors.grey))],
                  ),

                  const SizedBox(height: 16),

                  // DESKRIPSI
                  if ((detail.deskripsi ?? '').isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text(detail.deskripsi ?? '', textAlign: TextAlign.justify),
                        const SizedBox(height: 12),
                      ],
                    ),

                  // REVIEWS (show top 4)
                  const Text('Ulasan teratas', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ...detail.reviews.take(4).map((r) => _buildReviewTile(r)).toList(),

                  const SizedBox(height: 24),

                  // BUTTON BOOKING (simple)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // redirect ke halaman booking app kamu
                        // Navigator.pushNamed(context, '/booking', arguments: detail.id);
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14.0),
                        child: Text('Booking Sekarang'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReviewTile(GReview r) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.green.shade100,
            child: Text(r.user.isNotEmpty ? r.user[0].toUpperCase() : '?'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(r.user, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Text(r.createdAt, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(r.content),
                const SizedBox(height: 6),
                Row(children: [
                  for (var i = 0; i < r.rating.round(); i++) const Icon(Icons.star, size: 16, color: Colors.amber),
                  for (var i = 0; i < (5 - r.rating.round()); i++) const Icon(Icons.star_border, size: 16, color: Colors.grey),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
