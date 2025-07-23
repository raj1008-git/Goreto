// lib/features/maps/widgets/category_dropdown.dart

import 'package:flutter/material.dart';

class CategoryDropdown extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String?> onChanged;
  final bool isLoading;

  const CategoryDropdown({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Icon(
              Icons.location_on,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: categories.isEmpty
                  ? const Text(
                      'No categories available',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCategory,
                        hint: const Text(
                          'Select Category',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                        icon: isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                Icons.keyboard_arrow_down,
                                color: Theme.of(context).primaryColor,
                              ),
                        isExpanded: true,
                        items: categories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _getCategoryColor(category),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      category,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: onChanged,
                        dropdownColor: Colors.white,
                        elevation: 8,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    // Generate consistent colors for categories
    final hash = category.hashCode;
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[hash.abs() % colors.length];
  }
}
