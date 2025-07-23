// lib/presentation/widgets/category_selection_popup.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/appColors.dart';
import '../../../data/providers/category_selection_provider.dart';

class CategorySelectionPopup extends StatefulWidget {
  final VoidCallback? onCompleted;

  const CategorySelectionPopup({Key? key, this.onCompleted}) : super(key: key);

  @override
  _CategorySelectionPopupState createState() => _CategorySelectionPopupState();
}

class _CategorySelectionPopupState extends State<CategorySelectionPopup> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    // Load initial categories
    Future.microtask(() {
      context.read<CategorySelectionProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more when near bottom
      context.read<CategorySelectionProvider>().loadMoreCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.yellow, AppColors.primary],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.category_outlined,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Choose Your Favourite Category',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'You can choose more than one',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            // Selected count indicator
            Consumer<CategorySelectionProvider>(
              builder: (context, provider, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: provider.selectedCount > 0
                              ? Colors.green.withOpacity(0.1)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: provider.selectedCount > 0
                                ? Colors.green
                                : Colors.grey,
                          ),
                        ),
                        child: Text(
                          '${provider.selectedCount} Selected',
                          style: TextStyle(
                            color: provider.selectedCount > 0
                                ? Colors.green.shade700
                                : Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (provider.selectedCount > 0)
                        TextButton(
                          onPressed: provider.clearSelections,
                          child: Text(
                            'Clear All',
                            style: TextStyle(
                              color: Colors.red.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),

            // Category list
            Expanded(
              child: Consumer<CategorySelectionProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading categories...'),
                        ],
                      ),
                    );
                  }

                  if (provider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading categories',
                            style: TextStyle(
                              color: Colors.red.shade600,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            provider.error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: provider.loadCategories,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount:
                        provider.allCategories.length +
                        (provider.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= provider.allCategories.length) {
                        // Loading more indicator
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final category = provider.allCategories[index];
                      final isSelected = provider.isCategorySelected(
                        category.category,
                      );

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () =>
                                provider.toggleCategory(category.category),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.blue.shade50
                                    : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.secondary
                                      : Colors.grey.shade200,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primary
                                            : Colors.grey.shade400,
                                        width: 2,
                                      ),
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 16,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      category.category,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        color: isSelected
                                            ? AppColors.primary
                                            : Colors.grey.shade800,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    _getCategoryIcon(category.category),
                                    color: isSelected
                                        ? AppColors.primary
                                        : Colors.grey.shade500,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Footer with action buttons
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Consumer<CategorySelectionProvider>(
                builder: (context, provider, child) {
                  return Column(
                    children: [
                      if (provider.error != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red.shade600,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  provider.error!,
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: provider.isSaving
                                  ? null
                                  : () {
                                      Navigator.of(context).pop();
                                    },
                              child: const Text(
                                'Skip for now',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed:
                                  provider.isSaving ||
                                      provider.selectedCount == 0
                                  ? null
                                  : _saveCategories,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: provider.isSaving
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text(
                                      'Save Preferences',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveCategories() async {
    final provider = context.read<CategorySelectionProvider>();
    final success = await provider.saveSelectedCategories();

    if (success) {
      Navigator.of(context).pop();
      widget.onCompleted?.call();

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  '${provider.selectedCount} categories saved successfully!',
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'lodging':
        return Icons.hotel;
      case 'clothing store':
        return Icons.store;
      case 'movie theater':
        return Icons.movie;
      case 'department store':
        return Icons.shopping_bag;
      case 'point of interest':
        return Icons.place;
      case 'hospital':
        return Icons.local_hospital;
      case 'primary school':
      case 'secondary school':
        return Icons.school;
      case 'place of worship':
        return Icons.temple_hindu;
      case 'travel agency':
        return Icons.flight;
      default:
        return Icons.category;
    }
  }
}
