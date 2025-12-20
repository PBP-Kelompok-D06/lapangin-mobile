import 'package:flutter/material.dart';
import 'package:lapangin_mobile/config.dart';

class AdminFieldCard extends StatelessWidget {
  final Map<String, dynamic> fieldData;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const AdminFieldCard({
    super.key,
    required this.fieldData,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Keys based on API response
    final String? imageUrl = fieldData['foto_utama'] ?? fieldData['image_url'];
    final String name = fieldData['nama_lapangan'] ?? fieldData['nama'] ?? 'Unknown Field';
    final String type = fieldData['jenis_olahraga'] ?? fieldData['jenis'] ?? 'Unknown';
    final String location = fieldData['lokasi'] ?? '-';
    final dynamic price = fieldData['harga_per_jam'] ?? fieldData['harga'] ?? 0;
    final String fasilitas = fieldData['fasilitas'] ?? '-';
    // Rating handling
    final dynamic ratingRaw = fieldData['rating'] ?? 0;
    final double rating = (ratingRaw is int) ? ratingRaw.toDouble() : (ratingRaw as double);
    final int reviewCount = fieldData['jumlah_ulasan'] ?? 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image & Badge Section
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: SizedBox(
                    height: 180,
                    width: double.infinity,
                    child: (imageUrl != null && imageUrl.isNotEmpty)
                        ? Builder(
                            builder: (context) {
                              final rawUrl = imageUrl!.startsWith('http') 
                                  ? imageUrl! 
                                  : "${Config.baseUrl}${imageUrl!.startsWith('/') ? '' : '/'}$imageUrl";
                              
                              // Use proxy endpoint exactly like Landing Page (card_lapangan.dart)
                              // This bypasses CORS and static serving issues on Web
                              final proxyUrl = "${Config.baseUrl}/proxy-image/?url=${Uri.encodeComponent(rawUrl)}";
                              
                              return Image.network(
                                proxyUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, error, stackTrace) => Container(
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.image_not_supported, size: 40, color: Colors.grey[400]),
                                        const SizedBox(height: 4),
                                        Text("Gagal memuat", style: TextStyle(color: Colors.grey[500], fontSize: 10))
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                          )
                        : Container(
                            color: const Color(0xFFF1F5E9), // Light green tint
                            child: Center(
                              child: Icon(Icons.sports_soccer, size: 50, color: const Color(0xFFA4C639).withOpacity(0.5)),
                            ),
                          ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFACCA69), // Green badge
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      type.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Location
                  Text(
                    location,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Fasilitas
                  if (fasilitas != '-' && fasilitas.isNotEmpty) ...[
                    Text(
                      "Fasilitas: $fasilitas",
                      style: TextStyle(color: Colors.grey[800], fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Price
                  Text(
                    "Rp $price/jam",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF2E7D32), // Dark green
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        "$rating ($reviewCount)",
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onEdit,
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text("EDIT"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE3F2FD), // Light blue
                            foregroundColor: const Color(0xFF1976D2), // Blue text
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete, size: 16),
                          label: const Text("HAPUS"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFEBEE), // Light red
                            foregroundColor: const Color(0xFFD32F2F), // Red text
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
