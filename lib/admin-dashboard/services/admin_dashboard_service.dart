import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:lapangin_mobile/config.dart';
import 'package:lapangin_mobile/admin-dashboard/models/dashboard_stats.dart';
import 'package:lapangin_mobile/admin-dashboard/services/booking_service.dart';

class AdminDashboardService {
  Future<DashboardStats> getDashboardStats(CookieRequest request) async {
    try {
      // Fetch all stats in parallel
      final results = await Future.wait([
        AdminBookingService.getLapanganList(request),
        AdminBookingService.getPendingBookings(request),
        request.get('${Config.baseUrl}${Config.communityListEndpoint}'),
      ]);

      final lapanganList = results[0] as List;
      final pendingBookings = results[1] as List;
      final communityById = results[2] as List; // The endpoint returns a list of communities

      return DashboardStats(
        totalFields: lapanganList.length,
        pendingBookings: pendingBookings.length,
        activeCommunities: communityById.length,
      );
    } catch (e) {
      print("❌ Error fetching dashboard stats: $e");
      // Fallback to 0 or rethrow depending on desired UX
      // For now, return 0s so the UI at least loads
      return DashboardStats(
        totalFields: 0,
        pendingBookings: 0,
        activeCommunities: 0,
      );
    }
  }
}
