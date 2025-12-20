import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data'; // For Uint8List
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:lapangin_mobile/config.dart';
import 'package:lapangin_mobile/admin-dashboard/services/booking_service.dart';

class AdminFieldFormPage extends StatefulWidget {
  final Map<String, dynamic>? fieldData; // If null, create mode. If set, edit mode.

  const AdminFieldFormPage({super.key, this.fieldData});

  @override
  State<AdminFieldFormPage> createState() => _AdminFieldFormPageState();
}

class _AdminFieldFormPageState extends State<AdminFieldFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _facilitiesController = TextEditingController();

  String? _selectedType;
  final List<String> _typeOptions = ['Futsal', 'Bulutangkis', 'Basket'];

  // Images
  File? _imageFile1;
  Uint8List? _webImageBytes1;
  String? _existingImageUrl1;

  File? _imageFile2;
  Uint8List? _webImageBytes2;
  String? _existingImageUrl2;

  File? _imageFile3;
  Uint8List? _webImageBytes3;
  String? _existingImageUrl3;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.fieldData != null) {
      _nameController.text = widget.fieldData!['nama'] ?? widget.fieldData!['nama_lapangan'] ?? '';
      _selectedType = widget.fieldData!['jenis'] ?? widget.fieldData!['jenis_olahraga'];
      _locationController.text = widget.fieldData!['lokasi'] ?? '';
      _priceController.text = (widget.fieldData!['harga'] ?? widget.fieldData!['harga_per_jam'] ?? '').toString();
      _descController.text = widget.fieldData!['deskripsi'] ?? '';
      _facilitiesController.text = widget.fieldData!['fasilitas'] ?? '';
      
      // Existing images handling would go here if API provided them in list
      // For now, primary image might be in 'image_url'
      _existingImageUrl1 = widget.fieldData!['image_url'];
      // _existingImageUrl2/3 usually need detailed fetch or if list has them
    } else {
        // Default select first just in case or leave null for hint
    }
  }

  Future<void> _pickImage(int slot) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          if (slot == 1) _webImageBytes1 = bytes;
          if (slot == 2) _webImageBytes2 = bytes;
          if (slot == 3) _webImageBytes3 = bytes;
        });
      } else {
        setState(() {
          if (slot == 1) _imageFile1 = File(pickedFile.path);
          if (slot == 2) _imageFile2 = File(pickedFile.path);
          if (slot == 3) _imageFile3 = File(pickedFile.path);
        });
      }
    }
  }

  Future<String?> _convertImageToBase64(File? file, Uint8List? webBytes) async {
    if (kIsWeb && webBytes != null) {
      return "data:image/jpeg;base64,${base64Encode(webBytes)}";
    } else if (file != null) {
      final bytes = await file.readAsBytes();
      return "data:image/jpeg;base64,${base64Encode(bytes)}";
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih jenis lapangan")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final request = context.read<CookieRequest>();
      
      // Convert images
      final img1 = await _convertImageToBase64(_imageFile1, _webImageBytes1);
      final img2 = await _convertImageToBase64(_imageFile2, _webImageBytes2);
      final img3 = await _convertImageToBase64(_imageFile3, _webImageBytes3);

      final Map<String, dynamic> payload = {
        'nama': _nameController.text,
        'jenis': _selectedType,
        'lokasi': _locationController.text,
        'harga': _priceController.text,
        'deskripsi': _descController.text,
        'fasilitas': _facilitiesController.text,
      };

      if (img1 != null) payload['foto_utama'] = img1;
      if (img2 != null) payload['foto_2'] = img2;
      if (img3 != null) payload['foto_3'] = img3;

      bool success = false;
      String message = "";

      if (widget.fieldData == null) {
        // CREATE
        final res = await AdminBookingService.createLapangan(request, payload);
        if (res['status'] == true || res['status'] == 'success') success = true;
        message = res['message'] ?? (success ? "Lapangan berhasil dibuat!" : "Gagal membuat lapangan");
      } else {
        // EDIT
        final id = widget.fieldData!['pk'] ?? widget.fieldData!['id'];
        final res = await AdminBookingService.editLapangan(request, id, payload);
        if (res['status'] == true || res['status'] == 'success') success = true;
         message = res['message'] ?? (success ? "Lapangan berhasil diedit!" : "Gagal mengedit lapangan");
      }

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
          Navigator.pop(context, true);
        }
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }

    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- UI HELPER METHODS ---
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
              ? [const TextSpan(text: " *", style: TextStyle(color: Colors.red))]
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

  Widget _buildImagePicker(int slot, Uint8List? webBytes, File? file, String label, String? existingUrl) {
    bool hasImage = (webBytes != null || file != null || (existingUrl != null && existingUrl.isNotEmpty));

    // Determine current image provider
    ImageProvider? imageProvider;
    if (kIsWeb && webBytes != null) {
      imageProvider = MemoryImage(webBytes);
    } else if (file != null) {
      imageProvider = FileImage(file);
    } else if (existingUrl != null && existingUrl.isNotEmpty) {
      imageProvider = NetworkImage(existingUrl.startsWith('http') ? existingUrl : "${Config.baseUrl}$existingUrl");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label, slot == 1 && widget.fieldData == null), // Required only for main photo on create
        GestureDetector(
          onTap: () => _pickImage(slot),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid), 
              // Ref code uses solid, but let's use dotted for empty state often looks nicer. 
              // Ref code: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid)
              // Let's stick to Reference exactly:
              borderRadius: BorderRadius.circular(8),
            ),
            child: !hasImage
              ? SizedBox(
                  height: 180,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image, size: 50, color: Colors.grey.shade400),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFACCA69),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "Upload Foto $slot",
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text("Format: JPG, PNG (Max 5Mb)", style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                    ],
                  ),
                )
              : Column(
                  children: [
                     ClipRRect(
                       borderRadius: BorderRadius.circular(8),
                       child: SizedBox(
                         height: 180,
                         width: double.infinity,
                         child: Image(image: imageProvider!, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Center(child: Icon(Icons.broken_image))),
                       ),
                     ),
                     const SizedBox(height: 8),
                     SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _pickImage(slot),
                          icon: const Icon(Icons.camera_alt, size: 16),
                          label: Text("Ganti Foto $slot"),
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.fieldData != null;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isEdit ? "Edit Lapangan" : "Tambah Lapangan", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: BackButton(color: Colors.black, onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // NAMA FIELD
              _buildLabel("NAMA LAPANGAN", true),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration("Contoh: Futsal Arena Senayan"),
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              // JENIS FIELD
              _buildLabel("JENIS LAPANGAN", true),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: _inputDecoration("Pilih Jenis"),
                items: _typeOptions.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (v) => setState(() => _selectedType = v),
                validator: (v) => v == null ? "Wajib dipilih" : null,
              ),
              const SizedBox(height: 16),

              // LOKASI
              _buildLabel("LOKASI", true),
              TextFormField(
                controller: _locationController,
                decoration: _inputDecoration("Contoh: Jakarta Selatan"),
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              // IMAGES (1, 2, 3)
              _buildImagePicker(1, _webImageBytes1, _imageFile1, "FOTO LAPANGAN 1 (UTAMA)", _existingImageUrl1),
              _buildImagePicker(2, _webImageBytes2, _imageFile2, "FOTO LAPANGAN 2", _existingImageUrl2),
              _buildImagePicker(3, _webImageBytes3, _imageFile3, "FOTO LAPANGAN 3", _existingImageUrl3),

              // HARGA
              _buildLabel("HARGA PER JAM", true),
              TextFormField(
                controller: _priceController,
                decoration: _inputDecoration("Rp"),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              // FASILITAS
              _buildLabel("FASILITAS", true),
              TextFormField(
                 controller: _facilitiesController,
                 decoration: _inputDecoration("Contoh: Musholla, Cafe, Parkir luas..."),
                 maxLines: 2,
                 validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 16),

              // DESKRIPSI
              _buildLabel("DESKRIPSI", true),
              TextFormField(
                controller: _descController,
                decoration: _inputDecoration("Deskripsi lengkap tentang lapangan..."),
                maxLines: 4,
                validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
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
                          backgroundColor: const Color(0xFF333333),
                          side: const BorderSide(color: Color(0xFF333333)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        child: const Text("Batal", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                     child: SizedBox(
                       height: 48,
                       child: ElevatedButton(
                         onPressed: _isLoading ? null : _submit,
                         style: ElevatedButton.styleFrom(
                           backgroundColor: const Color(0xFFACCA69),
                           foregroundColor: Colors.white,
                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                           disabledBackgroundColor: Colors.grey,
                         ),
                         child: _isLoading 
                           ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                           : Text(isEdit ? "Simpan Perubahan" : "Simpan Lapangan", style: const TextStyle(fontWeight: FontWeight.bold)),
                       ),
                     ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
