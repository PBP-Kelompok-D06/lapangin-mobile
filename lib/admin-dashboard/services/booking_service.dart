import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:lapangin_mobile/config.dart';

class AdminBookingService {
  /// Get Pending Bookings
  static Future<List<Map<String, dynamic>>> getPendingBookings(
    CookieRequest request
  ) async {
    try {
      final responseData = await request.get('${Config.baseUrl}/dashboard/api/booking/pending/');
      
      print('🔵 Get Pending Bookings Response: $responseData');
      
      if (responseData['status'] != 'success') {
        throw Exception(responseData['message'] ?? 'Gagal mengambil data booking');
      }
      
      return List<Map<String, dynamic>>.from(responseData['data']);
      
    } catch (e) {
      print('❌ Get Pending Bookings Error: $e');
      rethrow;
    }
  }
  
  /// Approve Booking
  static Future<void> approveBooking(
    int bookingId,
    CookieRequest request
  ) async {
    try {
      final responseData = await request.post(
        '${Config.baseUrl}/dashboard/api/booking/$bookingId/approve/',
        {}
      );
      
      print('🔵 Approve Booking Response: $responseData');
      
      if (responseData['status'] != 'success') {
        throw Exception(responseData['message'] ?? 'Gagal approve booking');
      }
      
    } catch (e) {
      print('❌ Approve Booking Error: $e');
      rethrow;
    }
  }
  
  /// Reject Booking
  static Future<void> rejectBooking(
    int bookingId,
    CookieRequest request
  ) async {
    try {
      final responseData = await request.post(
        '${Config.baseUrl}/dashboard/api/booking/$bookingId/reject/',
        {}
      );
      
      print('🔵 Reject Booking Response: $responseData');
      
      if (responseData['status'] != 'success') {
        throw Exception(responseData['message'] ?? 'Gagal reject booking');
      }
      
    } catch (e) {
      print('❌ Reject Booking Error: $e');
      rethrow;
    }
  }
  
  /// Get Lapangan List
  static Future<List<Map<String, dynamic>>> getLapanganList(
    CookieRequest request
  ) async {
    try {
      final responseData = await request.get('${Config.baseUrl}/dashboard/api/lapangan/list/');
      
      print('🔵 Get Lapangan List Response: $responseData');
      
      if (responseData['status'] != 'success') {
        throw Exception(responseData['message'] ?? 'Gagal mengambil data lapangan');
      }
      
      return List<Map<String, dynamic>>.from(responseData['data']);
      
    } catch (e) {
      print('❌ Get Lapangan List Error: $e');
      rethrow;
    }
  }
}