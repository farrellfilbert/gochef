import 'package:flutter/material.dart';
import '../../models/menu_addon_model.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class AddonCategoryManager extends StatefulWidget {
  final List<MenuAddonCategoryModel> initialCategories;
  final ValueChanged<List<MenuAddonCategoryModel>> onChanged;

  const AddonCategoryManager({
    super.key,
    required this.initialCategories,
    required this.onChanged,
  });

  @override
  State<AddonCategoryManager> createState() => _AddonCategoryManagerState();
}

class _AddonCategoryManagerState extends State<AddonCategoryManager> {
  late List<MenuAddonCategoryModel> categories;

  @override
  void initState() {
    super.initState();
    categories = List.from(widget.initialCategories);
  }

  void _notifyChanged() {
    widget.onChanged(categories);
  }

  void _addCategory() {
    setState(() {
      categories.add(MenuAddonCategoryModel(id: 0, name: ''));
      _notifyChanged();
    });
  }

  void _updateCategoryName(int index, String name) {
    setState(() {
      final old = categories[index];
      categories[index] = MenuAddonCategoryModel(
        id: old.id,
        name: name,
        isRequired: old.isRequired,
        isMultiple: old.isMultiple,
        options: old.options,
      );
      _notifyChanged();
    });
  }

  void _updateCategoryChecks(int index, {bool? isRequired, bool? isMultiple}) {
    setState(() {
      final old = categories[index];
      categories[index] = MenuAddonCategoryModel(
        id: old.id,
        name: old.name,
        isRequired: isRequired ?? old.isRequired,
        isMultiple: isMultiple ?? old.isMultiple,
        options: old.options,
      );
      _notifyChanged();
    });
  }

  void _removeCategory(int index) {
    setState(() {
      categories.removeAt(index);
      _notifyChanged();
    });
  }

  void _addOption(int catIndex) {
    setState(() {
      final old = categories[catIndex];
      final newOptions = List<MenuAddonModel>.from(old.options)
        ..add(MenuAddonModel(id: 0, name: ''));
      categories[catIndex] = MenuAddonCategoryModel(
        id: old.id,
        name: old.name,
        isRequired: old.isRequired,
        isMultiple: old.isMultiple,
        options: newOptions,
      );
      _notifyChanged();
    });
  }

  void _updateOption(int catIndex, int optIndex, String name, double price) {
    setState(() {
      final old = categories[catIndex];
      final newOptions = List<MenuAddonModel>.from(old.options);
      final oldOpt = newOptions[optIndex];
      newOptions[optIndex] = MenuAddonModel(id: oldOpt.id, name: name, price: price);
      categories[catIndex] = MenuAddonCategoryModel(
        id: old.id,
        name: old.name,
        isRequired: old.isRequired,
        isMultiple: old.isMultiple,
        options: newOptions,
      );
      _notifyChanged();
    });
  }

  void _removeOption(int catIndex, int optIndex) {
    setState(() {
      final old = categories[catIndex];
      final newOptions = List<MenuAddonModel>.from(old.options)..removeAt(optIndex);
      categories[catIndex] = MenuAddonCategoryModel(
        id: old.id,
        name: old.name,
        isRequired: old.isRequired,
        isMultiple: old.isMultiple,
        options: newOptions,
      );
      _notifyChanged();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Customization Groups', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
            TextButton.icon(
              onPressed: _addCategory,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Group'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (categories.isEmpty)
          const Text(
            'No customization groups added yet.',
            style: TextStyle(color: AppColors.onSurfaceVariant),
          ),
        ...categories.asMap().entries.map((catEntry) {
          int catIdx = catEntry.key;
          MenuAddonCategoryModel cat = catEntry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Group Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          TextFormField(
                            initialValue: cat.name,
                            style: const TextStyle(color: AppColors.onSurface),
                            decoration: const InputDecoration(
                              hintText: 'Group Name (e.g. Spiciness Level)',
                              isDense: true,
                            ),
                            onChanged: (val) => _updateCategoryName(catIdx, val),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              SizedBox(
                                height: 24,
                                width: 24,
                                child: Checkbox(
                                  value: cat.isRequired,
                                  onChanged: (val) => _updateCategoryChecks(catIdx, isRequired: val),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('Required', style: TextStyle(color: AppColors.onSurface, fontSize: 12)),
                              const SizedBox(width: 16),
                              SizedBox(
                                height: 24,
                                width: 24,
                                child: Checkbox(
                                  value: cat.isMultiple,
                                  onChanged: (val) => _updateCategoryChecks(catIdx, isMultiple: val),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('Allow Multiple Selection', style: TextStyle(color: AppColors.onSurface, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeCategory(catIdx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('Options:', style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                // Options List
                ...cat.options.asMap().entries.map((optEntry) {
                  int optIdx = optEntry.key;
                  MenuAddonModel opt = optEntry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            initialValue: opt.name,
                            style: const TextStyle(color: AppColors.onSurface, fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: 'Option (e.g. Level 1)',
                              isDense: true,
                            ),
                            onChanged: (val) => _updateOption(catIdx, optIdx, val, opt.price),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            initialValue: opt.price > 0 ? opt.price.toString() : '',
                            style: const TextStyle(color: AppColors.onSurface, fontSize: 14),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              hintText: '+\$0.00',
                              isDense: true,
                            ),
                            onChanged: (val) {
                              _updateOption(catIdx, optIdx, opt.name, double.tryParse(val) ?? 0.0);
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red, size: 20),
                          onPressed: () => _removeOption(catIdx, optIdx),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  );
                }),
                TextButton.icon(
                  onPressed: () => _addOption(catIdx),
                  icon: const Icon(Icons.add, size: 14),
                  label: const Text('Add Option', style: TextStyle(fontSize: 12)),
                )
              ],
            ),
          );
        }),
      ],
    );
  }
}
