import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'package:lapangin_mobile/authbooking/screens/register.dart';
import 'package:lapangin_mobile/landing/screens/menu.dart';
import 'package:lapangin_mobile/admin-dashboard/screens/admin_dashboard_screen.dart';
import 'package:lapangin_mobile/config.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final request = context.read<CookieRequest>();

      final response = await request.login(
        "${Config.localUrl}${Config.loginEndpoint}",
        {
          'username': _usernameController.text.trim(),
          'password': _passwordController.text,
        },
      );

      setState(() => _isLoading = false);

      if (request.loggedIn && response['status'] == true) {
        final role = response['role'] ?? request.jsonData['role'];
        final username =
            response['username'] ?? _usernameController.text.trim();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Selamat datang, $username!"),
            backgroundColor: Colors.green,
          ),
        );

        _navigateBasedOnRole(role, username, request);
      } else {
        _showErrorDialog(response['message'] ?? "Login gagal");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog("Tidak dapat terhubung ke server");
    }
  }

  void _navigateBasedOnRole(
    String? role,
    String username,
    CookieRequest request,
  ) {
    if (role?.toUpperCase() == 'PEMILIK') {
      final cookie = request.cookies['sessionid'];
      final sessionCookie =
          cookie != null ? 'sessionid=${cookie.value}' : '';

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AdminDashboardScreen(
            sessionCookie: sessionCookie,
            username: username,
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MyHomePage()),
      );
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Login Gagal"),
        content: Text(message),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 80),

              /// ===== HEADER =====
              Column(
                children: const [
                  Text(
                    "Login",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF383838),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Welcome back to Lapangin",
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 13,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 80),

              /// ===== FORM CARD =====
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildInput(
                        label: "Username",
                        hint: "Enter your username here",
                        controller: _usernameController,
                        validator: (v) =>
                            v == null || v.isEmpty ? "Wajib diisi" : null,
                      ),
                      const SizedBox(height: 24),
                      _buildInput(
                        label: "Password",
                        hint: "Enter your password here",
                        controller: _passwordController,
                        obscure: _obscurePassword,
                        suffix: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? "Wajib diisi" : null,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              /// ===== LOGIN BUTTON =====
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB8D279),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(strokeWidth: 2)
                      : const Text(
                          "Login",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4D5833),
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 12),

              /// ===== REGISTER BUTTON =====
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RegisterPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF383838),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text(
                    "Register",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFCFE1A5),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// ===== REUSABLE INPUT =====
  Widget _buildInput({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF839556),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            suffixIcon: suffix,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}
