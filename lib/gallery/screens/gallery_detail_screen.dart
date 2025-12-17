// lib/gallery/screens/gallery_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:lapangin_mobile/review/screens/review_lapangan.dart';
import 'package:lapangin_mobile/review/widgets/card_review.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/lapangan_detail.dart';
import 'package:lapangin_mobile/config.dart';
import 'package:lapangin_mobile/review/widgets/statistik.dart';
import 'package:provider/provider.dart';
import 'package:lapangin_mobile/booking/screens/booking_screen.dart';
import 'dart:math';

/// NOTE:
/// - ganti BASE_URL sesuai environment kamu (emulator android: 10.0.2.2)
/// - tambahkan permission Internet di AndroidManifest jika perlu

class GalleryDetailScreen extends StatefulWidget {
  final int lapanganId;

  const GalleryDetailScreen({Key? key, required this.lapanganId})
    : super(key: key);

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
    final uri = Uri.parse('${Config.baseUrl}/gallery/api/lapangan/$id/');
    final request = context.read<CookieRequest>();
    final res = await request.get(uri.toString());
    print("RESPONSE: $res");

    if (res is Map<String, dynamic>) {
      final detail = LapanganDetail.fromJson(res);
      // set initial hero (use first galleryImage or image)
      _currentHero ??= (detail.galleryImages.isNotEmpty
          ? detail.galleryImages[0]
          : detail.image);
      return detail;
    } else {
      throw Exception('Failed to load detail (status ${res['status']})');
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
    final request = context.read<CookieRequest>();
    final String _userName = request.jsonData['username'] ?? "User";
    final String firstName = _userName.split(' ').first;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Hi, $firstName!",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFF6B8E23),
              child: Text(
                firstName.isNotEmpty ? firstName[0].toUpperCase() : "U",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
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
          _currentHero ??= (detail.galleryImages.isNotEmpty
              ? detail.galleryImages[0]
              : detail.image);

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HERO IMAGE
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _currentHero != null
                          ? Image.network(
                            buildImageUrl(_currentHero!),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              loadingBuilder: (ctx, child, progress) {
                                if (progress == null) return child;
                                final pct =
                                    progress.cumulativeBytesLoaded /
                                    (progress.expectedTotalBytes ?? 1);
                                return Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Container(color: Colors.grey.shade200),
                                    Center(
                                      child: CircularProgressIndicator(
                                        value: pct,
                                      ),
                                    ),
                                  ],
                                );
                              },
                              errorBuilder: (ctx, err, stack) {
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: const Center(
                                    child: Icon(Icons.broken_image, size: 48),
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(Icons.image, size: 48),
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // THUMBNAILS (scroll horizontal)
                  Center(
                    child: SizedBox(
                      height: 88,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        children: [
                          // combine galleryImages + fallback image
                          ...{
                            if (detail.galleryImages.isNotEmpty)
                              ...detail.galleryImages
                            else if (detail.image != null)
                              detail.image!,
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
                                    border: Border.all(
                                      color: isActive
                                          ? Colors.green
                                          : Colors.white,
                                      width: 3,
                                    ),
                                    boxShadow: isActive
                                        ? [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 8,
                                              offset: Offset(0, 4),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      buildImageUrl(img),
                                      fit: BoxFit.cover,
                                      loadingBuilder: (ctx, child, progress) {
                                        if (progress == null) return child;
                                        return Container(
                                          color: Colors.grey.shade200,
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder: (ctx, _, __) => Container(
                                        color: Colors.grey.shade200,
                                        child: const Center(
                                          child: Icon(Icons.broken_image),
                                        ),
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
                  ),

                  const SizedBox(height: 24),

                  // TITLE & PRICE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          detail.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        'Rp ${formatRupiah(detail.price)}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // RATING & LOCATION
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${detail.rating}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          detail.location,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // FASILITAS chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: detail.fasilitas.isNotEmpty
                        ? detail.fasilitas
                              .map((f) => Chip(label: Text(f)))
                              .toList()
                        : [
                            const Text(
                              'Tidak ada fasilitas terdaftar.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                  ),

                  const SizedBox(height: 16),

                  // DESKRIPSI
                  if ((detail.deskripsi ?? '').isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Deskripsi',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          detail.deskripsi ?? '',
                          textAlign: TextAlign.justify,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),

                  // S (show top 4)
                  ReviewStats(reviews: detail.reviews),
                  SizedBox(height: 20),
                  if (detail.reviews.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(30.0),
                        child: Text("Belum ada review"),
                      ),
                    )
                  else
                    ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: min(4, detail.reviews.length),
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return ReviewCard(
                          review: detail.reviews[index],
                          onRefresh: () {
                            setState(() {
                              _futureDetail = fetchLapanganDetail(
                                widget.lapanganId,
                              );
                            });
                          },
                        );
                      },
                    ),
                  const SizedBox(height: 20),

                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF383838),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ReviewPage(fieldId: detail.id),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              "Lihat Semua Review",
                              style: TextStyle(
                                color: Color(0xFFB8D279),
                                fontFamily: 'Montserrat',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: SizedBox(
          width: double.infinity,
          height: 40,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB8D279),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookingScreen(
                    lapanganId: widget.lapanganId,
                    sessionCookie: request.cookies['sessionid']?.value ?? "",
                    username: request.jsonData['username'],
                  ),
                ),
              );
              //ke bion
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.add, color: Color(0xFF4D5833), size: 20),
                SizedBox(width: 12),
                Text(
                  "Booking Sekarang",
                  style: TextStyle(
                    color: Color(0xFF4D5833),
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
String buildImageUrl(String img) {
  final isFullUrl = img.startsWith("http://") || img.startsWith("https://");
  final rawUrl = isFullUrl ? img : "${Config.baseUrl}/$img";

  return "${Config.baseUrl}/proxy-image/?url=${Uri.encodeComponent(rawUrl)}";
}
