import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lapangin/community/models/community_model.dart';
import 'package:lapangin/community/widgets/community_post_card.dart';
import 'package:lapangin/config.dart';

class CommunityDetailPage extends StatefulWidget {
  final Community community;

  const CommunityDetailPage({super.key, required this.community});

  @override
  State<CommunityDetailPage> createState() => _CommunityDetailPageState();
}

class _CommunityDetailPageState extends State<CommunityDetailPage> {
  // Gunakan IP dari Config
  final String baseUrl = Config.baseUrl;

  Future<List<CommunityPost>> fetchPosts(CookieRequest request) async {
    final response = await request.get('$baseUrl/community/api/community/${widget.community.pk}/posts/');
    List<dynamic> postsJson = response['posts'];
    return postsJson.map((json) => CommunityPost.fromJson(json)).toList();
  }

  Future<void> joinCommunity(CookieRequest request) async {
    // Melakukan request POST ke Django
    final response = await request.post('$baseUrl/community/api/${widget.community.pk}/join-flutter/', {});
    
    if (!mounted) return;

    if (response['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'])));
      setState(() {}); // Refresh halaman untuk update status/tampilan
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(response['message'] ?? "Gagal join."),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    
    // Handle Image URL
    String imageUrl = widget.community.imageUrl ?? "";
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
        imageUrl = '$baseUrl$imageUrl';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          const Center(
            child: Text(
              "Hi, Username!  ",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=5"), // Placeholder avatar
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Hero Image Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey[300],
                image: imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(imageUrl),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {
                           print("Error loading image: $imageUrl");
                        },
                      )
                    : null,
              ),
              child: Stack(
                children: [
                  if (imageUrl.isEmpty)
                    const Center(child: Icon(Icons.sports, size: 60, color: Colors.grey)),
                  
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.6),
                        ],
                      ),
                    ),
                  ),
                  
                  // Text Content
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.community.communityName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${widget.community.sportsType} • ${widget.community.location}",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 2. Tentang Komunitas Card
            Container(
              margin: const EdgeInsets.all(16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Tentang Komunitas",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.community.description,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  
                  // Details Grid
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Column 1
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.people_outline, size: 18, color: Color(0xFF8B9E6D)),
                                const SizedBox(width: 8),
                                Text(
                                  "${widget.community.memberCount} Anggota",
                                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.person_outline, size: 18, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(
                                  widget.community.contactPerson,
                                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Column 2
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(
                                  "Dibuat : 03 Dec 2025", // Placeholder as requested
                                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.phone_outlined, size: 16, color: Colors.red),
                                const SizedBox(width: 8),
                                Text(
                                  "08123456789", // Placeholder
                                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 3. Join Banner
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD), // Light blue
                borderRadius: BorderRadius.circular(4),
                border: const Border(
                  left: BorderSide(color: Color(0xFF1565C0), width: 4),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF1565C0), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: const Text(
                      "Bergabunglah untuk\nberpartisipasi dalam forum",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => joinCommunity(request),
                    icon: const Icon(Icons.person_add_alt_1, size: 18, color: Color(0xFF556B2F)), // Dark olive
                    label: const Text("Gabung", style: TextStyle(color: Color(0xFF556B2F), fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC5E1A5), // Light green
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Thicker button
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 4. Forum Diskusi Header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Icon(Icons.chat_bubble_outline, color: Color(0xFF8B9E6D), size: 24),
                  SizedBox(width: 8),
                  Text(
                    "Forum Diskusi",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),

            // 5. Forum List
            FutureBuilder(
              future: fetchPosts(request),
              builder: (context, AsyncSnapshot<List<CommunityPost>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Column(
                      children: [
                        Text("Belum ada diskusi.", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ));
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final post = snapshot.data![index];
                      return CommunityPostCard(post: post);
                    },
                  );
                }
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}