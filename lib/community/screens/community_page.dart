import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lapangin/community/models/community_model.dart';
import 'package:lapangin/community/widgets/community_card.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  String _searchQuery = "";
  String _selectedCategory = "Jenis Olahraga";
  String _selectedLocation = "Filter Lokasi";
  
  // Options for filters
  final List<String> _categories = ["Jenis Olahraga", "Futsal", "Bulutangkis", "Basket", "Renang"];
  final List<String> _locations = ["Filter Lokasi", "Depok", "Jakarta", "Bogor", "Tangerang", "Bekasi"];

  // Gunakan IP 10.0.2.2 jika pakai Emulator Android
  final String baseUrl = "http://10.0.2.2:8000"; 

  Future<List<Community>> fetchCommunities(CookieRequest request) async {
    final response = await request.get('$baseUrl/community/api/communities/');
    
    List<Community> listCommunity = [];
    for (var d in response) {
      if (d != null) {
        listCommunity.add(Community.fromJson(d));
      }
    }
    return listCommunity;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, size: 28),
                    onPressed: () {
                      // Handle menu if needed
                    },
                  ),
                  const Text(
                    "Username",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=12"), // Placeholder
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2. Hero Section
                    Container(
                      margin: const EdgeInsets.all(16.0),
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: const DecorationImage(
                          image: NetworkImage("https://images.unsplash.com/photo-1517649763962-0c623066013b?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80"),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black.withValues(alpha: 0.1), Colors.black.withValues(alpha: 0.6)],
                          ),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        alignment: Alignment.bottomLeft,
                        child: const Text(
                          "Bergabung dengan Komunitas\nOlahraga Terdekatmu!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),

                    // 3. Search & Filter Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Cari Komunitas",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8B9E6D), // Olive green
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value.toLowerCase();
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Ketikkan nama komunitas..',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildDropdown(_selectedCategory, _categories, (val) {
                                setState(() => _selectedCategory = val!);
                              }),
                              const SizedBox(width: 12),
                              _buildDropdown(_selectedLocation, _locations, (val) {
                                setState(() => _selectedLocation = val!);
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 4. Community List
                    FutureBuilder(
                      future: fetchCommunities(request),
                      builder: (context, AsyncSnapshot snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text("Tidak ada data komunitas."),
                          ));
                        } else {
                          List<Community> communities = snapshot.data!;
                          List<Community> filteredCommunities = communities.where((c) {
                            bool matchCategory = _selectedCategory == "Jenis Olahraga" || 
                                                 c.sportsType.toLowerCase() == _selectedCategory.toLowerCase();
                            bool matchLocation = _selectedLocation == "Filter Lokasi" ||
                                                 c.location.toLowerCase().contains(_selectedLocation.toLowerCase());
                            bool matchSearch = c.communityName.toLowerCase().contains(_searchQuery);
                            
                            return matchCategory && matchLocation && matchSearch;
                          }).toList();

                          if (filteredCommunities.isEmpty) {
                             return const Center(child: Padding(
                               padding: EdgeInsets.all(20.0),
                               child: Text("Komunitas tidak ditemukan."),
                             ));
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredCommunities.length,
                            itemBuilder: (_, index) {
                              final community = filteredCommunities[index];
                              return CommunityCard(community: community);
                            },
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String value, List<String> items, ValueChanged<String?> onChanged) {
    return Expanded(
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 1.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: items.contains(value) ? value : items.first,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 13),
            onChanged: onChanged,
            items: items.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}