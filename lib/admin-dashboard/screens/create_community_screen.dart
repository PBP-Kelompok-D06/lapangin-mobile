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
  final Map<String, dynamic>? communityToEdit; 

  const CreateCommunityScreen({super.key, this.communityToEdit});

  @override
  State<CreateCommunityScreen> createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends State<CreateCommunityScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _maxMemberController;
  late TextEditingController _contactPersonController;
  late TextEditingController _contactPhoneController;
  late TextEditingController _descriptionController;

  String _sportsType = "Futsal"; // Default value matched to options options
  
  // Image Handling
  File? _imageFile; // For Mobile (Android/iOS)
  Uint8List? _webImageBytes; // For Web
  final ImagePicker _picker = ImagePicker();
  String? _existingImageUrl;

  // Dropdown Options
  final List<String> _sportsOptions = [
    'Futsal',
    'Bulutangkis',
    'Basket',
  ];

  bool _isLoading = false;

  bool _isDetailFetched = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize Controllers with default values
    _nameController = TextEditingController();
    _locationController = TextEditingController();
    _maxMemberController = TextEditingController(text: "50");
    _contactPersonController = TextEditingController();
    _contactPhoneController = TextEditingController();
    _descriptionController = TextEditingController();

    if (widget.communityToEdit != null) {
      _initEditMode(widget.communityToEdit!);
      // Fetch full details to get description if missing
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchFullDetails();
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _maxMemberController.dispose();
    _contactPersonController.dispose();
    _contactPhoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _initEditMode(Map<String, dynamic> data) {
    _nameController.text = data['community_name'] ?? "";
    _descriptionController.text = data['description'] ?? "";
    _locationController.text = data['location'] ?? "";
    _maxMemberController.text = (data['max_member'] ?? 50).toString();
    _contactPersonController.text = data['contact_person'] ?? data['contact_person_name'] ?? "";
    _contactPhoneController.text = data['contact_phone'] ?? "";
    
    // Handle Image URL Prefix
    String? imgUrl = data['image_url'];
    if (imgUrl != null && imgUrl.isNotEmpty && !imgUrl.startsWith('http')) {
        _existingImageUrl = "${Config.baseUrl}$imgUrl";
    } else {
        _existingImageUrl = imgUrl;
    }
    
    // Normalize Sports Type
    String type = data['sports_type'] ?? "Futsal";
    if (_sportsOptions.contains(type)) {
      _sportsType = type;
    } else {
        final match = _sportsOptions.firstWhere(
           (e) => e.toLowerCase() == type.toLowerCase(), 
           orElse: () => "Futsal"
        );
        _sportsType = match;
    }
  }

  Future<void> _fetchFullDetails() async {
    final request = context.read<CookieRequest>();
    final pk = widget.communityToEdit!['pk'];
    try {
      // Use standard Django JSON endpoint which returns a List
      final response = await request.get('${Config.baseUrl}/community/json/$pk/');
      
      if (response is List && response.isNotEmpty) {
         // Django serialization format: [{"model": "...", "pk": 1, "fields": {...}}]
         final fields = response[0]['fields'];
         if (fields != null) {
           // Normalize data to match _initEditMode expectations
           final Map<String, dynamic> normalizedData = {
              'community_name': fields['name'] ?? fields['community_name'],
              'description': fields['description'],
              'location': fields['location'],
              'max_member': fields['max_members'] ?? fields['max_member'], // Django model usually has 'max_members'
              'contact_person': fields['contact_person'],
              'contact_phone': fields['contact_phone'],
              'sports_type': fields['sports_type'],
              'image_url': fields['image'], // Field name in model for image
           };

           setState(() {
              _initEditMode(normalizedData);
           });
         }
      } else if (response is Map) {
         // Fallback if it somehow returns a Map (e.g. error or different serializer)
         setState(() {
            _initEditMode(response as Map<String, dynamic>);
         });
      }
    } catch (e) {
      print("Error fetching details: $e");
    }
  }

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

    // Validation: Image required only for create, optional for edit
    bool hasNewImage = (!kIsWeb && _imageFile != null) || (kIsWeb && _webImageBytes != null);
    if (!hasNewImage && widget.communityToEdit == null) {
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
      // 1. Prepare Payload
      final Map<String, dynamic> payload = {
        "community_name": _nameController.text,
        "description": _descriptionController.text,
        "location": _locationController.text,
        "sports_type": _sportsType,
        "max_member": _maxMemberController.text,
        "contact_person": _contactPersonController.text,
        "contact_phone": _contactPhoneController.text,
      };

      // 2. Handle Image
      if (hasNewImage) {
         String base64Image;
          if (kIsWeb) {
            base64Image = "data:image/jpeg;base64,${base64Encode(_webImageBytes!)}";
          } else {
            final bytes = await _imageFile!.readAsBytes();
            base64Image = "data:image/jpeg;base64,${base64Encode(bytes)}";
          }
          payload['image'] = base64Image;
          // IMPORTANT: If edit endpoint mirrors `admin_community_edit`, it might expect 'community_image' or 'image' in payload. 
          // The view: keys -> 'community_image' or 'image' from request.FILES or base64 'image' in json body. 
          // So 'image' key with base64 string should work.
      } else if (widget.communityToEdit != null) {
          // No image update
      }

      // 3. Determine URL and Method
      String url;
      if (widget.communityToEdit != null) {
         // Edit Mode
         // URL: /community/admin/<pk>/edit/ -> Force JSON
         final pk = widget.communityToEdit!['pk'];
         url = "${Config.baseUrl}${Config.adminCommunityEditEndpoint}$pk/edit/?format=json";
      } else {
         // Create Mode
         url = "${Config.baseUrl}${Config.createCommunityEndpoint}";
      }

      // 4. Send Request
      final response = await request.post(url, payload);

      setState(() {
        _isLoading = false;
      });

      // Handle Response
      // Standardize response check. If Map and status==True/true.
      bool success = false;
      String message = "";

      // Handle HTML String Response (if returned directly)
      if (response is String && response.toString().toLowerCase().contains('<!doctype html>')) {
         success = true;
         message = widget.communityToEdit != null ? "Komunitas berhasil diperbarui!" : "Komunitas berhasil dibuat!";
      } else if (response is Map) {
         if (response['status'] == true || response['status'] == 'success') {
            success = true;
            message = widget.communityToEdit != null ? "Komunitas berhasil diperbarui!" : "Komunitas berhasil dibuat!";
         } else {
            message = response['message'] ?? "Gagal menyimpan data.";
         }
      } else {
         message = "Terjadi kesalahan respon server.";
      }
      
      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        Navigator.pop(context, true); 
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }

    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Check if exception contains HTML (Success redirect disguised as error)
      if (e.toString().toLowerCase().contains('<!doctype html>')) {
         if (!mounted) return;
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("Komunitas berhasil disimpan!")),
         );
         Navigator.pop(context, true);
         return;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final isEdit = widget.communityToEdit != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? 'Edit Komunitas' : 'Tambah Komunitas',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
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
                controller: _nameController,
                decoration: _inputDecoration("Contoh: Futsal Arena Senayan"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Nama komunitas wajib diisi" : null,
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
                  if(newValue != null) setState(() => _sportsType = newValue);
                },
              ),
              const SizedBox(height: 16),

              // LOKASI
              _buildLabel("LOKASI", true),
              TextFormField(
                controller: _locationController,
                decoration: _inputDecoration("Contoh: Jakarta Selatan"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Lokasi wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              // MAKSIMAL ANGGOTA
              _buildLabel("MAKSIMAL ANGGOTA", true),
              TextFormField(
                controller: _maxMemberController,
                decoration: _inputDecoration("50"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Wajib diisi";
                  if (int.tryParse(value) == null) return "Harus berupa angka";
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // NAMA CONTACT PERSON
              _buildLabel("NAMA CONTACT PERSON", true),
              TextFormField(
                controller: _contactPersonController,
                decoration: _inputDecoration("juragan01"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Contact Person wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              // NOMOR TELEPON
              _buildLabel("NOMOR TELEPON", true),
              TextFormField(
                controller: _contactPhoneController, 
                decoration: _inputDecoration("08123456789"),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value == null || value.isEmpty ? "Nomor telepon wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              // FOTO KOMUNITAS
              _buildLabel("FOTO KOMUNITAS", !isEdit),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: (_imageFile == null && _webImageBytes == null && _existingImageUrl == null)
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
                              child: kIsWeb && _webImageBytes != null
                               ? Image.memory(
                                   _webImageBytes!,
                                   width: double.infinity,
                                   height: 200,
                                   fit: BoxFit.cover,
                                 )
                               : (_imageFile != null 
                                  ? Image.file(
                                    _imageFile!,
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  )
                                  : Image.network(
                                     _existingImageUrl!,
                                     width: double.infinity,
                                     height: 200,
                                     fit: BoxFit.cover,
                                     errorBuilder: (ctx, err, stack) => const SizedBox(
                                        height: 200, 
                                        child: Center(child: Icon(Icons.broken_image))
                                     ),
                                  )
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
                controller: _descriptionController,
                maxLines: 4,
                decoration: _inputDecoration("Ceritakan tentang komunitas ini...."),
                validator: (value) =>
                    value == null || value.isEmpty ? "Deskripsi wajib diisi" : null,
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
                            : Text(
                                isEdit ? "Simpan Perubahan" : "Simpan",
                                style: const TextStyle(fontWeight: FontWeight.bold),
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
