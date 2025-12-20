import 'package:flutter/material.dart';
import 'package:lapangin_mobile/config.dart';

class AdminCommunityCard extends StatelessWidget {
  final Map<String, dynamic> communityData;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const AdminCommunityCard({
    Key? key,
    required this.communityData,
    required this.onEdit,
    required this.onDelete,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String name = communityData['community_name'] ?? 'Nama Komunitas';
    final String location = communityData['location'] ?? 'Lokasi';
    final String type = communityData['sports_type'] ?? 'Jenis';
    final int memberCount = communityData['member_count'] ?? 0;
    final int maxMember = communityData['max_member'] ?? 0;
    final String? imageUrl = communityData['image_url'];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12), // Increased opacity
              blurRadius: 6, 
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Thumbnail Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: SizedBox(
                height: 150,
                width: double.infinity,
                child: (imageUrl != null && imageUrl.isNotEmpty)
                    ? Image.network(
                        imageUrl.startsWith('http') ? imageUrl : "${Config.baseUrl}$imageUrl",
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, color: Colors.grey, size: 50),
                      ),
              ),
            ),

            // 2. Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Type • Location
                  Row(
                    children: [
                      Text(
                        type,
                        style: const TextStyle(
                          color: Color(0xFF8B9E6D), // Olive green/Goldish
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text("•", style: TextStyle(color: Color(0xFFE5B80B), fontSize: 12)),
                      const SizedBox(width: 4),
                       Text(
                        location,
                        style: const TextStyle(
                          color: Color(0xFFE5B80B), // Gold/Yellow
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Member Count
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        "$memberCount/$maxMember anggota",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  const Text(
                    "Join kuy",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // "Cek Komunitas ->"
                  const Text(
                    "Cek Komunitas →",
                     style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8B9E6D),
                        fontWeight: FontWeight.bold,
                      ),
                  ),

                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    children: [
                      // Edit Button
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: onEdit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1F2937), // Dark Blue/Grey
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Edit",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Hapus Button
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: onDelete,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEF4444), // Red
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "Hapus",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
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
