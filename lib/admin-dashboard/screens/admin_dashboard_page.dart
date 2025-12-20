import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lapangin_mobile/admin-dashboard/models/dashboard_stats.dart';
import 'package:lapangin_mobile/admin-dashboard/services/admin_dashboard_service.dart';
import 'package:lapangin_mobile/admin-dashboard/widgets/booking_alert_banner.dart';
import 'package:lapangin_mobile/admin-dashboard/widgets/dashboard_overview_card.dart';
import 'package:lapangin_mobile/admin-dashboard/widgets/quick_action_card.dart';
import 'package:lapangin_mobile/admin-dashboard/screens/admin_booking_pending_page.dart';
import 'package:lapangin_mobile/admin-dashboard/screens/admin_transaction_history_page.dart';
import 'package:lapangin_mobile/admin-dashboard/screens/create_community_screen.dart';
import 'package:lapangin_mobile/admin-dashboard/screens/admin_community_page.dart';
import 'package:lapangin_mobile/admin-dashboard/screens/admin_field_page.dart';
import 'package:lapangin_mobile/admin-dashboard/screens/admin_field_form_page.dart';

import 'package:lapangin_mobile/admin-dashboard/widgets/admin_left_drawer.dart';

class AdminDashboardPage extends StatefulWidget {
  final String? username;

  const AdminDashboardPage({super.key, this.username});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final AdminDashboardService _service = AdminDashboardService();
  DashboardStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    final request = context.read<CookieRequest>();
    try {
      final stats = await _service.getDashboardStats(request);
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      // Handle error
      print("Error loading dashboard stats: $e");
      setState(() => _isLoading = false);
    }
  }

  void _handleQuickAction(BuildContext context, String action) {
    print("Quick Action Tapped: $action");
    final request = context.read<CookieRequest>();
    
    switch (action) {
      case 'Tambah Lapangan':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AdminFieldFormPage()),
        ).then((_) => _fetchStats());
        break;
      case 'Approve Booking':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminBookingPendingPage(),
          ),
        ).then((_) => _fetchStats());
        break;
      case 'Lihat Transaksi':
        Navigator.push(
          context,
          MaterialPageRoute(
             builder: (context) => const AdminTransactionHistoryPage(),
          ),
        );
        break;
      case 'Buat Komunitas':
        // TODO: Navigate to Create Community Screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CreateCommunityScreen(),
          ),
        );
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background
      drawer: const AdminLeftDrawer(activePage: 'Home'),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // leading removed to use default drawer icon
        actions: [
          Row(
            children: [
              Text(
                widget.username ?? "Admin",
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                 margin: const EdgeInsets.only(right: 16),
                 child: const CircleAvatar(
                   backgroundColor: Colors.orange,
                   child: Icon(Icons.person, color: Colors.white),
                 ),
              ),
            ],
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Dashboard Overview",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2F2F2F),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Overview Cards
                  DashboardOverviewCard(
                    title: "Total",
                    count: "${_stats?.totalFields ?? 0}",
                    subtitle: "Lapangan Terdaftar",
                    icon: Icons.sports_soccer_rounded,
                    iconColor: const Color(0xFF7A8450),
                    iconBgColor: const Color(0xFFE8EFCF),
                    actionText: "Kelola",
                    onTap: () {
                       Navigator.push(
                         context, 
                         MaterialPageRoute(builder: (context) => const AdminFieldPage())
                       ).then((_) => _fetchStats());
                    },
                  ),
                  DashboardOverviewCard(
                    title: "Total",
                    count: "${_stats?.pendingBookings ?? 0}",
                    subtitle: "Booking Menunggu",
                    icon: Icons.access_time_filled_rounded,
                    iconColor: const Color(0xFFE55858),
                    iconBgColor: const Color(0xFFFFDADA),
                    actionText: "Kelola",
                    onTap: () => _handleQuickAction(context, 'Approve Booking'),
                  ),
                  DashboardOverviewCard(
                    title: "Total",
                    count: "${_stats?.activeCommunities ?? 0}",
                    subtitle: "Komunitas Aktif",
                    icon: Icons.groups_rounded,
                    iconColor: const Color(0xFF4A89DC),
                    iconBgColor: const Color(0xFFD6EAFC),
                    actionText: "Kelola",
                    onTap: () {
                       Navigator.push(
                         context, 
                         MaterialPageRoute(builder: (context) => const AdminCommunityPage())
                       ).then((_) => _fetchStats());
                    },
                  ),

                  // Alert Banner
                  BookingAlertBanner(
                    pendingCount: _stats?.pendingBookings ?? 0,
                    onTap: () => _handleQuickAction(context, 'Approve Booking'),
                  ),

                  const SizedBox(height: 8),
                  
                  const Text(
                    "Quick Actions",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2F2F2F),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Grid of Quick Actions
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.5, // Reduced height for wider look
                    children: [
                      QuickActionCard(
                        label: "Tambah\nLapangan",
                        icon: Icons.add_rounded,
                        color: const Color(0xFFA4C639), // Light green
                        onTap: () => _handleQuickAction(context, 'Tambah Lapangan'),
                      ),
                      QuickActionCard(
                        label: "Approve\nBooking",
                        icon: Icons.check_rounded,
                        color: const Color(0xFF66D52F), // Bright Green
                        onTap: () => _handleQuickAction(context, 'Approve Booking'),
                      ),
                      QuickActionCard(
                        label: "Lihat\nTransaksi",
                        icon: Icons.list_alt_rounded,
                        color: const Color(0xFF4A90E2), // Blue
                        onTap: () => _handleQuickAction(context, 'Lihat Transaksi'),
                      ),
                      QuickActionCard(
                        label: "Buat\nKomunitas",
                        icon: Icons.group_add_rounded,
                        color: const Color(0xFF3B95FF), // Another Blue
                        onTap: () => _handleQuickAction(context, 'Buat Komunitas'),
                      ),
                    ],
                  ),
                  
                  // Extra space at bottom
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
