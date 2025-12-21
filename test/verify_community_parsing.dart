import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import this
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:lapangin_mobile/config.dart';

void main() {
  group('Community Parsing Verification', () {
    late CookieRequest request;

    setUp(() {
       TestWidgetsFlutterBinding.ensureInitialized();
       SharedPreferences.setMockInitialValues({}); // Mock SharedPreferences
       HttpOverrides.global = null; // Enable real HTTP requests
       request = CookieRequest();
    });

    test('Login and Parse Community Detail', () async {
      // 1. Login
      final loginResponse = await request.login(
        '${Config.baseUrl}/dashboard/api/login/', // Use Dashboard/Admin login as User login might be flaky implies
        {'username': 'juragan01', 'password': 'AyamGoreng'},
      );
      print('Login Response: $loginResponse');
      expect(loginResponse['status'], true, reason: "Login failed");

      // 2. Get Community List to find a valid ID
      final listResponse = await request.get('${Config.baseUrl}${Config.communityListEndpoint}');
      List<dynamic> communities = listResponse;
      if (communities.isEmpty) {
        print('Skipping parsing test: No communities found.');
        return;
      }
      
      int pk = communities[0]['pk'];
      print('Testing with Community ID: $pk');

      // 3. Fetch Detail using JSON endpoint (Simulating CreateCommunityScreen logic)
      final detailUrl = '${Config.baseUrl}/community/json/$pk/';
      print('Fetching from: $detailUrl');
      
      // CookieRequest automatically decodes JSON
      final response = await request.get(detailUrl);
      
      print('Response Type: ${response.runtimeType}');
      print('Response: $response');

      // 4. Verify Structure (List -> [0] -> fields)
      expect(response, isA<List>(), reason: "Response should be a List (Django serialized)");
      expect(response, isNotEmpty);
      
      final firstItem = response[0];
      expect(firstItem.containsKey('fields'), true, reason: "Item should contain 'fields' key");
      
      final fields = firstItem['fields'];
      expect(fields, isA<Map>(), reason: "'fields' should be a Map");
      
      // 5. Check critical keys needed for _initEditMode
      // 'name' or 'community_name'
      bool hasName = fields.containsKey('name') || fields.containsKey('community_name');
      expect(hasName, true, reason: "Fields must contain 'name' or 'community_name'");
      
      print('✅ Verification Successful: Parsed fields correctly.');
    });
  });
}
