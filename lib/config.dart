// lapangin/lib/config.dart
class Config {
  // Set to true for Development (Local), false for Production (PWS)
  static const bool isDev = true; 
  
  static const String _pwsUrl = "https://zibeon-jonriano-lapangin2.pbp.cs.ui.ac.id";
  static const String _localUrl = "http://localhost:8000"; // Use http://10.0.2.2:8000 for Android emulator

  static String get baseUrl => isDev ? _localUrl : _pwsUrl;
  
  // Authbooking endpoints
  static const String loginEndpoint = "/accounts/login-flutter/";
  static const String registerEndpoint = "/accounts/register-flutter/";
  static const String logoutEndpoint = "/accounts/logout-flutter/";

  // Booking endpoints
  static const String lapanganListEndpoint = "/booking/api/lapangan/";
  static const String lapanganDetailEndpoint = "/booking/api/lapangan/";
  static const String availableSlotsEndpoint = "/booking/api/slots/";
  static const String createBookingEndpoint = "/booking/api/create/";
  static const String bookingDetailEndpoint = "/booking/api/booking_detail/"; 
  static const String myBookingsEndpoint = "/booking/api/my-bookings/";
  static const String cancelBookingEndpoint = "/booking/api/booking/";
  
  // Community endpoints
  static const String communityListEndpoint = "/community/api/communities/";
  static const String adminCommunityListEndpoint = "/community/api/communities/"; 
  static const String adminCommunityEditEndpoint = "/community/admin/"; // + <pk>/edit/
  
  // Admin Dashboard
  static const String adminDashboardStatsEndpoint = "/dashboard/api/stats/";
  static const String adminPendingBookingsEndpoint = "/dashboard/api/booking/pending/";
  static const String adminBookingApproveEndpoint = "/dashboard/api/booking/"; // + <id>/approve/
  static const String adminBookingRejectEndpoint = "/dashboard/api/booking/"; // + <id>/reject/
  static const String adminTransactionListEndpoint = "/dashboard/transaksi/";
  
  // Menggunakan Hybrid View untuk operasi CRUD (Create/Update/Delete) karena API View mungkin belum stabil
  static const String adminLapanganCreateEndpoint = "/dashboard/lapangan/create/";
  static const String adminLapanganListEndpoint = "/dashboard/api/lapangan/list/"; 
  static const String adminLapanganUpdateEndpoint = "/dashboard/lapangan/"; // + <id>/update/
  static const String adminLapanganDeleteEndpoint = "/dashboard/lapangan/"; // + <id>/delete/
  static const String adminCommunityDeleteEndpoint = "/community/admin/"; 
  static const String communityPostsBase = "/community/api/community/";
  static const String communityDetailBase = "/community/api/"; // Alias for detailed actions
  static const String postOperationBase = "/community/api/post/";
  static const String createCommunityEndpoint = "/community/api/create-flutter/";
  
  // Legacy support for existing code referencing localUrl directly
  // It is recommended to use baseUrl instead
  static String get localUrl => baseUrl;
}