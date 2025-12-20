import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../services/booking_service.dart';
import 'admin_booking_pending_page.dart';
import 'package:lapangin_mobile/admin-dashboard/widgets/admin_left_drawer.dart';

class AdminTransactionHistoryPage extends StatefulWidget {
  const AdminTransactionHistoryPage({super.key});

  @override
  State<AdminTransactionHistoryPage> createState() => _AdminTransactionHistoryPageState();
}

class _AdminTransactionHistoryPageState extends State<AdminTransactionHistoryPage> {
  // 'PAID' | 'CANCELLED' | '' (All)
  String _selectedFilter = 'PAID'; 
  
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final request = context.read<CookieRequest>();
    try {
      // Pass filter to API
      final result = await AdminBookingService.getTransactionHistory(
        request, 
        statusFilter: _selectedFilter
      );
      
      if (mounted) {
        setState(() {
          _data = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }
  
  void _onFilterChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedFilter = newValue;
      });
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine counts from summary or current list?
    // API returns summary object: {paid: X, cancelled: Y} regardless of filter?
    // Let's assume API implementation returns full summary if possible, or we rely on what we have.
    // The implementation of `transaksi_list` in provided generic views usually filters the list but might calculate summary based on base query.
    // Logic: 
    // paid_count = all_transactions_base.filter(status='PAID').count()
    // cancelled_count = all_transactions_base.filter(status='CANCELLED').count()
    // Returns full summary. Perfect.
    
    final summary = _data?['summary'] ?? {'paid': 0, 'cancelled': 0};
    final transactions = (_data?['data'] as List<dynamic>?) ?? [];
    
    return Scaffold(
      drawer: const AdminLeftDrawer(activePage: 'Riwayat Transaksi'),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Riwayat Transaksi",
          style: GoogleFonts.poppins(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _error != null 
              ? Center(child: Text("Error: $_error")) 
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // 1. Filter Section
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Filter Status:", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedFilter,
                                items: const [
                                  DropdownMenuItem(value: 'PAID', child: Text("Berhasil (PAID)")),
                                  DropdownMenuItem(value: 'CANCELLED', child: Text("Gagal (CANCELLED)")),
                                  DropdownMenuItem(value: '', child: Text("Semua")),
                                ], 
                                onChanged: _onFilterChanged,
                                style: GoogleFonts.poppins(color: Colors.black, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      // Total Transaksi Label
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Total Transaksi: ${transactions.length}", 
                          style: GoogleFonts.poppins(color: Colors.green[800], fontWeight: FontWeight.bold)
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // 2. Summary Cards
                      _buildSummaryCard(
                        "Booking Berhasil", 
                        summary['paid'].toString(), 
                        Colors.green.shade50, 
                        Colors.green, 
                        Icons.check_circle_outline
                      ),
                      const SizedBox(height: 12),
                      _buildSummaryCard(
                        "Total Dibatalkan", // "Total Pending" in mock image seems wrong contextually with red X, renamed to Dibatalkan/Cancelled as per Request logic
                        summary['cancelled'].toString(), 
                        Colors.red.shade50, 
                        Colors.red, 
                        Icons.close
                      ),
                      const SizedBox(height: 20),
                      
                      // 3. Transaction List
                      if (transactions.isEmpty)
                        _buildEmptyState()
                      else
                        ...transactions.map((t) => _buildTransactionCard(t)),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.assignment_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Belum Ada Transaksi",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B), // Slate 800
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Belum ada booking yang selesai atau dibatalkan",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF64748B), // Slate 500
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const AdminBookingPendingPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFA3D179), // Light Green
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "Lihat Booking Masuk",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, String value, Color bgColor, Color iconColor, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: iconColor, width: 4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor),
              const SizedBox(width: 8),
              Text(title,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, color: Colors.black87)),
            ],
          ),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: iconColor)),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    // API returns: id, user, lapangan (string), tanggal, jam, total_bayar, status, tanggal_booking
    
    final id = transaction['id'];
    final namaLapangan = transaction['lapangan'] ?? 'Unknown';
    // Jenis Olahraga not explicitly returned in the simple JSON? 
    // Wait, API implementation for list:
    // 'lapangan': t.slot.lapangan.nama_lapangan, ... 
    // It does not return jenis_olahraga separately in the API code provided?
    // API Code:
    /*
        data.append({
            'lapangan': t.slot.lapangan.nama_lapangan,
            ...
        })
    */
    // So 'jenis_olahraga' is missing! mock image has it.
    // I can infer or just hide it? Or user might want to update API?
    // I'll assume 'namaLapangan' might contain it or just display empty/placeholder if not available.
    // Actually, `lapangan` field is just the name.
    
    final pemesan = transaction['user'] ?? 'Unknown';
    final tanggal = transaction['tanggal'] ?? '-';
    final jam = transaction['jam'];
    final totalBayar = transaction['total_bayar']; // int/double/string
    final status = transaction['status']; // 'PAID' or 'CANCELLED'

    final isPaid = status == 'PAID';
    final statusColor = isPaid ? const Color(0xFFA3D179) : Colors.red.shade300; // Light Green match
    final statusText = isPaid ? "Paid" : "Cancelled";
    final labelColor = isPaid ? Colors.white : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            "#$id | $namaLapangan",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          // Subheader (removed jenis since not in API data)
          
          const SizedBox(height: 12),
          
          RichText(
            text: TextSpan(
              style: GoogleFonts.poppins(color: Colors.black, fontSize: 14),
              children: [
                const TextSpan(text: "Pemesan : ", style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: "$pemesan\n"),
                TextSpan(text: "$tanggal ($jam)", style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "#Rp ${totalBayar.toString()}", // Mock uses #Harga, so I assume formatting
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green[800]), // Darker green for price
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.poppins(
                      color: labelColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
