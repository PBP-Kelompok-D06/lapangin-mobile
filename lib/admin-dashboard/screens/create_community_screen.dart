import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:lapangin_mobile/config.dart';

class CreateCommunityScreen extends StatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  State<CreateCommunityScreen> createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends State<CreateCommunityScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form Fields
  String _name = "";
  String _sportsType = "Badminton"; // Default value
  String _location = "";
  int _maxMember = 50; // Default value
  String _contactPerson = "";
  String _contactPhone = "";
  String _description = "";
  
  // Image Handling
  File? _imageFile; // For Mobile (Android/iOS)
  Uint8List? _webImageBytes; // For Web
  final ImagePicker _picker = ImagePicker();

  // Dropdown Options
  final List<String> _sportsOptions = [
    'Badminton',
    'Futsal',
    'Basket',
  ];

  bool _isLoading = false;

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
          _imageFile = null; 
        });
      } else {
        setState(() {
          _imageFile = File(pickedFile.path);
          _webImageBytes = null;
        });
      }
    }
  }

  Future<void> _submitForm(CookieRequest request) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if ((!kIsWeb && _imageFile == null) || (kIsWeb && _webImageBytes == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Harap upload foto komunitas.")),
      );
      return;
    }

    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Convert Image to Base64
      String base64Image;
      if (kIsWeb) {
        base64Image = "data:image/jpeg;base64,${base64Encode(_webImageBytes!)}";
      } else {
        final bytes = await _imageFile!.readAsBytes();
        base64Image = "data:image/jpeg;base64,${base64Encode(bytes)}";
      }

      // 2. Prepare JSON Data
      final Map<String, dynamic> payload = {
        "community_name": _name,
        "description": _description,
        "location": _location,
        "sports_type": _sportsType,
        "max_member": _maxMember.toString(),
        "contact_person": _contactPerson,
        "contact_phone": _contactPhone,
        "image": base64Image,
      };

      // 3. Send Request
      final response = await request.post(
        "${Config.baseUrl}${Config.createCommunityEndpoint}",
        payload,
      );

      setState(() {
        _isLoading = false;
      });

      if (response['status'] == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Komunitas berhasil dibuat!")),
        );
        Navigator.pop(context, true); // Return true to indicate success
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text(response['message'] ?? "Gagal membuat komunitas.")),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tambah Komunitas',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // NAMA KOMUNITAS
              _buildLabel("NAMA KOMUNITAS", true),
              TextFormField(
                decoration: _inputDecoration("Contoh: Futsal Arena Senayan"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Nama komunitas wajib diisi" : null,
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),

              // JENIS LAPANGAN (SPORTS TYPE)
              _buildLabel("JENIS LAPANGAN", true),
              DropdownButtonFormField<String>(
                decoration: _inputDecoration("Pilih Jenis"),
                value: _sportsType,
                items: _sportsOptions.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _sportsType = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // LOKASI
              _buildLabel("LOKASI", true),
              TextFormField(
                decoration: _inputDecoration("Contoh: Jakarta Selatan"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Lokasi wajib diisi" : null,
                onSaved: (value) => _location = value!,
              ),
              const SizedBox(height: 16),

              // MAKSIMAL ANGGOTA
              _buildLabel("MAKSIMAL ANGGOTA", true),
              TextFormField(
                initialValue: "50",
                decoration: _inputDecoration("50"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Wajib diisi";
                  if (int.tryParse(value) == null) return "Harus berupa angka";
                  return null;
                },
                onSaved: (value) => _maxMember = int.parse(value!),
              ),
              const SizedBox(height: 16),

              // NAMA CONTACT PERSON
              _buildLabel("NAMA CONTACT PERSON", true),
              TextFormField(
                decoration: _inputDecoration("juragan01"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Contact Person wajib diisi" : null,
                onSaved: (value) => _contactPerson = value!,
              ),
              const SizedBox(height: 16),

              // NOMOR TELEPON
              _buildLabel("NOMOR TELEPON", true),
              TextFormField(
                initialValue: "", 
                decoration: _inputDecoration("08123456789"),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value == null || value.isEmpty ? "Nomor telepon wajib diisi" : null,
                onSaved: (value) => _contactPhone = value!,
              ),
              const SizedBox(height: 16),

              // FOTO KOMUNITAS
              _buildLabel("FOTO KOMUNITAS", true),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: (_imageFile == null && _webImageBytes == null)
                      ? SizedBox(
                          height: 200,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image, size: 60, color: Colors.grey.shade400),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFACCA69), 
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  "Upload Foto",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Format: JPG, PNG (Max 5Mb)",
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: kIsWeb 
                               ? Image.memory(
                                   _webImageBytes!,
                                   width: double.infinity,
                                   height: 200,
                                   fit: BoxFit.cover,
                                 )
                               : Image.file(
                                    _imageFile!,
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.camera_alt, size: 18),
                                label: const Text("Ganti Foto"),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.black87,
                                  side: BorderSide(color: Colors.grey.shade400),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // DESKRIPSI
              _buildLabel("DESKRIPSI", true),
              TextFormField(
                maxLines: 4,
                decoration: _inputDecoration("Ceritakan tentang komunitas ini...."),
                validator: (value) =>
                    value == null || value.isEmpty ? "Deskripsi wajib diisi" : null,
                onSaved: (value) => _description = value!,
              ),
              const SizedBox(height: 24),

              // BUTTONS
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Color(0xFF333333),
                          side: const BorderSide(color: Color(0xFF333333)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text(
                          "Batal",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => _submitForm(request),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFACCA69),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          disabledBackgroundColor: Colors.grey,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Simpan",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isRequired) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          children: isRequired
              ? [
                  const TextSpan(
                    text: " *",
                    style: TextStyle(color: Colors.red),
                  ),
                ]
              : [],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}
