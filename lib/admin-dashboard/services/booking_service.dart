import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:lapangin_mobile/config.dart';
import 'dart:convert';

class AdminBookingService {
  /// Get Pending Bookings
  static Future<List<Map<String, dynamic>>> getPendingBookings(
    CookieRequest request
  ) async {
    try {
      final responseData = await request.get('${Config.baseUrl}${Config.adminPendingBookingsEndpoint}?format=json');
      
      print('🔵 Get Pending Bookings Response: $responseData');
      
      bool isSuccess = false;
      if (responseData['status'] is bool) {
        isSuccess = responseData['status'];
      } else if (responseData['status'] is String) {
         isSuccess = responseData['status'] == 'success';
      }
      
      if (!isSuccess) {
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
        '${Config.baseUrl}${Config.adminBookingApproveEndpoint}$bookingId/approve/',
        {}
      );
      
      print('🔵 Approve Booking Response: $responseData');
      
      bool isSuccess = false;
      if (responseData['status'] is bool) {
        isSuccess = responseData['status'];
      } else if (responseData['status'] is String) {
         isSuccess = responseData['status'] == 'success';
      }

      if (!isSuccess) {
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
        '${Config.baseUrl}${Config.adminBookingRejectEndpoint}$bookingId/reject/',
        {}
      );
      
      print('🔵 Reject Booking Response: $responseData');
      
      bool isSuccess = false;
      if (responseData['status'] is bool) {
        isSuccess = responseData['status'];
      } else if (responseData['status'] is String) {
         isSuccess = responseData['status'] == 'success';
      }

      if (!isSuccess) {
        throw Exception(responseData['message'] ?? 'Gagal reject booking');
      }
      
    } catch (e) {
      print('❌ Reject Booking Error: $e');
      rethrow;
    }
  }

  /// Get Transaction History
  static Future<Map<String, dynamic>> getTransactionHistory(
    CookieRequest request, {
    String statusFilter = '',
  }) async {
    try {
      String url = '${Config.baseUrl}${Config.adminTransactionListEndpoint}?format=json';
      if (statusFilter.isNotEmpty) {
        url += '&status=$statusFilter';
      }
      
      final responseData = await request.get(url);
      print('🔵 Get Transaction History Response: $responseData');
      
      // Response structure: {status: True, data: [], summary: {...}}
      // Hybrid view returns 'status': True (bool)
      
      bool isSuccess = false;
      if (responseData['status'] is bool) {
        isSuccess = responseData['status'];
      } else if (responseData['status'] is String) {
        isSuccess = responseData['status'] == 'success' || responseData['status'] == 'true';
      }
      
      if (!isSuccess) {
        throw Exception(responseData['message'] ?? 'Gagal mengambil data transaksi');
      }
      
      return {
        'data': List<Map<String, dynamic>>.from(responseData['data'] ?? []),
        'summary': responseData['summary'] ?? {'paid': 0, 'cancelled': 0},
      };
      
    } catch (e) {
      print('❌ Get Transaction History Error: $e');
      rethrow;
    }
  }
  
  /// Get Lapangan List
  static Future<List<Map<String, dynamic>>> getLapanganList(
    CookieRequest request
  ) async {
    try {
      // Revert to Dashboard Endpoint (User Specific)
      // Added timestamp to prevent caching
      final responseData = await request.get('${Config.baseUrl}/dashboard/lapangan/?format=json&t=${DateTime.now().millisecondsSinceEpoch}');
      
      print('🔵 Get Lapangan List Response (Dashboard): $responseData');
      
      // Handle 'status' and 'data' envelope used by Dashboard API
      bool isSuccess = false;
      if (responseData['status'] is bool) {
        isSuccess = responseData['status'];
      } else if (responseData['status'] is String) {
        isSuccess = responseData['status'] == 'success' || responseData['status'] == 'true';
      }

      if (!isSuccess) {
        throw Exception(responseData['message'] ?? 'Gagal mengambil data lapangan');
      }

      final List<dynamic> dataList = responseData['data'] ?? [];

      // Map to match AdminFieldCard expectations
      return dataList.map<Map<String, dynamic>>((item) {
        return {
          'pk': item['pk'] ?? item['id'],
          'id': item['pk'] ?? item['id'],
          'nama_lapangan': item['nama'] ?? item['nama_lapangan'], // Dashboard usually uses 'nama'
          'lokasi': item['lokasi'],
          'harga_per_jam': item['harga'] ?? item['harga_per_jam'], // Dashboard usually uses 'harga'
          'foto_utama': item['foto_utama'] ?? item['image'] ?? item['image_url'], // Dashboard usually uses 'image_url'
          'image_url': item['image_url'] ?? item['image'] ?? item['foto_utama'],
          'rating': item['rating'],
          'jumlah_ulasan': item['jumlah_ulasan'] ?? item['review_count'] ?? 0,
          'jenis_olahraga': item['jenis'] ?? item['jenis_olahraga'], // Dashboard usually uses 'jenis'
          'fasilitas': item['fasilitas'] ?? '-',
          'deskripsi': item['deskripsi'] ?? item['description'] ?? '',
        };
      }).toList();
      
    } catch (e) {
      print('❌ Get Lapangan List Error: $e');
      rethrow;
    }
  }

  /// Get Lapangan Detail
  static Future<Map<String, dynamic>> getFieldDetail(
    CookieRequest request,
    int id,
  ) async {
    try {
      // Try fetching from the public API detail endpoint as it likely contains full info
      // Endpoint: /booking/api/lapangan/<id>/
      final response = await request.get('${Config.baseUrl}${Config.lapanganDetailEndpoint}$id/');
      
      print('🔵 Get Field Detail Response: $response');
      
      // If response is list, take first. If map, take as is.
      if (response is List && response.isNotEmpty) {
        return response[0] as Map<String, dynamic>;
      } else if (response is Map) {
         // Some endpoints wrap in {status: true, data: ...} or just return the object
         if (response.containsKey('data')) {
            return response['data'] is List ? response['data'][0] : response['data'];
         }
         return response as Map<String, dynamic>;
      }
      
      throw Exception('Format respon tidak dikenali');
      
    } catch (e) {
      print('❌ Get Field Detail Error: $e');
      rethrow;
    }
  }

  /// Create Lapangan
  static Future<Map<String, dynamic>> createLapangan(
    CookieRequest request,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await request.post(
        '${Config.baseUrl}${Config.adminLapanganCreateEndpoint}?format=json',
        data,
      );
      print('🔵 Create Lapangan Response: $response');
      if (response['status'] == false) {
         throw Exception(response['message'] ?? 'Gagal membuat lapangan');
      }
      return response;
    } catch (e) {
      print('❌ Create Lapangan Error: $e');
      rethrow;
    }
  }

  /// Edit Lapangan
  static Future<Map<String, dynamic>> editLapangan(
    CookieRequest request,
    int id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await request.post(
        '${Config.baseUrl}${Config.adminLapanganUpdateEndpoint}$id/edit/?format=json',
        jsonEncode(data)
      );
      print('🔵 Edit Lapangan Response: $response');
      if (response['status'] == false) { // status might be boolean True/False based on python code
         throw Exception(response['message'] ?? 'Gagal mengedit lapangan');
      }
      return response;
    } catch (e) {
      print('❌ Edit Lapangan Error: $e');
      rethrow;
    }
  }

  /// Delete Lapangan
  static Future<void> deleteLapangan(
    CookieRequest request,
    int id,
  ) async {
    try {
      // Delete usually uses POST in Django for safety
      final response = await request.post(
        '${Config.baseUrl}${Config.adminLapanganDeleteEndpoint}$id/delete/?format=json',
        {}
      );
       print('🔵 Delete Lapangan Response: $response');
       
       bool isSuccess = false;
       if (response['status'] is bool) {
         isSuccess = response['status'];
       } else if (response['status'] is String) {
         isSuccess = response['status'] == 'success' || response['status'] == 'true';
       }

       if (!isSuccess) {
         throw Exception(response['message'] ?? 'Gagal menghapus lapangan');
       }
    } catch (e) {
      print('🔴 Error deleting lapangan: $e');
      rethrow;
    }
  }
}