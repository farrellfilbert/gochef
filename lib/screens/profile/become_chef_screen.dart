import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/api_service.dart';
import '../chef_dashboard/chef_main_navigation.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class BecomeChefScreen extends StatefulWidget {
  final String userId;

  const BecomeChefScreen({super.key, required this.userId});

  @override
  State<BecomeChefScreen> createState() => _BecomeChefScreenState();
}

class _PendingCertificate {
  String title;
  String type;
  XFile? file;

  _PendingCertificate({
    required this.title,
    required this.type,
    this.file,
  });
}

class _BecomeChefScreenState extends State<BecomeChefScreen> {
  final _formKey = GlobalKey<FormState>();
  final _kitchenNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController(text: 'North Hollywood, CA');
  double _latitude = 34.1722;
  double _longitude = -118.3765;
  bool _isLoading = false;
  XFile? _kitchenImage;
  final List<_PendingCertificate> _certificates = [];

  final List<String> _certTypes = [
    'Food Safety & Hygiene',
    'Culinary Arts License',
    'Halal Accreditation',
    'Professional Chef Certification',
    'Business Permit',
    'Other Accreditation',
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _kitchenImage = picked);
    }
  }

  void _showAddCertificateDialog() {
    final titleController = TextEditingController();
    String selectedType = _certTypes.first;
    XFile? certImage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Add Certificate / Accreditation', style: AppTextStyles.headlineMd(color: Colors.white)),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    dropdownColor: AppColors.surfaceContainerHigh,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Certificate Type',
                      labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                    items: _certTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedType = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Certificate / License Title',
                      hintText: 'e.g. ServSafe Food Handler Certificate',
                      hintStyle: TextStyle(color: Colors.white38),
                      labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(source: ImageSource.gallery);
                      if (picked != null) {
                        setModalState(() => certImage = picked);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.5),
                      ),
                      child: certImage != null
                          ? Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.greenAccent, size: 24),
                                  const SizedBox(width: 8),
                                  Text('Document Image Selected', style: AppTextStyles.bodyMd(color: Colors.white)),
                                ],
                              ),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.upload_file, color: AppColors.primary, size: 30),
                                SizedBox(height: 6),
                                Text('Upload Certificate Photo / Scan', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.bold)),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (titleController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter certificate title')),
                          );
                          return;
                        }
                        setState(() {
                          _certificates.add(_PendingCertificate(
                            title: titleController.text.trim(),
                            type: selectedType,
                            file: certImage,
                          ));
                        });
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Add Certificate', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _upgradeToChef() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      String kitchenImageUrl = 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(_kitchenNameController.text)}';
      
      if (_kitchenImage != null) {
        String? uploadedUrl = await ApiService.uploadImage(_kitchenImage!);
        if (uploadedUrl != null) {
          kitchenImageUrl = uploadedUrl;
        }
      }

      // Upload certificate documents
      List<Map<String, String>> uploadedCerts = [];
      for (var cert in _certificates) {
        String certUrl = '';
        if (cert.file != null) {
          String? url = await ApiService.uploadImage(cert.file!);
          if (url != null) certUrl = url;
        }
        uploadedCerts.add({
          'title': cert.title,
          'type': cert.type,
          'url': certUrl,
        });
      }

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/upgrade_to_chef.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_id': widget.userId,
          'kitchen_name': _kitchenNameController.text.trim(),
          'kitchen_description': _descriptionController.text.trim(),
          'kitchen_avatar': kitchenImageUrl,
          'kitchen_cover': kitchenImageUrl,
          'location': _locationController.text.trim(),
          'latitude': _latitude,
          'longitude': _longitude,
          'certificates': uploadedCerts,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        if (mounted) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  const Icon(Icons.hourglass_top_rounded, color: Colors.amber, size: 28),
                  const SizedBox(width: 10),
                  Text('Application Submitted', style: AppTextStyles.headlineMd(color: Colors.white)),
                ],
              ),
              content: Text(
                'Your Chef & Kitchen application with credential certificates has been successfully submitted! Our team will review your profile details and accreditation.',
                style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Got It', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        }
      } else {
        throw Exception(data['error'] ?? 'Failed to upgrade');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.8),
        title: const Text('Become a Chef'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Open Your Kitchen',
                style: AppTextStyles.headlineLgMobile(color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              Text(
                'Turn your passion into a business. Set up your kitchen details & credentials below.',
                style: AppTextStyles.bodyLg(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 32),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
                      image: _kitchenImage != null && !kIsWeb
                          ? DecorationImage(image: FileImage(File(_kitchenImage!.path)), fit: BoxFit.cover)
                          : _kitchenImage != null && kIsWeb
                            ? DecorationImage(image: NetworkImage(_kitchenImage!.path), fit: BoxFit.cover)
                            : null,
                    ),
                    child: _kitchenImage == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, color: AppColors.primary, size: 32),
                              SizedBox(height: 4),
                              Text('Add Photo', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                            ],
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _kitchenNameController,
                style: const TextStyle(color: AppColors.onSurface),
                decoration: InputDecoration(
                  labelText: 'Kitchen Name',
                  labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
                  prefixIcon: const Icon(Icons.store, color: AppColors.primary),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
                validator: (v) => v!.isEmpty ? 'Kitchen name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                style: const TextStyle(color: AppColors.onSurface),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Kitchen Description',
                  labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.description, color: AppColors.primary),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
                validator: (v) => v!.isEmpty ? 'Description is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                style: const TextStyle(color: AppColors.onSurface),
                decoration: InputDecoration(
                  labelText: 'Kitchen Location / Address',
                  hintText: 'e.g. North Hollywood, CA',
                  labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
                  prefixIcon: const Icon(Icons.location_on, color: AppColors.primary),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
                validator: (v) => v!.isEmpty ? 'Location address is required' : null,
              ),
              const SizedBox(height: 28),
              
              // Certificates & Accreditations Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Certificates & Accreditations', style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 16)),
                  TextButton.icon(
                    onPressed: _showAddCertificateDialog,
                    icon: const Icon(Icons.add, size: 18, color: AppColors.primary),
                    label: const Text('Add Document', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Upload food safety licenses, culinary degrees, or certifications for customer trust.',
                style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant).copyWith(fontSize: 13),
              ),
              const SizedBox(height: 12),
              if (_certificates.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_user_outlined, color: Colors.white38, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No certificates added yet. Adding credentials helps build instant trust with food buyers.',
                          style: AppTextStyles.bodyMd(color: Colors.white54).copyWith(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: _certificates.asMap().entries.map((entry) {
                    final index = entry.key;
                    final cert = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified, color: Colors.amber, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(cert.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                Text(cert.type, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                            onPressed: () {
                              setState(() => _certificates.removeAt(index));
                            },
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _upgradeToChef,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: AppColors.onPrimary)
                      : Text('Open Kitchen', style: AppTextStyles.bodyLg(color: AppColors.onPrimary).copyWith(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
