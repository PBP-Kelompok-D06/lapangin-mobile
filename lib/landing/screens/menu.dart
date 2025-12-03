import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lapangin/community/screens/community_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) {
        CookieRequest request = CookieRequest();
        return request;
      },
      child: MaterialApp(
        title: 'Lapangin',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E88E5)),
          useMaterial3: true,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lapangin Mobile', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E88E5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Selamat Datang di Lapangin!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            // Grid Menu Sederhana
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  // Tombol Menu Komunitas
                  _buildMenuCard(
                    context, 
                    "Komunitas", 
                    Icons.groups, 
                    const Color(0xFF1E88E5),
                    () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CommunityPage()))
                  ),

                  // Tombol Admin Dashboard
                  _buildMenuCard(
                    context, 
                    "Admin Dashboard", 
                    Icons.admin_panel_settings, 
                    const Color(0xFFC4DA6B), 
                    () {
                      // Menggunakan named route yang didefinisikan di main.dart
                      Navigator.pushNamed(context, '/admin-login');
                    }
                  ),
                  
                  // Tombol Logout
                  _buildMenuCard(context, "Logout", Icons.logout, Colors.red, () async {
                    final request = Provider.of<CookieRequest>(context, listen: false);
                    final response = await request.logout("http://zibeon-jonriano-lapangin2.pbp.cs.ui.ac.id/accounts/logout-flutter/");
                    
                    if (context.mounted) {
                      String message = response["message"];
                      if (response['status']) {
                        String uname = response["username"];
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text("$message Sampai jumpa, $uname."),
                        ));
                        // Navigate back to login page
                        Navigator.pushReplacementNamed(context, '/login');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(message),
                        ));
                      }
                    }
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.white),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}