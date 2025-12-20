import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../services/booking_service.dart';
import 'admin_transaction_history_page.dart';

class AdminBookingPendingPage extends StatefulWidget {
  const AdminBookingPendingPage({super.key});

  @override
  State<AdminBookingPendingPage> createState() => _AdminBookingPendingPageState();
}

class _AdminBookingPendingPageState extends State<AdminBookingPendingPage> {
  Future<List<Map<String, dynamic>>>? _pendingBookingsFuture;

  @override
  void initState() {
    super.initState();
    _refreshBookings();
  }

  void _refreshBookings() {
    final request = context.read<CookieRequest>();
    setState(() {
      _pendingBookingsFuture = AdminBookingService.getPendingBookings(request);
    });
  }

  Future<void> _handleApprove(int id) async {
    final request = context.read<CookieRequest>();
    try {
      await AdminBookingService.approveBooking(id, request);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Booking berhasil di-approve!")),
        );
        _refreshBookings();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal approve: $e")),
        );
      }
    }
  }

  Future<void> _handleReject(int id) async {
    final request = context.read<CookieRequest>();
    try {
      await AdminBookingService.rejectBooking(id, request);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Booking berhasil ditolak!")),
        );
        _refreshBookings();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal menolak: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Booking Masuk",
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            Text(
              "Kelola booking yang menunggu approval Anda",
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _pendingBookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final bookings = snapshot.data ?? [];



          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // 1. Total Pending Card
                _buildStatCard(
                    "Total Pending",
                    bookings.length.toString(),
                    Colors.orange.shade50,
                    Colors.orange,
                    Icons.access_time),
                const SizedBox(height: 12),

                // 2. Info Card
                _buildInfoCard(
                    "Info",
                    "Booking akan otomatis dibatalkan jika tidak di-approve dalam 5 menit",
                    Colors.blue.shade50,
                    Colors.blue,
                    Icons.info_outline),
                const SizedBox(height: 12),

                // 3. Tips Card
                _buildInfoCard(
                    "Tips",
                    "Pastikan transfer sudah diterima sebelum approve",
                    Colors.green.shade50,
                    Colors.green,
                    Icons.lightbulb_outline),
                const SizedBox(height: 16),

                // 4. Booking List
                if (bookings.isEmpty)
                  _buildEmptyState()
                else
                  ...bookings.map((booking) => _buildBookingCard(booking)),
                  
                const SizedBox(height: 20),
                
                // 5. Important Info Footer (Yellow)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.yellow.shade200)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: Colors.orange[800]),
                          const SizedBox(width: 8),
                          Text("Informasi Penting", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.orange[900])),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildBulletPoint("Approve: Status booking berubah jadi PAID, slot jadi BOOKED (tidak bisa dipesan lagi)"),
                      _buildBulletPoint("Cancel: Status booking berubah jadi CANCELLED, slot kembali AVAILABLE"),
                      _buildBulletPoint("Auto-Cancel: Booking otomatis dibatalkan jika tidak di-approve dalam 5 menit"),
                      _buildBulletPoint("Verifikasi Transfer: Pastikan transfer sudah diterima sebelum approve"),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, Color bgColor, Color iconColor, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: iconColor, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: iconColor)),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
      String title, String content, Color bgColor, Color color, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(title,
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold, color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 4),
          Text(content,
              style: GoogleFonts.poppins(fontSize: 12, color: color)),
        ],
      ),
    );
  }
  
  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• ", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.orange[900])),
          Expanded(child: Text(text, style: GoogleFonts.poppins(fontSize: 11, color: Colors.orange[900]))),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    // API returns nested objects: user.username, lapangan.nama, etc.
    // Check booking_service data mapping. 
    // Wait, getPendingBookings returns raw JSON from API?
    // API 3: api_pending_bookings returns data structure:
    // { id, user: {username, email}, lapangan: {nama...}, slot: {...}, total_bayar, tanggal_booking }
    
    final id = booking['id'];
    final namaLapangan = booking['lapangan']['nama'] ?? 'Unknown Field';
    final jenisOlahraga = booking['lapangan']['jenis_olahraga'] ?? '-';
    final pemesan = booking['user']['username'] ?? 'Unknown User';
    final tanggal = booking['slot']['tanggal'] ?? '-';
    final jam = "${booking['slot']['jam_mulai']} - ${booking['slot']['jam_akhir']}";
    final totalBayar = booking['total_bayar']; // double/int

    // Format currency manually or use library. Just simple string for now.
    final hargaStr = "Rp ${totalBayar.toString()}";

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
          // Header: #ID | Name
          Text(
            "#$id | $namaLapangan",
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            "Lapangan $jenisOlahraga",
            style: GoogleFonts.poppins(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 12),
          
          // Content
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
          
          // Footer: Price + Button
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () => _handleReject(id),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text("Tolak",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _handleApprove(id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFA3D179), // Light Green from mockup
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: Text("Approve",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  ),
                ],
              )
        ],
      ),
    );
  }
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
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
                Icons.inbox_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Tidak Ada Booking Pending",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B), // Slate 800
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Semua booking sudah di-approve atau belum ada booking masuk",
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
                            const AdminTransactionHistoryPage()),
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
                  "Lihat Riwayat Transaksi",
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
}
