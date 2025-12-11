// lib/booking/screens/my_bookings_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/booking_models.dart';
import '../services/booking_service.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  List<Booking> _bookings = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _userName = "User";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setUserName();
      _loadBookings();
    });
  }

  void _setUserName() {
    final request = context.read<CookieRequest>();
    final userData = request.jsonData;

    print("--- Data User Tersimpan di CookieRequest (My Bookings Screen) ---");
    print(userData);
    print("-------------------------------------");

    const potentialKeys = ['username', 'first_name', 'name', 'fullname'];

    String? foundName;

    for (var key in potentialKeys) {
      if (userData.containsKey(key) && userData[key] != null) {
        final nameCandidate = userData[key].toString();
        if (nameCandidate.isNotEmpty) {
          foundName = nameCandidate;
          print("Ditemukan nama pengguna dengan kunci: $key. Nilai: $foundName");
          break;
        }
      }
    }
    
    if (foundName != null) {
      setState(() {
        _userName = foundName!;
      });
    }
  }

Future<void> _loadBookings() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    final request = context.read<CookieRequest>();
    
    // Gunakan metode baru dengan CookieRequest langsung
    final bookings = await BookingService.getMyBookingsWithRequest(request);
    
    setState(() {
      _bookings = bookings;
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _errorMessage = e.toString();
      _isLoading = false;
    });
    print('Error loading bookings: $e');
  }
}

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('d MMMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return "U";
    final parts = name.trim().split(' ');
    String initials = parts.first[0].toUpperCase();
    if (parts.length > 1) {
      initials += parts.last[0].toUpperCase();
    }
    return initials;
  }

  @override
  Widget build(BuildContext context) {
    String firstName = _userName.split(' ').first;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Hi, $firstName!",
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFF6B8E23),
              child: Text(
                _getInitials(_userName),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFA7BF6E)),
            )
          : _errorMessage != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadBookings,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFA7BF6E),
            ),
            child: const Text('Coba Lagi'),
          ),
          const SizedBox(height: 16),
          // Tambahkan tombol untuk kembali ke login jika session expired
          if (_errorMessage!.contains('login'))
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text('Kembali ke Login'),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pesanan Kamu',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Silahkan datang ke lokasi sesuai waktu yang\nditentukan',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _bookings.isEmpty
              ? _buildEmptyState()
              : _buildBookingsList(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada pesanan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Booking lapangan favoritmu sekarang!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList() {
    return RefreshIndicator(
      onRefresh: _loadBookings,
      color: const Color(0xFFA7BF6E),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _bookings.length,
        itemBuilder: (context, index) {
          final booking = _bookings[index];
          return _buildBookingCard(booking);
        },
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama Lapangan
          Text(
            booking.lapangan.nama,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          
          // Jenis Lapangan
          Text(
            'Lapangan Bulutangkis',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          
          // Tanggal dan Waktu
          Row(
            children: [
              Text(
                '${_formatDate(booking.slot.tanggal)} (${booking.slot.jamMulai}-${booking.slot.jamAkhir})',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Info Lokasi
          Row(
            children: [
              const Text(
                'Info Lokasi',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                booking.lapangan.lokasi,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}