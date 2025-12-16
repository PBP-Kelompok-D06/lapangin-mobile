import 'package:flutter/material.dart';

class BookingAlertBanner extends StatelessWidget {
  final int pendingCount;
  final VoidCallback onTap;

  const BookingAlertBanner({
    super.key,
    required this.pendingCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (pendingCount == 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F1), // Light orange background from design
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: const Color(0xFFFF7A00),
            width: 3,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              Icons.info_outline_rounded,
              color: const Color(0xFFFF7A00),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Ada $pendingCount Booking Menunggu Approval!",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B4500),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Segera approve atau tolak booking untuk menghindari pembatalan otomatis.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFC88A5C),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7A00),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              minimumSize: const Size(0, 36),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text(
              "Lihat\nSekarang",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
