import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import 'package:lapangin_mobile/authbooking/screens/login.dart';
import 'package:lapangin_mobile/config.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nomorWhatsappController = TextEditingController();
  final _nomorRekeningController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  String _selectedRole = 'PENYEWA';

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nomorWhatsappController.dispose();
    _nomorRekeningController.dispose();
    super.dispose();
  }

  String? _validateWhatsApp(String? value) {
    if (_selectedRole != 'PEMILIK') return null;

    if (value == null || value.isEmpty) {
      return 'Nomor WhatsApp wajib diisi';
    }

    String v = value.trim();
    if (v.startsWith('0')) v = '+62${v.substring(1)}';
    if (!v.startsWith('+62')) v = '+62$v';

    if (!RegExp(r'^\+62[0-9]{8,13}$').hasMatch(v)) {
      return 'Format WhatsApp tidak valid';
    }

    return null;
  }

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    final request = context.read<CookieRequest>();
    setState(() => _isLoading = true);

    try {
      final data = {
        "username": _usernameController.text.trim(),
        "password1": _passwordController.text,
        "password2": _confirmPasswordController.text,
        "role": _selectedRole,
      };

      if (_selectedRole == 'PEMILIK') {
        data.addAll({
          "nomor_whatsapp": _nomorWhatsappController.text.trim(),
          "nomor_rekening": _nomorRekeningController.text.trim(),
        });
      }

      final response = await request.postJson(
        Config.getUrl(Config.registerEndpoint),
        jsonEncode(data),
      );

      setState(() => _isLoading = false);

      final success = response['status'] == true ||
          response['status'].toString().toLowerCase() == 'success';

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registrasi berhasil"),
            backgroundColor: Colors.green,
          ),
        );

        await Future.delayed(const Duration(seconds: 2));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? "Registrasi gagal"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Connection error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
              const SizedBox(height: 60),

              /// ===== HEADER =====
              Column(
                children: const [
                  Text(
                    "Register",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF383838),
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Create your Lapangin account",
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),

              const SizedBox(height: 48),

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
                        validator: (v) => v == null || v.length < 3
                            ? "Minimal 3 karakter"
                            : null,
                      ),
                      const SizedBox(height: 20),

                      _buildInput(
                        label: "Password",
                        hint: "Enter your password here",
                        controller: _passwordController,
                        obscure: _obscurePassword,
                        suffix: _passwordToggle(() {
                          setState(() => _obscurePassword = !_obscurePassword);
                        }),
                        validator: (v) => v == null || v.length < 8
                            ? "Minimal 8 karakter"
                            : null,
                      ),
                      const SizedBox(height: 20),

                      _buildInput(
                        label: "Confirm Password",
                        hint: "Enter your password confirmation here",
                        controller: _confirmPasswordController,
                        obscure: _obscureConfirm,
                        suffix: _passwordToggle(() {
                          setState(() => _obscureConfirm = !_obscureConfirm);
                        }),
                        validator: (v) => v != _passwordController.text
                            ? "Password tidak sama"
                            : null,
                      ),
                      const SizedBox(height: 20),

                      _buildDropdown(),

                      if (_selectedRole == 'PEMILIK') ...[
                        const SizedBox(height: 20),
                        _buildInput(
                          label: "Account Number",
                          hint: "Ex: 1234567890 - a.n Budi Santoso",
                          controller: _nomorRekeningController,
                          validator: (v) =>
                              v == null || v.isEmpty ? "Wajib diisi" : null,
                        ),
                        const SizedBox(height: 20),
                        _buildInput(
                          label: "WhatsApp Number",
                          hint: "Ex: +6281234567890",
                          controller: _nomorWhatsappController,
                          validator: _validateWhatsApp,
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              /// ===== REGISTER BUTTON =====
              _primaryButton("Register", _registerUser),

              const SizedBox(height: 12),

              /// ===== LOGIN BUTTON =====
              _secondaryButton("Login", () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              }),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  /// ===== INPUT FIELD =====
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

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Role",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF839556),
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: _selectedRole,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          items: const [
            DropdownMenuItem(value: "PENYEWA", child: Text("Penyewa Lapangan")),
            DropdownMenuItem(value: "PEMILIK", child: Text("Pemilik Lapangan")),
          ],
          onChanged: _isLoading
              ? null
              : (v) {
                  setState(() {
                    _selectedRole = v!;
                    _formKey.currentState?.validate();
                  });
                },
        ),
      ],
    );
  }

  Widget _primaryButton(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: _isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFB8D279),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(strokeWidth: 2)
            : Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4D5833),
                ),
              ),
      ),
    );
  }

  Widget _secondaryButton(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF383838),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFFCFE1A5),
          ),
        ),
      ),
    );
  }

  Widget _passwordToggle(VoidCallback onTap) {
    return IconButton(
      icon: Icon(
        _obscurePassword ? Icons.visibility_off : Icons.visibility,
        size: 20,
      ),
      onPressed: onTap,
    );
  }
}
