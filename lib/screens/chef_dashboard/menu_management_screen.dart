import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../models/menu_item_model.dart';
import '../../models/category_model.dart';
import '../../models/menu_addon_model.dart';
import '../../services/api_service.dart';
import 'addon_category_manager.dart';
import '../../services/api_service.dart';
import '../../models/menu_item_model.dart';
import '../../models/category_model.dart';
import '../../models/menu_addon_model.dart';
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
  List<CategoryModel> _categories = [];
  int? _kitchenId;

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    setState(() => _isLoading = true);
    try {
      final categories = await ApiService.getCategories();
      
      final kitchenIdStr = await ApiService.getKitchenId();
      if (kitchenIdStr != null) {
        _kitchenId = int.tryParse(kitchenIdStr);
      }
      
      setState(() {
        _categories = categories;
      });
      
      if (_kitchenId != null) {
        final items = await ApiService.getMenuItems(kitchenId: _kitchenId!);
        setState(() {
          _menuItems = items;
        });
      } else {
        setState(() {
          _menuItems = [];
        });
        debugPrint('Kitchen ID is null');
      }
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

  InputDecoration _buildInputDecoration(String label, {IconData? prefixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
      filled: true,
      fillColor: AppColors.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.onSurfaceVariant) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  void _showEditDishDialog(MenuItemModel item) {
    final nameController = TextEditingController(text: item.name);
    final descriptionController = TextEditingController(text: item.description);
    final priceController = TextEditingController(text: item.price.toString());
    final caloriesController = TextEditingController(text: item.calories.toString());
    XFile? selectedImage;
    bool isUploading = false;
    int? selectedCategoryId = item.categoryId > 0 ? item.categoryId : (_categories.isNotEmpty ? _categories.first.id : null);
    
    List<MenuAddonCategoryModel> addonCategories = [];
    if (item.addonCategories != null) {
      addonCategories = List.from(item.addonCategories!);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: AppColors.surfaceContainerHigh,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Edit Dish', style: AppTextStyles.headlineMd(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          if (kIsWeb) {
                            setDialogState(() {
                              selectedImage = image;
                            });
                            return;
                          }
                          final croppedFile = await ImageCropper().cropImage(
                            sourcePath: image.path,
                            uiSettings: [
                              WebUiSettings(
                                context: context,
                                presentStyle: WebPresentStyle.dialog,
                              ),
                            ],
                          );
                          if (croppedFile != null) {
                            setDialogState(() {
                              selectedImage = XFile(croppedFile.path);
                            });
                          }
                        }
                      },
                      child: Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
                        ),
                        child: selectedImage == null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.network(item.image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.restaurant_menu, size: 48, color: AppColors.primary))),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: kIsWeb 
                                    ? Image.network(selectedImage!.path, fit: BoxFit.cover)
                                    : Image.file(File(selectedImage!.path), fit: BoxFit.cover),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_categories.isNotEmpty) ...[
                      DropdownButtonFormField<int>(
                        value: selectedCategoryId,
                        decoration: _buildInputDecoration('Category', prefixIcon: Icons.category),
                        dropdownColor: AppColors.surfaceContainerHigh,
                        style: const TextStyle(color: AppColors.onSurface),
                        items: _categories.map((cat) {
                          return DropdownMenuItem<int>(
                            value: cat.id,
                            child: Text(cat.name),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setDialogState(() {
                            selectedCategoryId = val;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: AppColors.onSurface),
                      decoration: _buildInputDecoration('Dish Name', prefixIcon: Icons.restaurant_menu),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      style: const TextStyle(color: AppColors.onSurface),
                      maxLines: 3,
                      decoration: _buildInputDecoration('Description').copyWith(alignLabelWithHint: true),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: priceController,
                            style: const TextStyle(color: AppColors.onSurface),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: _buildInputDecoration('Price (\$)', prefixIcon: Icons.attach_money),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: caloriesController,
                            style: const TextStyle(color: AppColors.onSurface),
                            keyboardType: TextInputType.number,
                            decoration: _buildInputDecoration('Calories (kcal)', prefixIcon: Icons.local_fire_department),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    AddonCategoryManager(
                      initialCategories: addonCategories,
                      onChanged: (categories) {
                        addonCategories = categories;
                      },
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: isUploading ? null : () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Cancel', style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isUploading ? null : () async {
                              if (nameController.text.isEmpty || priceController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Name and price are required!')),
                                );
                                return;
                              }

                              if (selectedCategoryId == null && _categories.isNotEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please select a category!')),
                                );
                                return;
                              }

                              setDialogState(() => isUploading = true);

                              try {
                                String? imageUrl;
                                if (selectedImage != null) {
                                  imageUrl = await ApiService.uploadImage(selectedImage!);
                                  if (imageUrl == null) {
                                    throw Exception('Failed to upload image');
                                  }
                                }

                                bool success = await ApiService.updateMenuItem({
                                  'id': item.id,
                                  'kitchen_id': _kitchenId,
                                  'category_id': selectedCategoryId ?? 1,
                                  'name': nameController.text,
                                  'description': descriptionController.text,
                                  'price': double.parse(priceController.text),
                                  'calories': int.tryParse(caloriesController.text) ?? 650,
                                  'image': selectedImage != null ? imageUrl : '',
                                  'addon_categories': addonCategories.map((c) => c.toJson()).toList(),
                                });

                                if (success) {
                                  Navigator.pop(context);
                                  _loadMenu();
                                } else {
                                  throw Exception('Failed to update menu item');
                                }
                              } catch (e) {
                                setDialogState(() => isUploading = false);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: isUploading 
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)) 
                              : const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  void _showAddDishDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final caloriesController = TextEditingController(text: '650');
    XFile? selectedImage;
    bool isUploading = false;
    int? selectedCategoryId = _categories.isNotEmpty ? _categories.first.id : null;
    List<MenuAddonCategoryModel> addonCategories = [];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: AppColors.surfaceContainerHigh,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Add New Dish', style: AppTextStyles.headlineMd(color: AppColors.onSurface).copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          if (kIsWeb) {
                            setDialogState(() {
                              selectedImage = image;
                            });
                            return;
                          }
                          final croppedFile = await ImageCropper().cropImage(
                            sourcePath: image.path,
                            uiSettings: [
                              WebUiSettings(
                                context: context,
                                presentStyle: WebPresentStyle.dialog,
                              ),
                            ],
                          );
                          if (croppedFile != null) {
                            setDialogState(() {
                              selectedImage = XFile(croppedFile.path);
                            });
                          }
                        }
                      },
                      child: Container(
                        height: 160,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5),
                        ),
                        child: selectedImage == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.add_a_photo, color: AppColors.primary, size: 28),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text('Tap to pick image', style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500)),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: kIsWeb 
                                    ? Image.network(selectedImage!.path, fit: BoxFit.cover)
                                    : Image.file(File(selectedImage!.path), fit: BoxFit.cover),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (_categories.isNotEmpty) ...[
                      DropdownButtonFormField<int>(
                        value: selectedCategoryId,
                        decoration: _buildInputDecoration('Category', prefixIcon: Icons.category),
                        dropdownColor: AppColors.surfaceContainerHigh,
                        style: const TextStyle(color: AppColors.onSurface),
                        items: _categories.map((cat) {
                          return DropdownMenuItem<int>(
                            value: cat.id,
                            child: Text(cat.name),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setDialogState(() {
                            selectedCategoryId = val;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: AppColors.onSurface),
                      decoration: _buildInputDecoration('Dish Name', prefixIcon: Icons.restaurant_menu),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      style: const TextStyle(color: AppColors.onSurface),
                      maxLines: 3,
                      decoration: _buildInputDecoration('Description').copyWith(alignLabelWithHint: true),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: priceController,
                            style: const TextStyle(color: AppColors.onSurface),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: _buildInputDecoration('Price (\$)', prefixIcon: Icons.attach_money),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: caloriesController,
                            style: const TextStyle(color: AppColors.onSurface),
                            keyboardType: TextInputType.number,
                            decoration: _buildInputDecoration('Calories (kcal)', prefixIcon: Icons.local_fire_department),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    AddonCategoryManager(
                      initialCategories: addonCategories,
                      onChanged: (categories) {
                        addonCategories = categories;
                      },
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: isUploading ? null : () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Cancel', style: TextStyle(color: AppColors.onSurfaceVariant, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isUploading ? null : () async {
                              if (nameController.text.isEmpty || priceController.text.isEmpty || selectedImage == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Name, price and image are required!')),
                                );
                                return;
                              }

                              if (selectedCategoryId == null && _categories.isNotEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please select a category!')),
                                );
                                return;
                              }

                              setDialogState(() => isUploading = true);

                              try {
                                // Upload Image
                                String? imageUrl = await ApiService.uploadImage(selectedImage!);

                                if (imageUrl != null) {
                                    bool success = await ApiService.createMenuItem({
                                      'kitchen_id': _kitchenId,
                                      'category_id': selectedCategoryId ?? 1,
                                      'name': nameController.text,
                                      'description': descriptionController.text,
                                      'price': double.parse(priceController.text),
                                      'calories': int.tryParse(caloriesController.text) ?? 650,
                                      'image': imageUrl,
                                      'is_popular': 0,
                                      'addon_categories': addonCategories.map((a) => a.toJson()).toList(),
                                    });

                                  if (success) {
                                    Navigator.pop(context);
                                    _loadMenu();
                                  } else {
                                    throw Exception('Failed to create dish');
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
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: isUploading 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                              : const Text('Add Dish', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
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
                    item: item,
                    id: item.id,
                    title: '${item.name} (${item.calories} calories)',
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
    required MenuItemModel item,
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
                          onPressed: () => _showEditDishDialog(item),
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
                    child: Text(
                      price,
                      style: AppTextStyles.labelMono(color: Colors.white).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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

  Widget _buildAddonCategoriesUI(List<MenuAddonCategoryModel> addonCategories, StateSetter setDialogState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Customization Groups', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
            TextButton.icon(
              onPressed: () {
                setDialogState(() {
                  addonCategories.add(MenuAddonCategoryModel(id: 0, name: '', options: []));
                });
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Group'),
            ),
          ],
        ),
        if (addonCategories.isNotEmpty)
          ...addonCategories.asMap().entries.map((catEntry) {
            int catIdx = catEntry.key;
            var cat = catEntry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: cat.name,
                          style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold),
                          decoration: const InputDecoration(hintText: 'Group Name (e.g. Size)', isDense: true),
                          onChanged: (val) {
                            cat = MenuAddonCategoryModel(id: cat.id, name: val, isRequired: cat.isRequired, isMultiple: cat.isMultiple, options: cat.options);
                            addonCategories[catIdx] = cat;
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red, size: 20),
                        onPressed: () {
                          setDialogState(() {
                            addonCategories.removeAt(catIdx);
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          title: const Text('Required', style: TextStyle(color: AppColors.onSurface, fontSize: 12)),
                          value: cat.isRequired,
                          onChanged: (val) {
                            setDialogState(() {
                              addonCategories[catIdx] = MenuAddonCategoryModel(id: cat.id, name: cat.name, isRequired: val ?? false, isMultiple: cat.isMultiple, options: cat.options);
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                      Expanded(
                        child: CheckboxListTile(
                          title: const Text('Multiple', style: TextStyle(color: AppColors.onSurface, fontSize: 12)),
                          value: cat.isMultiple,
                          onChanged: (val) {
                            setDialogState(() {
                              addonCategories[catIdx] = MenuAddonCategoryModel(id: cat.id, name: cat.name, isRequired: cat.isRequired, isMultiple: val ?? false, options: cat.options);
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.outlineVariant),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Options', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {
                          setDialogState(() {
                            final opts = List<MenuAddonModel>.from(cat.options);
                            opts.add(MenuAddonModel(id: 0, name: '', price: 0));
                            addonCategories[catIdx] = MenuAddonCategoryModel(id: cat.id, name: cat.name, isRequired: cat.isRequired, isMultiple: cat.isMultiple, options: opts);
                          });
                        },
                        child: const Text('Add Option', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                  ...cat.options.asMap().entries.map((optEntry) {
                    int optIdx = optEntry.key;
                    var opt = optEntry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              initialValue: opt.name,
                              style: const TextStyle(color: AppColors.onSurface, fontSize: 12),
                              decoration: const InputDecoration(hintText: 'Option Name', isDense: true),
                              onChanged: (val) {
                                final opts = List<MenuAddonModel>.from(addonCategories[catIdx].options);
                                opts[optIdx] = MenuAddonModel(id: opt.id, name: val, price: opt.price);
                                addonCategories[catIdx] = MenuAddonCategoryModel(id: cat.id, name: cat.name, isRequired: cat.isRequired, isMultiple: cat.isMultiple, options: opts);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              initialValue: opt.price > 0 ? opt.price.toString() : '',
                              style: const TextStyle(color: AppColors.onSurface, fontSize: 12),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(hintText: '+\$0.00', isDense: true),
                              onChanged: (val) {
                                final opts = List<MenuAddonModel>.from(addonCategories[catIdx].options);
                                opts[optIdx] = MenuAddonModel(id: opt.id, name: opt.name, price: double.tryParse(val) ?? 0.0);
                                addonCategories[catIdx] = MenuAddonCategoryModel(id: cat.id, name: cat.name, isRequired: cat.isRequired, isMultiple: cat.isMultiple, options: opts);
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red, size: 16),
                            onPressed: () {
                              setDialogState(() {
                                final opts = List<MenuAddonModel>.from(addonCategories[catIdx].options);
                                opts.removeAt(optIdx);
                                addonCategories[catIdx] = MenuAddonCategoryModel(id: cat.id, name: cat.name, isRequired: cat.isRequired, isMultiple: cat.isMultiple, options: opts);
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            );
          }).toList(),
      ],
    );
  }
}
