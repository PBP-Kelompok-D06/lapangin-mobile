// lib/booking/widgets/booking_slot_card.dart

import 'package:flutter/material.dart';
import '../models/booking_models.dart';
import 'package:intl/intl.dart';

class BookingSlotCard extends StatelessWidget {
  final BookingSlot slot;
  final DateTime tanggal; 
  final bool isSelected;
  final VoidCallback? onTap;

  const BookingSlotCard({
    super.key,
    required this.slot,
    required this.tanggal,
    this.isSelected = false,
    this.onTap,
  });

  // Fungsi untuk format tanggal
  String _formatTanggal(DateTime date) {
    return DateFormat('d MMM').format(date);
  }

  // Fungsi untuk menentukan warna background berdasarkan status
  Color _getBackgroundColor() {
    if (slot.isAvailable) {
      return isSelected ? const Color(0xFFF0F7E6) : Colors.white;
    } else if (slot.isPending) {
      return const Color(0xFFFFF8E1); // Kuning muda
    } else {
      return const Color(0xFFFFEBEE); // Merah muda
    }
  }

  // Fungsi untuk menentukan warna border berdasarkan status
  Color _getBorderColor() {
    if (slot.isAvailable && isSelected) {
      return const Color(0xFFA7BF6E);
    } else if (slot.isAvailable) {
      return Colors.grey.shade300;
    } else if (slot.isPending) {
      return const Color(0xFFFFB300); // Kuning
    } else {
      return Colors.red.shade300;
    }
  }

  // Fungsi untuk menentukan warna badge status
  Color _getBadgeColor() {
    if (slot.isAvailable) {
      return const Color(0xFFE8F5E9); // Hijau muda
    } else if (slot.isPending) {
      return const Color(0xFFFFF9C4); // Kuning muda
    } else {
      return const Color(0xFFFFCDD2); // Merah muda
    }
  }

  // Fungsi untuk menentukan warna text badge
  Color _getBadgeTextColor() {
    if (slot.isAvailable) {
      return const Color(0xFF4CAF50); // Hijau
    } else if (slot.isPending) {
      return const Color(0xFFF57F17); // Kuning tua
    } else {
      return const Color(0xFFD32F2F); // Merah
    }
  }

  // Fungsi untuk format currency
  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: slot.isAvailable ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          border: Border.all(
            color: _getBorderColor(),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFA7BF6E).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Tanggal - FIXED: Gunakan tanggal dari slot
            Text(
              _formatTanggal(tanggal), // ✅ GUNAKAN TANGGAL DARI SLOT
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: slot.isAvailable 
                    ? Colors.grey.shade600
                    : Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 4),
            
            // Waktu
            Text(
              '${slot.jamMulai}-${slot.jamAkhir}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: slot.isAvailable 
                    ? Colors.black87
                    : Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 8),
            
            // Harga atau BOOKED
            Text(
              slot.isAvailable 
                  ? _formatCurrency(slot.harga)
                  : 'BOOKED',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: slot.isAvailable 
                    ? Colors.black87
                    : Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 8),
            
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _getBadgeColor(),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                slot.status == 'AVAILABLE' ? 'Available' : slot.status,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _getBadgeTextColor(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}