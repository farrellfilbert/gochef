import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../services/api_service.dart';
import '../../models/menu_item_model.dart';
import 'dart:io';
import 'package:flutter/foundation.dart'; // for kIsWeb

class ChefMenuScreen extends StatefulWidget {
  const ChefMenuScreen({super.key});

  @override
  State<ChefMenuScreen> createState() => _ChefMenuScreenState();
}

class _ChefMenuScreenState extends State<ChefMenuScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  List<MenuItemModel> _menuItems = [];
  int _kitchenId = 1; // Default kitchen ID, in a real app this comes from user session

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    setState(() => _isLoading = true);
    try {
      // In a real app we'd fetch the chef's kitchen ID first. 
      // Assuming kitchenId = 1 for the demo.
      final items = await ApiService.getMenu(_kitchenId);
      setState(() {
        _menuItems = items;
      });
    } catch (e) {
      debugPrint('Error loading menu: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteDish(int id) async {
    final success = await ApiService.deleteMenuItem(id);
    if (success) {
      setState(() {
        _menuItems.removeWhere((item) => item.id == id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Dish deleted'), backgroundColor: AppColors.primary),
        );
      }
    }
  }

  void _showAddDishDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    XFile? selectedImage;
    bool isUploading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.surfaceContainerHigh,
            title: Text('Add New Dish', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        setDialogState(() {
                          selectedImage = image;
                        });
                      }
                    },
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.outlineVariant),
                      ),
                      child: selectedImage == null
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, color: AppColors.primary, size: 32),
                                SizedBox(height: 8),
                                Text('Tap to pick image', style: TextStyle(color: AppColors.onSurfaceVariant)),
                              ],
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: kIsWeb 
                                  ? Image.network(selectedImage!.path, fit: BoxFit.cover)
                                  : Image.file(File(selectedImage!.path), fit: BoxFit.cover),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: AppColors.onSurface),
                    decoration: const InputDecoration(
                      labelText: 'Dish Name',
                      labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descriptionController,
                    style: const TextStyle(color: AppColors.onSurface),
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: priceController,
                    style: const TextStyle(color: AppColors.onSurface),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Price',
                      labelStyle: TextStyle(color: AppColors.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isUploading ? null : () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: AppColors.onSurfaceVariant)),
              ),
              ElevatedButton(
                onPressed: isUploading ? null : () async {
                  if (nameController.text.isEmpty || priceController.text.isEmpty || selectedImage == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Name, price and image are required!')),
                    );
                    return;
                  }

                  setDialogState(() => isUploading = true);

                  try {
                    // Upload Image
                    String? imageUrl = await ApiService.uploadImage(selectedImage!);

                    if (imageUrl != null) {
                      // Save Menu Item
                      bool success = await ApiService.createMenuItem({
                        'kitchen_id': _kitchenId,
                        'category_id': 1, // Default category
                        'name': nameController.text,
                        'description': descriptionController.text,
                        'price': double.parse(priceController.text),
                        'image': imageUrl,
                        'is_popular': 0,
                      });

                      if (success) {
                        Navigator.pop(context);
                        _loadMenu();
                      } else {
                        throw Exception('Failed to save menu item');
                      }
                    } else {
                      throw Exception('Failed to upload image');
                    }
                  } catch (e) {
                    setDialogState(() => isUploading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: isUploading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                  : const Text('Save', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface.withValues(alpha: 0.8),
        elevation: 0,
        title: const Text('Menu Management', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory_2, color: AppColors.primary),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
        : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search and Actions
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: AppTextStyles.bodyMd(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search your creations...',
                        hintStyle: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5)),
                        prefixIcon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.magentaGloss,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: MaterialButton(
                  onPressed: _showAddDishDialog,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add, color: Colors.white),
                      const SizedBox(width: 8),
                      Text('ADD NEW DISH', style: AppTextStyles.labelMono(color: Colors.white).copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Menu Grid
            if (_menuItems.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Text('No menu items found. Add some!', style: AppTextStyles.bodyLg(color: AppColors.onSurfaceVariant)),
              )
            else
              ..._menuItems.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildDishCard(
                    id: item.id,
                    title: item.name,
                    description: item.description,
                    price: '\$${item.price.toStringAsFixed(2)}',
                    imagePath: item.image,
                    inventory: 'In stock',
                    isActive: true,
                  ),
                );
              }),
            
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildDishCard({
    required int id,
    required String title,
    required String description,
    required String price,
    required String imagePath,
    required String inventory,
    Color? inventoryColor,
    required bool isActive,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Opacity(
        opacity: isActive ? 1.0 : 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  imagePath,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(height: 160, color: AppColors.surfaceContainer),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.black45,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.black45,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.delete, size: 16, color: AppColors.error),
                          onPressed: () => _deleteDish(id),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.4)),
                    ),
                    child: Text(price, style: AppTextStyles.labelMono(color: AppColors.primary)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.headlineMd(color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant.withValues(alpha: 0.8)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  Divider(color: AppColors.outlineVariant.withValues(alpha: 0.1)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('INVENTORY', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                          Text(inventory, style: AppTextStyles.bodyMd(color: inventoryColor ?? Colors.white)),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Active', style: AppTextStyles.labelSm(color: AppColors.onSurfaceVariant)),
                          const SizedBox(width: 8),
                          Switch(
                            value: isActive,
                            onChanged: (bool value) {},
                            activeColor: AppColors.primary,
                            activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
