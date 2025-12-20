import 'package:flutter/material.dart';
import 'package:lapangin_mobile/admin-dashboard/screens/admin_dashboard_page.dart';
import 'package:lapangin_mobile/admin-dashboard/screens/admin_field_page.dart';
import 'package:lapangin_mobile/admin-dashboard/screens/admin_booking_pending_page.dart';
import 'package:lapangin_mobile/admin-dashboard/screens/admin_transaction_history_page.dart';
import 'package:lapangin_mobile/admin-dashboard/screens/admin_community_page.dart';

class AdminLeftDrawer extends StatelessWidget {
  final String activePage;

  const AdminLeftDrawer({super.key, required this.activePage});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFF556B48), // Dark Green Background
        child: SafeArea(
          child: Column(
            children: [
              // Custom Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                         Icon(Icons.settings, color: Colors.white, size: 24), // Using settings icon as placeholder for the one in image if generic
                         SizedBox(width: 10),
                         Text(
                          "Dashboard",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              
              // Menu Items
              _buildMenuItem(
                context,
                title: "Home",
                icon: Icons.dashboard, 
                isSelected: activePage == 'Home',
                onTap: () {
                  Navigator.pop(context); // Close drawer
                  if (activePage != 'Home') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminDashboardPage()),
                    );
                  }
                },
              ),
              _buildMenuItem(
                context,
                title: "Lapangan",
                icon: Icons.stadium, 
                isSelected: activePage == 'Lapangan',
                onTap: () {
                  Navigator.pop(context);
                  if (activePage != 'Lapangan') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminFieldPage()),
                    );
                  }
                },
              ),
              _buildMenuItem(
                context,
                title: "Booking Masuk",
                icon: Icons.access_time_filled,
                isSelected: activePage == 'Booking Masuk',
                onTap: () {
                  Navigator.pop(context);
                  if (activePage != 'Booking Masuk') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminBookingPendingPage()),
                    );
                  }
                },
              ),
              _buildMenuItem(
                context,
                title: "Riwayat Transaksi",
                icon: Icons.history,
                isSelected: activePage == 'Riwayat Transaksi',
                onTap: () {
                  Navigator.pop(context);
                  if (activePage != 'Riwayat Transaksi') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminTransactionHistoryPage()),
                    );
                  }
                },
              ),
              _buildMenuItem(
                context,
                title: "Komunitas",
                icon: Icons.group,
                isSelected: activePage == 'Komunitas',
                onTap: () {
                  Navigator.pop(context);
                  if (activePage != 'Komunitas') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminCommunityPage()),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFA5C165) : Colors.transparent, // Lighter green for active
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        visualDensity: const VisualDensity(vertical: -2), // Compact
      ),
    );
  }
}
