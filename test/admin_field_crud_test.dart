import 'package:flutter_test/flutter_test.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:lapangin_mobile/config.dart';
import 'package:lapangin_mobile/admin-dashboard/services/booking_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'dart:io';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  HttpOverrides.global = _MyHttpOverrides();

  group('Admin Field CRUD Integration Test', () {
    late CookieRequest request;
    int? createdFieldId;

    setUp(() async {
      request = CookieRequest();
    });

    test('Full Flow: Login -> Create -> List -> Delete -> Verify', () async {
      // 1. LOGIN
      print('\n--- STEP 1: LOGIN ---');
      final loginUrl = "${Config.baseUrl}/dashboard/api/login/";
      // Use standard post with JSON body because api_admin_login uses json.loads(request.body)
      final response = await request.post(loginUrl, jsonEncode({
        'username': 'juragan01',
        'password': 'AyamGoreng', 
      }));
      
      // CookieRequest returns the decoded JSON map directly
      print("Login response: $response");
      
      if (response['status'] == false) {
        fail("Login failed: ${response['message']}");
      }
      expect(response['status'], true);
      print("Login success!");

      // 2. CREATE FIELD
      print('\n--- STEP 2: CREATE FIELD ---');
      final createUrl = "${Config.baseUrl}${Config.adminLapanganCreateEndpoint}?format=json";
      final fieldData = {
        'nama': 'Test Field Automated ${DateTime.now().millisecondsSinceEpoch}',
        'jenis': 'Futsal',
        'lokasi': 'Test Location',
        'harga': '100000',
        'deskripsi': 'Created by automated test',
        'fasilitas': 'Wifi',
        // Note: Image upload simulation in simple JSON test might be skipped or need dummy base64
        // Backend handles missing image gracefully usually? Or we send a small dummy base64.
        'foto_utama': 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==', // 1x1 pixel red dot
      };

      // We use request.postJson (or post with json headers) handled by CookieRequest if usually multipart?
      // Step 626 `lapangan_create` handles `request.content_type == 'application/json'`.
      // CookieRequest.post typically sends form-data unless specified.
      // But `pbp_django_auth` postJson method exists? 
      // Let's rely on `postJson` if available or `post` with manual json dict.
      // Actually `CookieRequest.post` sends json body if data is Map.
      
      // Use Map directly so CookieRequest sends Form Data. 
      // Hybrid View handles request.POST if content_type is not json.
      final createResponse = await request.post(createUrl, fieldData);
      print("Create Response: $createResponse");
      
      // Hybrid View returns boolean 'status' and 'pk' at root
      expect(createResponse['status'], true); 
      if (createResponse['pk'] != null) {
        createdFieldId = createResponse['pk'];
      } else {
         fail("Create response did not return PK");
      }
      print("Created Field ID: $createdFieldId");

      // 3. VERIFY IN LIST
      print('\n--- STEP 3: VERIFY IN LIST ---');
      List<Map<String, dynamic>> fields = await AdminBookingService.getLapanganList(request);
      final found = fields.any((f) => f['id'] == createdFieldId);
      expect(found, true, reason: "Created field should be in the list");
      print("Field found in list!");

      // 4. DELETE FIELD
      print('\n--- STEP 4: DELETE FIELD ---');
      if (createdFieldId != null) {
        await AdminBookingService.deleteLapangan(request, createdFieldId!);
        print("Delete command executed.");
      }

      // 5. VERIFY DELETION
      print('\n--- STEP 5: VERIFY DELETION ---');
      await Future.delayed(const Duration(seconds: 2)); // Wait for server to commit/process

      // Fetch list again (service logic now includes timestamp to bust cache)
      List<Map<String, dynamic>> fieldsAfterDelete = await AdminBookingService.getLapanganList(request);
      
      print("IDs in list: ${fieldsAfterDelete.map((e) => e['id']).toList()}");
      print("Looking for ID: $createdFieldId");

      final foundAfterDelete = fieldsAfterDelete.any((f) => f['id'] == createdFieldId);
      expect(foundAfterDelete, false, reason: "Field should be gone from list after deletion");
      print("Field successfully removed from list!");

    });
  });
}

class _MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
