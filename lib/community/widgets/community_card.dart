import 'package:flutter/material.dart';
import 'package:lapangin/community/models/community_model.dart';
import 'package:lapangin/community/screens/community_detail_page.dart';

class CommunityCard extends StatelessWidget {
  final Community community;

  const CommunityCard({super.key, required this.community});

  @override
  Widget build(BuildContext context) {
    // Gunakan IP 10.0.2.2 jika pakai Emulator Android
    const String baseUrl = "http://10.0.2.2:8000"; 

    String imageUrl = community.imageUrl ?? "";
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
        imageUrl = '$baseUrl$imageUrl';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CommunityDetailPage(community: community)),
          );
        },
        child: Row(
          children: [
            // Left Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: imageUrl.isNotEmpty 
                  ? Image.network(
                      imageUrl, 
                      height: 120, 
                      width: 120, 
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, _, __) => Container(height: 120, width: 120, color: Colors.grey[300], child: const Icon(Icons.broken_image)),
                    )
                  : Container(height: 120, width: 120, color: Colors.grey[300], child: const Icon(Icons.sports, size: 40, color: Colors.grey)),
            ),
            
            // Right Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      community.communityName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        children: [
                          TextSpan(text: community.sportsType, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8B9E6D))),
                          const TextSpan(text: " • "),
                          TextSpan(text: community.location, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      community.description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Cek Komunitas ->",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8B9E6D),
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.person, size: 16, color: Color(0xFF8B9E6D)),
                            const SizedBox(width: 2),
                            Text(
                              "${community.memberCount}",
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
