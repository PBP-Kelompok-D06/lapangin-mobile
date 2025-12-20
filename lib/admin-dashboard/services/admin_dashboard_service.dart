import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:lapangin_mobile/config.dart';
import 'package:lapangin_mobile/admin-dashboard/models/dashboard_stats.dart';
import 'package:lapangin_mobile/admin-dashboard/services/booking_service.dart';

class AdminDashboardService {
  Future<DashboardStats> getDashboardStats(CookieRequest request) async {
    int totalFields = 0;
    int pendingBookings = 0;
    int activeCommunities = 0;

    // 1. Fetch Lapangan
    try {
      final lapanganList = await AdminBookingService.getLapanganList(request);
      totalFields = lapanganList.length;
    } catch (e) {
      print("❌ Error fetching fields: $e");
    }

    // 2. Fetch Pending Bookings
    try {
      final pendingList = await AdminBookingService.getPendingBookings(request);
      pendingBookings = pendingList.length;
    } catch (e) {
      print("❌ Error fetching pending bookings: $e");
    }

    // 3. Fetch Communities
    try {
      final response = await request.get('${Config.baseUrl}${Config.adminCommunityListEndpoint}?format=json');
      if (response is Map && response.containsKey('data')) {
        activeCommunities = (response['data'] as List).length;
      } else if (response is List) {
        activeCommunities = response.length;
      }
    } catch (e) {
      print("❌ Error fetching communities: $e");
    }

    return DashboardStats(
      totalFields: totalFields,
      pendingBookings: pendingBookings,
      activeCommunities: activeCommunities,
    );
  }

  Future<List<dynamic>> fetchAdminCommunities(CookieRequest request) async {
    try {
      final response = await request.get('${Config.baseUrl}${Config.adminCommunityListEndpoint}?format=json');
      if (response is Map && response.containsKey('data')) {
        return response['data'] as List<dynamic>;
      } else if (response is List) {
         return response;
      }
      return [];
    } catch (e) {
      print("Error fetching admin communities: $e");
      return [];
    }
  }
}
