import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:lapangin_mobile/admin-dashboard/services/booking_service.dart';
import 'package:lapangin_mobile/admin-dashboard/screens/admin_field_form_page.dart';
import 'package:lapangin_mobile/admin-dashboard/widgets/admin_field_card.dart';
import 'package:lapangin_mobile/admin-dashboard/widgets/admin_left_drawer.dart';

class AdminFieldPage extends StatefulWidget {
  const AdminFieldPage({super.key});

  @override
  State<AdminFieldPage> createState() => _AdminFieldPageState();
}

class _AdminFieldPageState extends State<AdminFieldPage> {
  // Filter states
  String _selectedType = "Pilih Jenis";
  final List<String> _types = ["Pilih Jenis", "Futsal", "Bulutangkis", "Basket"];
  
  final TextEditingController _searchController = TextEditingController();
  String _locationQuery = "";

  late Future<List<Map<String, dynamic>>> _fieldsFuture;

  @override
  void initState() {
    super.initState();
    _refreshFields();
  }

  void _refreshFields() {
    final request = context.read<CookieRequest>();
    setState(() {
      _fieldsFuture = AdminBookingService.getLapanganList(request);
    });
  }

  Future<void> _handleDelete(int pk, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Konfirmasi Hapus"),
        content: Text("Yakin ingin menghapus lapangan '$name'?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Batal")),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
         final request = context.read<CookieRequest>();
         await AdminBookingService.deleteLapangan(request, pk);
         if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lapangan berhasil dihapus")));
           _refreshFields();
         }
      } catch (e) {
         if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal menghapus: $e")));
      }
    }
  }

  void _handleEdit(Map<String, dynamic> field) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminFieldFormPage(fieldData: field)),
    );
    if (result == true) {
      _refreshFields();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminLeftDrawer(activePage: 'Lapangan'),
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Kelola Lapangan", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
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
                  "Lapangan\nAnda",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminFieldFormPage()),
                    );
                    if (result == true) {
                      _refreshFields();
                    }
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Tambah Lapangan"),
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
                               value: _types.contains(_selectedType) ? _selectedType : "Pilih Jenis",
                               icon: const Icon(Icons.keyboard_arrow_down),
                               onChanged: (val) {
                                 setState(() {
                                   _selectedType = val!;
                                 });
                               },
                               items: _types.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
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
                             controller: _searchController,
                             onChanged: (v) => setState(() => _locationQuery = v),
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
                ],
              ),
            ),
            
            const SizedBox(height: 20),
          
            // List of Fields
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _fieldsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                   return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                   return const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Text("Belum ada lapangan."),
                    )
                   );
                }

                final allFields = snapshot.data!;
                // Client-side filtering
                final filtered = allFields.where((f) {
                   final typeMatch = _selectedType == "Pilih Jenis" || 
                                     (f['jenis'] ?? f['jenis_olahraga']) == _selectedType;
                   final locMatch = (f['lokasi'] ?? '').toString().toLowerCase().contains(_locationQuery.toLowerCase());
                   return typeMatch && locMatch;
                }).toList();

                if (filtered.isEmpty) {
                   return const Center(child: Padding(padding: EdgeInsets.only(top: 40), child: Text("Tidak ada lapangan yang cocok.")));
                }

                return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final field = filtered[index];
                    return AdminFieldCard(
                      fieldData: field,
                      onEdit: () => _handleEdit(field),
                      onDelete: () => _handleDelete(field['pk'] ?? field['id'], field['nama'] ?? field['nama_lapangan']),
                      onTap: () => _handleEdit(field), 
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
