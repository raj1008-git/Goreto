// // lib/presentation/widgets/category_selection_popup.dart
//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../../core/constants/appColors.dart';
// import '../../../data/providers/category_selection_provider.dart';
//
// class CategorySelectionPopup extends StatefulWidget {
//   final VoidCallback? onCompleted;
//
//   const CategorySelectionPopup({Key? key, this.onCompleted}) : super(key: key);
//
//   @override
//   _CategorySelectionPopupState createState() => _CategorySelectionPopupState();
// }
//
// class _CategorySelectionPopupState extends State<CategorySelectionPopup>
//     with TickerProviderStateMixin {
//   late ScrollController _scrollController;
//   late AnimationController _fadeController;
//   late Animation<double> _fadeAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();
//     _scrollController.addListener(_onScroll);
//
//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
//     );
//
//     // Load initial categories
//     Future.microtask(() {
//       context.read<CategorySelectionProvider>().loadCategories();
//       _fadeController.forward();
//     });
//   }
//
//   @override
//   void dispose() {
//     _scrollController.removeListener(_onScroll);
//     _scrollController.dispose();
//     _fadeController.dispose();
//     super.dispose();
//   }
//
//   void _onScroll() {
//     if (_scrollController.position.pixels >=
//         _scrollController.position.maxScrollExtent - 200) {
//       // Load more when near bottom
//       context.read<CategorySelectionProvider>().loadMoreCategories();
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FadeTransition(
//       opacity: _fadeAnimation,
//       child: Dialog(
//         backgroundColor: Colors.transparent,
//         child: Container(
//           height: MediaQuery.of(context).size.height * 0.85,
//           margin: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(24),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.15),
//                 blurRadius: 30,
//                 offset: const Offset(0, 15),
//                 spreadRadius: 0,
//               ),
//               BoxShadow(
//                 color: AppColors.primary.withOpacity(0.1),
//                 blurRadius: 20,
//                 offset: const Offset(0, 5),
//                 spreadRadius: 0,
//               ),
//             ],
//           ),
//           child: Column(
//             children: [
//               // Modern Header with gradient
//               Container(
//                 padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [AppColors.primary, AppColors.secondary],
//                     stops: const [0.0, 1.0],
//                   ),
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(24),
//                     topRight: Radius.circular(24),
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(20),
//                       ),
//                       child: const Icon(
//                         Icons.tune_rounded,
//                         color: Colors.white,
//                         size: 32,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     const Text(
//                       'Select Your Interests',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 26,
//                         fontWeight: FontWeight.w700,
//                         letterSpacing: -0.5,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Choose categories that match your preferences',
//                       textAlign: TextAlign.center,
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.9),
//                         fontSize: 15,
//                         fontWeight: FontWeight.w400,
//                         height: 1.4,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // Selection counter with modern design
//               Consumer<CategorySelectionProvider>(
//                 builder: (context, provider, child) {
//                   return Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 28,
//                       vertical: 20,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.grey.shade50,
//                       border: Border(
//                         bottom: BorderSide(
//                           color: Colors.grey.shade200,
//                           width: 1,
//                         ),
//                       ),
//                     ),
//                     child: Row(
//                       children: [
//                         AnimatedContainer(
//                           duration: const Duration(milliseconds: 300),
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 16,
//                             vertical: 10,
//                           ),
//                           decoration: BoxDecoration(
//                             gradient: provider.selectedCount > 0
//                                 ? LinearGradient(
//                                     colors: [
//                                       AppColors.primary.withOpacity(0.1),
//                                       AppColors.secondary.withOpacity(0.1),
//                                     ],
//                                   )
//                                 : null,
//                             color: provider.selectedCount == 0
//                                 ? Colors.grey.shade100
//                                 : null,
//                             borderRadius: BorderRadius.circular(25),
//                             border: Border.all(
//                               color: provider.selectedCount > 0
//                                   ? AppColors.primary.withOpacity(0.3)
//                                   : Colors.grey.shade300,
//                               width: 1.5,
//                             ),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               AnimatedSwitcher(
//                                 duration: const Duration(milliseconds: 200),
//                                 child: Icon(
//                                   provider.selectedCount > 0
//                                       ? Icons.check_circle_rounded
//                                       : Icons.radio_button_unchecked_rounded,
//                                   key: ValueKey(provider.selectedCount > 0),
//                                   color: provider.selectedCount > 0
//                                       ? AppColors.primary
//                                       : Colors.grey.shade500,
//                                   size: 18,
//                                 ),
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 '${provider.selectedCount} Selected',
//                                 style: TextStyle(
//                                   color: provider.selectedCount > 0
//                                       ? AppColors.primary
//                                       : Colors.grey.shade600,
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const Spacer(),
//                         if (provider.selectedCount > 0)
//                           AnimatedScale(
//                             scale: provider.selectedCount > 0 ? 1.0 : 0.0,
//                             duration: const Duration(milliseconds: 200),
//                             child: TextButton.icon(
//                               onPressed: provider.clearSelections,
//                               icon: const Icon(Icons.clear_rounded, size: 16),
//                               label: const Text('Clear All'),
//                               style: TextButton.styleFrom(
//                                 foregroundColor: Colors.red.shade600,
//                                 backgroundColor: Colors.red.shade50,
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 16,
//                                   vertical: 8,
//                                 ),
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//
//               // Category list with enhanced styling
//               Expanded(
//                 child: Consumer<CategorySelectionProvider>(
//                   builder: (context, provider, child) {
//                     if (provider.isLoading) {
//                       return Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Container(
//                               padding: const EdgeInsets.all(20),
//                               decoration: BoxDecoration(
//                                 gradient: LinearGradient(
//                                   colors: [
//                                     AppColors.primary.withOpacity(0.1),
//                                     AppColors.secondary.withOpacity(0.1),
//                                   ],
//                                 ),
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: CircularProgressIndicator(
//                                 valueColor: AlwaysStoppedAnimation<Color>(
//                                   AppColors.primary,
//                                 ),
//                                 strokeWidth: 3,
//                               ),
//                             ),
//                             const SizedBox(height: 24),
//                             Text(
//                               'Loading categories...',
//                               style: TextStyle(
//                                 color: Colors.grey.shade600,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     }
//
//                     if (provider.error != null) {
//                       return Center(
//                         child: Container(
//                           margin: const EdgeInsets.all(24),
//                           padding: const EdgeInsets.all(32),
//                           decoration: BoxDecoration(
//                             color: Colors.red.shade50,
//                             borderRadius: BorderRadius.circular(20),
//                             border: Border.all(
//                               color: Colors.red.shade200,
//                               width: 1,
//                             ),
//                           ),
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Container(
//                                 padding: const EdgeInsets.all(16),
//                                 decoration: BoxDecoration(
//                                   color: Colors.red.shade100,
//                                   borderRadius: BorderRadius.circular(16),
//                                 ),
//                                 child: Icon(
//                                   Icons.error_outline_rounded,
//                                   size: 32,
//                                   color: Colors.red.shade600,
//                                 ),
//                               ),
//                               const SizedBox(height: 20),
//                               Text(
//                                 'Oops! Something went wrong',
//                                 style: TextStyle(
//                                   color: Colors.red.shade700,
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                               const SizedBox(height: 12),
//                               Text(
//                                 provider.error!,
//                                 textAlign: TextAlign.center,
//                                 style: TextStyle(
//                                   color: Colors.red.shade600,
//                                   fontSize: 14,
//                                   height: 1.4,
//                                 ),
//                               ),
//                               const SizedBox(height: 24),
//                               ElevatedButton.icon(
//                                 onPressed: provider.loadCategories,
//                                 icon: const Icon(Icons.refresh_rounded),
//                                 label: const Text('Try Again'),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.red.shade600,
//                                   foregroundColor: Colors.white,
//                                   padding: const EdgeInsets.symmetric(
//                                     horizontal: 24,
//                                     vertical: 12,
//                                   ),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     }
//
//                     return ListView.builder(
//                       controller: _scrollController,
//                       padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
//                       itemCount:
//                           provider.allCategories.length +
//                           (provider.isLoadingMore ? 1 : 0),
//                       itemBuilder: (context, index) {
//                         if (index >= provider.allCategories.length) {
//                           // Loading more indicator
//                           return Container(
//                             padding: const EdgeInsets.all(20),
//                             alignment: Alignment.center,
//                             child: CircularProgressIndicator(
//                               valueColor: AlwaysStoppedAnimation<Color>(
//                                 AppColors.primary,
//                               ),
//                               strokeWidth: 2,
//                             ),
//                           );
//                         }
//
//                         final category = provider.allCategories[index];
//                         final isSelected = provider.isCategorySelected(
//                           category.category,
//                         );
//
//                         return Container(
//                           margin: const EdgeInsets.only(bottom: 12),
//                           child: Material(
//                             color: Colors.transparent,
//                             child: InkWell(
//                               onTap: () =>
//                                   provider.toggleCategory(category.category),
//                               borderRadius: BorderRadius.circular(16),
//                               splashColor: AppColors.primary.withOpacity(0.1),
//                               highlightColor: AppColors.primary.withOpacity(
//                                 0.05,
//                               ),
//                               child: AnimatedContainer(
//                                 duration: const Duration(milliseconds: 250),
//                                 curve: Curves.easeOutCubic,
//                                 padding: const EdgeInsets.all(20),
//                                 decoration: BoxDecoration(
//                                   gradient: isSelected
//                                       ? LinearGradient(
//                                           begin: Alignment.topLeft,
//                                           end: Alignment.bottomRight,
//                                           colors: [
//                                             AppColors.primary.withOpacity(0.08),
//                                             AppColors.secondary.withOpacity(
//                                               0.08,
//                                             ),
//                                           ],
//                                         )
//                                       : null,
//                                   color: isSelected ? null : Colors.white,
//                                   borderRadius: BorderRadius.circular(16),
//                                   border: Border.all(
//                                     color: isSelected
//                                         ? AppColors.primary.withOpacity(0.4)
//                                         : Colors.grey.shade200,
//                                     width: isSelected ? 2 : 1,
//                                   ),
//                                   boxShadow: isSelected
//                                       ? [
//                                           BoxShadow(
//                                             color: AppColors.primary
//                                                 .withOpacity(0.15),
//                                             blurRadius: 12,
//                                             offset: const Offset(0, 4),
//                                           ),
//                                         ]
//                                       : [
//                                           BoxShadow(
//                                             color: Colors.grey.withOpacity(
//                                               0.05,
//                                             ),
//                                             blurRadius: 8,
//                                             offset: const Offset(0, 2),
//                                           ),
//                                         ],
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     // Custom checkbox
//                                     AnimatedContainer(
//                                       duration: const Duration(
//                                         milliseconds: 250,
//                                       ),
//                                       width: 28,
//                                       height: 28,
//                                       decoration: BoxDecoration(
//                                         gradient: isSelected
//                                             ? LinearGradient(
//                                                 colors: [
//                                                   AppColors.primary,
//                                                   AppColors.secondary,
//                                                 ],
//                                               )
//                                             : null,
//                                         color: isSelected
//                                             ? null
//                                             : Colors.transparent,
//                                         borderRadius: BorderRadius.circular(8),
//                                         border: Border.all(
//                                           color: isSelected
//                                               ? Colors.transparent
//                                               : Colors.grey.shade400,
//                                           width: 2,
//                                         ),
//                                       ),
//                                       child: AnimatedScale(
//                                         scale: isSelected ? 1.0 : 0.0,
//                                         duration: const Duration(
//                                           milliseconds: 200,
//                                         ),
//                                         child: const Icon(
//                                           Icons.check_rounded,
//                                           color: Colors.white,
//                                           size: 18,
//                                         ),
//                                       ),
//                                     ),
//                                     const SizedBox(width: 20),
//                                     // Category icon
//                                     Container(
//                                       padding: const EdgeInsets.all(8),
//                                       decoration: BoxDecoration(
//                                         color: isSelected
//                                             ? AppColors.primary.withOpacity(
//                                                 0.15,
//                                               )
//                                             : Colors.grey.shade100,
//                                         borderRadius: BorderRadius.circular(10),
//                                       ),
//                                       child: Icon(
//                                         _getCategoryIcon(category.category),
//                                         color: isSelected
//                                             ? AppColors.primary
//                                             : Colors.grey.shade600,
//                                         size: 20,
//                                       ),
//                                     ),
//                                     const SizedBox(width: 16),
//                                     // Category name
//                                     Expanded(
//                                       child: Text(
//                                         category.category,
//                                         style: TextStyle(
//                                           fontSize: 16,
//                                           fontWeight: isSelected
//                                               ? FontWeight.w600
//                                               : FontWeight.w500,
//                                           color: isSelected
//                                               ? AppColors.primary
//                                               : Colors.grey.shade800,
//                                           height: 1.3,
//                                         ),
//                                       ),
//                                     ),
//                                     // Selection indicator
//                                     if (isSelected)
//                                       Container(
//                                         padding: const EdgeInsets.symmetric(
//                                           horizontal: 8,
//                                           vertical: 4,
//                                         ),
//                                         decoration: BoxDecoration(
//                                           gradient: LinearGradient(
//                                             colors: [
//                                               AppColors.primary,
//                                               AppColors.secondary,
//                                             ],
//                                           ),
//                                           borderRadius: BorderRadius.circular(
//                                             12,
//                                           ),
//                                         ),
//                                         child: const Text(
//                                           'Selected',
//                                           style: TextStyle(
//                                             color: Colors.white,
//                                             fontSize: 10,
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                         ),
//                                       ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ),
//
//               // Modern footer with enhanced buttons
//               Container(
//                 padding: const EdgeInsets.all(28),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: const BorderRadius.only(
//                     bottomLeft: Radius.circular(24),
//                     bottomRight: Radius.circular(24),
//                   ),
//                   border: Border(
//                     top: BorderSide(color: Colors.grey.shade200, width: 1),
//                   ),
//                 ),
//                 child: Consumer<CategorySelectionProvider>(
//                   builder: (context, provider, child) {
//                     return Column(
//                       children: [
//                         if (provider.error != null)
//                           Container(
//                             padding: const EdgeInsets.all(16),
//                             margin: const EdgeInsets.only(bottom: 20),
//                             decoration: BoxDecoration(
//                               color: Colors.red.shade50,
//                               borderRadius: BorderRadius.circular(12),
//                               border: Border.all(
//                                 color: Colors.red.shade200,
//                                 width: 1,
//                               ),
//                             ),
//                             child: Row(
//                               children: [
//                                 Icon(
//                                   Icons.error_outline_rounded,
//                                   color: Colors.red.shade600,
//                                   size: 20,
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Expanded(
//                                   child: Text(
//                                     provider.error!,
//                                     style: TextStyle(
//                                       color: Colors.red.shade700,
//                                       fontSize: 14,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         Row(
//                           children: [
//                             // Skip button
//                             Expanded(
//                               child: TextButton(
//                                 onPressed: provider.isSaving
//                                     ? null
//                                     : () {
//                                         Navigator.of(context).pop();
//                                       },
//                                 style: TextButton.styleFrom(
//                                   foregroundColor: Colors.grey.shade600,
//                                   padding: const EdgeInsets.symmetric(
//                                     vertical: 16,
//                                   ),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(14),
//                                     side: BorderSide(
//                                       color: Colors.transparent,
//                                       width: 2,
//                                     ),
//                                   ),
//                                 ),
//                                 child: const Text(
//                                   'Skip',
//                                   style: TextStyle(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.w600,
//                                     color: Colors.red,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 16),
//                             // Save button
//                             Expanded(
//                               flex: 2,
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                   gradient:
//                                       provider.isSaving ||
//                                           provider.selectedCount == 0
//                                       ? null
//                                       : LinearGradient(
//                                           begin: Alignment.topLeft,
//                                           end: Alignment.bottomRight,
//                                           colors: [
//                                             AppColors.primary,
//                                             AppColors.secondary,
//                                           ],
//                                         ),
//                                   borderRadius: BorderRadius.circular(14),
//                                   boxShadow:
//                                       provider.isSaving ||
//                                           provider.selectedCount == 0
//                                       ? null
//                                       : [
//                                           BoxShadow(
//                                             color: AppColors.primary
//                                                 .withOpacity(0.3),
//                                             blurRadius: 12,
//                                             offset: const Offset(0, 6),
//                                           ),
//                                         ],
//                                 ),
//                                 child: ElevatedButton(
//                                   onPressed:
//                                       provider.isSaving ||
//                                           provider.selectedCount == 0
//                                       ? null
//                                       : _saveCategories,
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor:
//                                         provider.isSaving ||
//                                             provider.selectedCount == 0
//                                         ? Colors.transparent
//                                         : Colors.transparent,
//                                     foregroundColor: Colors.white,
//                                     shadowColor: Colors.transparent,
//                                     padding: const EdgeInsets.symmetric(
//                                       vertical: 18,
//                                     ),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(14),
//                                     ),
//                                     elevation: 0,
//                                   ),
//                                   child: provider.isSaving
//                                       ? const SizedBox(
//                                           height: 20,
//                                           width: 25,
//                                           child: CircularProgressIndicator(
//                                             strokeWidth: 2,
//                                             valueColor:
//                                                 AlwaysStoppedAnimation<Color>(
//                                                   Colors.white,
//                                                 ),
//                                           ),
//                                         )
//                                       : Row(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.center,
//                                           children: [
//                                             const Icon(
//                                               Icons.save_rounded,
//                                               size: 18,
//                                             ),
//                                             const SizedBox(width: 8),
//                                             const Text(
//                                               'Save Preferences',
//                                               style: TextStyle(
//                                                 fontSize: 16,
//                                                 fontWeight: FontWeight.w600,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<void> _saveCategories() async {
//     final provider = context.read<CategorySelectionProvider>();
//     final success = await provider.saveSelectedCategories();
//
//     if (success) {
//       Navigator.of(context).pop();
//       widget.onCompleted?.call();
//
//       // Enhanced success message
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Container(
//               padding: const EdgeInsets.symmetric(vertical: 4),
//               child: Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(6),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: const Icon(
//                       Icons.check_circle_rounded,
//                       color: Colors.white,
//                       size: 20,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const Text(
//                           'Preferences Saved!',
//                           style: TextStyle(
//                             fontWeight: FontWeight.w600,
//                             fontSize: 15,
//                           ),
//                         ),
//                         Text(
//                           '${provider.selectedCount} categories selected',
//                           style: TextStyle(
//                             color: Colors.white.withOpacity(0.9),
//                             fontSize: 13,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             backgroundColor: Colors.green.shade600,
//             behavior: SnackBarBehavior.floating,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             margin: const EdgeInsets.all(16),
//             duration: const Duration(seconds: 3),
//           ),
//         );
//       }
//     }
//   }
//
//   IconData _getCategoryIcon(String categoryName) {
//     switch (categoryName.toLowerCase()) {
//       case 'lodging':
//         return Icons.hotel_rounded;
//       case 'clothing store':
//         return Icons.store_rounded;
//       case 'movie theater':
//         return Icons.movie_rounded;
//       case 'department store':
//         return Icons.shopping_bag_rounded;
//       case 'point of interest':
//         return Icons.place_rounded;
//       case 'hospital':
//         return Icons.local_hospital_rounded;
//       case 'primary school':
//       case 'secondary school':
//         return Icons.school_rounded;
//       case 'place of worship':
//         return Icons.temple_hindu_rounded;
//       case 'travel agency':
//         return Icons.flight_rounded;
//       case 'restaurant':
//       case 'food':
//         return Icons.restaurant_rounded;
//       case 'shopping':
//         return Icons.shopping_cart_rounded;
//       case 'entertainment':
//         return Icons.theaters_rounded;
//       case 'health':
//         return Icons.health_and_safety_rounded;
//       case 'education':
//         return Icons.menu_book_rounded;
//       case 'transport':
//         return Icons.directions_bus_rounded;
//       default:
//         return Icons.category_rounded;
//     }
//   }
// }
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

class _CategorySelectionPopupState extends State<CategorySelectionPopup>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Load initial categories
    Future.microtask(() {
      context.read<CategorySelectionProvider>().loadCategories();
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more when near bottom
      context.read<CategorySelectionProvider>().loadMoreCategories();
    }
  }

  // Helper method to get responsive margins and constraints
  EdgeInsets _getResponsiveMargin(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600) {
      // Mobile phones
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 20);
    } else if (screenWidth < 900) {
      // Tablets
      return const EdgeInsets.symmetric(horizontal: 40, vertical: 30);
    } else if (screenWidth < 1200) {
      // Small desktops/laptops
      return const EdgeInsets.symmetric(horizontal: 80, vertical: 40);
    } else {
      // Large screens
      return EdgeInsets.symmetric(
        horizontal: screenWidth * 0.15, // 15% margin on each side
        vertical: 50,
      );
    }
  }

  double _getMaxWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 600) {
      // Mobile: use almost full width
      return screenWidth * 0.95;
    } else if (screenWidth < 900) {
      // Tablet: limit to reasonable width
      return 600;
    } else if (screenWidth < 1200) {
      // Small desktop: moderate width
      return 700;
    } else {
      // Large screens: cap at max width for readability
      return 800;
    }
  }

  double _getDialogHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    if (screenHeight < 600) {
      // Short screens: use more space
      return screenHeight * 0.9;
    } else if (screenHeight < 800) {
      // Medium screens
      return screenHeight * 0.85;
    } else {
      // Tall screens: cap height for better UX
      return screenHeight * 0.8;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: _getResponsiveMargin(context),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: _getMaxWidth(context),
            maxHeight: _getDialogHeight(context),
          ),
          child: Container(
            width: double.infinity,
            height: _getDialogHeight(context),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                // Modern Header with gradient
                Container(
                  padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.secondary],
                      stops: const [0.0, 1.0],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.tune_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Select Your Interests',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose categories that match your preferences',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                // Selection counter with modern design
                Consumer<CategorySelectionProvider>(
                  builder: (context, provider, child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              gradient: provider.selectedCount > 0
                                  ? LinearGradient(
                                      colors: [
                                        AppColors.primary.withOpacity(0.1),
                                        AppColors.secondary.withOpacity(0.1),
                                      ],
                                    )
                                  : null,
                              color: provider.selectedCount == 0
                                  ? Colors.grey.shade100
                                  : null,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(
                                color: provider.selectedCount > 0
                                    ? AppColors.primary.withOpacity(0.3)
                                    : Colors.grey.shade300,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    provider.selectedCount > 0
                                        ? Icons.check_circle_rounded
                                        : Icons.radio_button_unchecked_rounded,
                                    key: ValueKey(provider.selectedCount > 0),
                                    color: provider.selectedCount > 0
                                        ? AppColors.primary
                                        : Colors.grey.shade500,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${provider.selectedCount} Selected',
                                  style: TextStyle(
                                    color: provider.selectedCount > 0
                                        ? AppColors.primary
                                        : Colors.grey.shade600,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          if (provider.selectedCount > 0)
                            AnimatedScale(
                              scale: provider.selectedCount > 0 ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 200),
                              child: TextButton.icon(
                                onPressed: provider.clearSelections,
                                icon: const Icon(Icons.clear_rounded, size: 16),
                                label: const Text('Clear All'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red.shade600,
                                  backgroundColor: Colors.red.shade50,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),

                // Category list with enhanced styling
                Expanded(
                  child: Consumer<CategorySelectionProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary.withOpacity(0.1),
                                      AppColors.secondary.withOpacity(0.1),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primary,
                                  ),
                                  strokeWidth: 3,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'Loading categories...',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      if (provider.error != null) {
                        return Center(
                          child: Container(
                            margin: const EdgeInsets.all(24),
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.red.shade200,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    Icons.error_outline_rounded,
                                    size: 32,
                                    color: Colors.red.shade600,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'Oops! Something went wrong',
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  provider.error!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.red.shade600,
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: provider.loadCategories,
                                  icon: const Icon(Icons.refresh_rounded),
                                  label: const Text('Try Again'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade600,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                        itemCount:
                            provider.allCategories.length +
                            (provider.isLoadingMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= provider.allCategories.length) {
                            // Loading more indicator
                            return Container(
                              padding: const EdgeInsets.all(20),
                              alignment: Alignment.center,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.primary,
                                ),
                                strokeWidth: 2,
                              ),
                            );
                          }

                          final category = provider.allCategories[index];
                          final isSelected = provider.isCategorySelected(
                            category.category,
                          );

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () =>
                                    provider.toggleCategory(category.category),
                                borderRadius: BorderRadius.circular(16),
                                splashColor: AppColors.primary.withOpacity(0.1),
                                highlightColor: AppColors.primary.withOpacity(
                                  0.05,
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeOutCubic,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              AppColors.primary.withOpacity(
                                                0.08,
                                              ),
                                              AppColors.secondary.withOpacity(
                                                0.08,
                                              ),
                                            ],
                                          )
                                        : null,
                                    color: isSelected ? null : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary.withOpacity(0.4)
                                          : Colors.grey.shade200,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primary
                                                  .withOpacity(0.15),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(
                                                0.05,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                  ),
                                  child: Row(
                                    children: [
                                      // Custom checkbox
                                      AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 250,
                                        ),
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          gradient: isSelected
                                              ? LinearGradient(
                                                  colors: [
                                                    AppColors.primary,
                                                    AppColors.secondary,
                                                  ],
                                                )
                                              : null,
                                          color: isSelected
                                              ? null
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? Colors.transparent
                                                : Colors.grey.shade400,
                                            width: 2,
                                          ),
                                        ),
                                        child: AnimatedScale(
                                          scale: isSelected ? 1.0 : 0.0,
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          child: const Icon(
                                            Icons.check_rounded,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      // Category icon
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.primary.withOpacity(
                                                  0.15,
                                                )
                                              : Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Icon(
                                          _getCategoryIcon(category.category),
                                          color: isSelected
                                              ? AppColors.primary
                                              : Colors.grey.shade600,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Category name
                                      Expanded(
                                        child: Text(
                                          category.category,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? AppColors.primary
                                                : Colors.grey.shade800,
                                            height: 1.3,
                                          ),
                                        ),
                                      ),
                                      // Selection indicator
                                      if (isSelected)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                AppColors.primary,
                                                AppColors.secondary,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: const Text(
                                            'Selected',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
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

                // Modern footer with enhanced buttons
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200, width: 1),
                    ),
                  ),
                  child: Consumer<CategorySelectionProvider>(
                    builder: (context, provider, child) {
                      return Column(
                        children: [
                          if (provider.error != null)
                            Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.red.shade200,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline_rounded,
                                    color: Colors.red.shade600,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      provider.error!,
                                      style: TextStyle(
                                        color: Colors.red.shade700,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Row(
                            children: [
                              // Skip button
                              Expanded(
                                child: TextButton(
                                  onPressed: provider.isSaving
                                      ? null
                                      : () {
                                          Navigator.of(context).pop();
                                        },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.grey.shade600,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      side: BorderSide(
                                        color: Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  child: const Text(
                                    'Skip',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Save button
                              Expanded(
                                flex: 2,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient:
                                        provider.isSaving ||
                                            provider.selectedCount == 0
                                        ? null
                                        : LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              AppColors.primary,
                                              AppColors.secondary,
                                            ],
                                          ),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow:
                                        provider.isSaving ||
                                            provider.selectedCount == 0
                                        ? null
                                        : [
                                            BoxShadow(
                                              color: AppColors.primary
                                                  .withOpacity(0.3),
                                              blurRadius: 12,
                                              offset: const Offset(0, 6),
                                            ),
                                          ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed:
                                        provider.isSaving ||
                                            provider.selectedCount == 0
                                        ? null
                                        : _saveCategories,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          provider.isSaving ||
                                              provider.selectedCount == 0
                                          ? Colors.transparent
                                          : Colors.transparent,
                                      foregroundColor: Colors.white,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: provider.isSaving
                                        ? const SizedBox(
                                            height: 20,
                                            width: 25,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.save_rounded,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 8),
                                              const Text(
                                                'Save Preferences',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
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

      // Enhanced success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Preferences Saved!',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '${provider.selectedCount} categories selected',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  IconData _getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'lodging':
        return Icons.hotel_rounded;
      case 'clothing store':
        return Icons.store_rounded;
      case 'movie theater':
        return Icons.movie_rounded;
      case 'department store':
        return Icons.shopping_bag_rounded;
      case 'point of interest':
        return Icons.place_rounded;
      case 'hospital':
        return Icons.local_hospital_rounded;
      case 'primary school':
      case 'secondary school':
        return Icons.school_rounded;
      case 'place of worship':
        return Icons.temple_hindu_rounded;
      case 'travel agency':
        return Icons.flight_rounded;
      case 'restaurant':
      case 'food':
        return Icons.restaurant_rounded;
      case 'shopping':
        return Icons.shopping_cart_rounded;
      case 'entertainment':
        return Icons.theaters_rounded;
      case 'health':
        return Icons.health_and_safety_rounded;
      case 'education':
        return Icons.menu_book_rounded;
      case 'transport':
        return Icons.directions_bus_rounded;
      default:
        return Icons.category_rounded;
    }
  }
}
