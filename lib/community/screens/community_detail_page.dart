import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lapangin/community/models/community_model.dart';
import 'package:lapangin/community/widgets/community_post_card.dart';

class CommunityDetailPage extends StatefulWidget {
  final Community community;

  const CommunityDetailPage({super.key, required this.community});

  @override
  State<CommunityDetailPage> createState() => _CommunityDetailPageState();
}

class _CommunityDetailPageState extends State<CommunityDetailPage> {
  // Gunakan IP 10.0.2.2 untuk emulator Android, atau localhost untuk Web
  final String baseUrl = "http://10.0.2.2:8000"; 

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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.arrow_back, color: Colors.black),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl, 
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, error, stackTrace) => Container(color: Colors.grey[300], child: const Icon(Icons.broken_image, color: Colors.grey, size: 50)),
                        )
                      : Container(color: Colors.grey[300], child: const Icon(Icons.sports, size: 80, color: Colors.grey)),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B9E6D),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.community.sportsType.toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.community.communityName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: Colors.white70),
                            const SizedBox(width: 4),
                            Text(
                              widget.community.location,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(width: 16),
                            const Icon(Icons.people, size: 16, color: Colors.white70),
                            const SizedBox(width: 4),
                            Text(
                              "${widget.community.memberCount} Anggota",
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tombol Join
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B9E6D), // Olive green
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                      onPressed: () => joinCommunity(request),
                      child: const Text(
                        "Bergabung dengan Komunitas",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  const Text(
                    "Tentang Komunitas",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.community.description,
                    style: TextStyle(color: Colors.grey[700], height: 1.6, fontSize: 14),
                  ),
                  const SizedBox(height: 30),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Forum Diskusi",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to create post page or show dialog
                        },
                        child: const Text("Lihat Semua", style: TextStyle(color: Color(0xFF8B9E6D))),
                      ),
                    ],
                  ),
                  const Divider(),
                ],
              ),
            ),
          ),
          
          // List Post Forum
          FutureBuilder(
            future: fetchPosts(request),
            builder: (context, AsyncSnapshot<List<CommunityPost>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(20), child: Center(child: Text("Belum ada diskusi."))));
              } else {
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final post = snapshot.data![index];
                      return CommunityPostCard(post: post);
                    },
                    childCount: snapshot.data!.length,
                  ),
                );
              }
            },
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 30)),
        ],
      ),
    );
  }
}