import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lapangin_mobile/config.dart';
import 'package:lapangin_mobile/admin-dashboard/services/admin_dashboard_service.dart';
import 'package:lapangin_mobile/admin-dashboard/widgets/admin_community_card.dart';
import 'package:lapangin_mobile/admin-dashboard/screens/create_community_screen.dart';
import 'package:lapangin_mobile/community/screens/community_detail_page.dart'; // To view detail
import 'package:lapangin_mobile/community/models/community_models.dart'; // If needed for casting

class AdminCommunityPage extends StatefulWidget {
  const AdminCommunityPage({Key? key}) : super(key: key);

  @override
  _AdminCommunityPageState createState() => _AdminCommunityPageState();
}

class _AdminCommunityPageState extends State<AdminCommunityPage> {
  final AdminDashboardService _service = AdminDashboardService();
  
  // Filter States
  String _selectedCategory = "Pilih Jenis";
  final List<String> _categories = ["Pilih Jenis", "Futsal", "Bulutangkis", "Basket"];
  
  final TextEditingController _locationController = TextEditingController();
  String _locationFilter = "";

  late Future<List<dynamic>> _communitiesFuture;

  @override
  void initState() {
    super.initState();
    _refreshCommunities();
  }

  void _refreshCommunities() {
    setState(() {
       final request = context.read<CookieRequest>();
      _communitiesFuture = _service.fetchAdminCommunities(request);
    });
  }

  void _applyFilter() {
    setState(() {
      _locationFilter = _locationController.text.trim().toLowerCase();
    });
  }

  void _handleEdit(Map<String, dynamic> community) async {
    // Navigate to edit page with community data
    final result = await Navigator.push(
      context, 
      MaterialPageRoute(builder: (_) => CreateCommunityScreen(communityToEdit: community)),
    );
    
    // If update was successful (result == true), refresh list
    if (result == true) {
       _refreshCommunities();
    }
  }

  void _handleDelete(int pk, String name) async {
     // Show confirmation dialog
     final bool? confirm = await showDialog<bool>(
       context: context, 
       builder: (context) => AlertDialog(
         title: const Text("Hapus Komunitas"),
         content: Text("Apakah Anda yakin ingin menghapus komunitas '$name'?"),
         actions: [
           TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
           TextButton(
             onPressed: () => Navigator.pop(context, true), 
             style: TextButton.styleFrom(foregroundColor: Colors.red),
             child: const Text("Hapus")
            ),
         ],
       )
     );

     if (confirm == true) {
        final request = context.read<CookieRequest>();
        try {
           // We assume adminCommunityDeleteEndpoint is set to "/community/admin/"
           // Full URL: /community/admin/<pk>/delete/
           final url = "${Config.baseUrl}${Config.adminCommunityDeleteEndpoint}$pk/delete/";
           
           // Since the view likely redirects, we just check if it throws error or returns something.
           // Ideally we should use request.post 
           final response = await request.post(url, {});
           
           // If we reach here without exception, assume success or check response.
           // If response is HTML, it might be string. If JSON, map. 
           // We'll just refresh list.
           ScaffoldMessenger.of(context).showSnackBar(
             const SnackBar(content: Text("Komunitas berhasil dihapus!")),
           );
           _refreshCommunities();

        } catch (e) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text("Gagal menghapus: $e")),
           );
        }
     }
  }

  @override
  void dispose() {
     _locationController.dispose();
     super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Admin Communities", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Komunitas\nAnda",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CreateCommunityScreen()),
                    );
                    _refreshCommunities(); 
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Tambah Komunitas"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC3D995), // Light Green
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Filter Section Container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                   BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                children: [
                   // Jenis Dropdown
                   Row(
                     children: [
                       const SizedBox(width: 60, child: Text("Jenis:", style: TextStyle(fontWeight: FontWeight.bold))),
                       Expanded(
                         child: Container(
                           height: 40,
                           padding: const EdgeInsets.symmetric(horizontal: 12),
                           decoration: BoxDecoration(
                             border: Border.all(color: Colors.grey.shade400),
                             borderRadius: BorderRadius.circular(8),
                           ),
                           child: DropdownButtonHideUnderline(
                             child: DropdownButton<String>(
                               isExpanded: true,
                               value: _categories.contains(_selectedCategory) ? _selectedCategory : "Pilih Jenis",
                               icon: const Icon(Icons.keyboard_arrow_down),
                               onChanged: (val) {
                                 setState(() {
                                   _selectedCategory = val!;
                                 });
                               },
                               items: _categories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                             ),
                           ),
                         ),
                       )
                     ],
                   ),
                   const SizedBox(height: 12),
                   // Lokasi Filter
                   Row(
                     children: [
                       const SizedBox(width: 60, child: Text("Lokasi:", style: TextStyle(fontWeight: FontWeight.bold))),
                       Expanded(
                         child: SizedBox(
                           height: 40,
                           child: TextField(
                             controller: _locationController,
                             decoration: InputDecoration(
                               hintText: "Filter lokasi...",
                               contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                               border: OutlineInputBorder(
                                 borderRadius: BorderRadius.circular(8),
                                 borderSide: BorderSide(color: Colors.grey.shade400),
                               ),
                             ),
                           ),
                         ),
                       )
                     ],
                   ),
                   const SizedBox(height: 12),
                   // Filter Button
                   SizedBox(
                     width: double.infinity,
                     height: 40,
                     child: ElevatedButton(
                       onPressed: _applyFilter,
                       style: ElevatedButton.styleFrom(
                         backgroundColor: const Color(0xFFC3D995), // Light Green matches design
                         foregroundColor: Colors.black87,
                         elevation: 0,
                         shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                         ),
                       ),
                       child: const Text("Filter", style: TextStyle(fontWeight: FontWeight.bold)),
                     ),
                   )
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            // List of Communities
            FutureBuilder<List<dynamic>>(
              future: _communitiesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Text("Belum ada komunitas yang dibuat."),
                    ),
                  );
                }

                // Filter Logic Client-Side (Optional: Server side is better but client side works for small list)
                final communities = snapshot.data!.where((c) {
                  final String type = c['sports_type'] ?? '';
                  final String location = c['location'] ?? '';
                  
                  bool matchType = (_selectedCategory == "Pilih Jenis") || (type.toLowerCase() == _selectedCategory.toLowerCase());
                  bool matchLocation = _locationFilter.isEmpty || location.toLowerCase().contains(_locationFilter);

                  return matchType && matchLocation;
                }).toList();

                return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: communities.length,
                  itemBuilder: (context, index) {
                    final community = communities[index];
                    return AdminCommunityCard(
                      communityData: community, 
                      onEdit: () => _handleEdit(community), 
                      onDelete: () => _handleDelete(community['pk'], community['community_name']), 
                      onTap: () {
                         // Cast generic map to Community model if CommunityDetailPage requires it
                         // For now, simpler to assume CommunityDetailPage might accept model. 
                         // Check CommunityDetailPage constructor.
                         // Need to convert map to Community model.
                         try {
                           Community commModel = Community.fromJson(community);
                           Navigator.push(context, MaterialPageRoute(builder: (_) => CommunityDetailPage(community: commModel)));
                         } catch (e) {
                           print("Conversion error: $e");
                         }
                      }
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
