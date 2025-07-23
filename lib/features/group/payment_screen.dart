// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
//
// import '../../core/constants/appColors.dart';
// import '../../data/providers/payment_provider.dart';
//
// class PaymentScreen extends StatefulWidget {
//   const PaymentScreen({Key? key}) : super(key: key);
//
//   @override
//   State<PaymentScreen> createState() => _PaymentScreenState();
// }
//
// class _PaymentScreenState extends State<PaymentScreen> {
//   int _selectedPlan = 1; // Default selection is 1 Month Plan
//
//   // Mapping subscription plans to IDs (adjust according to your backend)
//   final Map<int, int> _planToSubscriptionId = {
//     1: 1, // 1 Month Plan
//     2: 2, // 3 Month Plan
//     3: 3, // 1 Year Plan
//   };
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.secondary,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Header
//             Padding(
//               padding: const EdgeInsets.all(20),
//               child: Row(
//                 children: [
//                   IconButton(
//                     onPressed: () => Navigator.of(context).pop(),
//                     icon: const Icon(Icons.arrow_back, color: Colors.white),
//                   ),
//                   const Expanded(
//                     child: Text(
//                       'Support Our Growth',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                   const SizedBox(width: 48),
//                 ],
//               ),
//             ),
//
//             // Scrollable Content
//             Expanded(
//               child: Container(
//                 margin: const EdgeInsets.only(top: 20),
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.only(
//                     topLeft: Radius.circular(30),
//                     topRight: Radius.circular(30),
//                   ),
//                 ),
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.all(24),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const Text('🌱', style: TextStyle(fontSize: 60)),
//                       const SizedBox(height: 16),
//                       Text(
//                         'Your Support Fuels Our Growth',
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: AppColors.secondary,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 24),
//
//                       Container(
//                         padding: const EdgeInsets.all(20),
//                         decoration: BoxDecoration(
//                           color: Colors.grey[50],
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         child: Text(
//                           'Every contribution helps us build faster, debug deeper, and design better. This app is more than just lines of code—it\'s a commitment to empowering teams and simplifying work life.\n\nYour support ensures:\n🔧 Reliable updates and new features\n🛡️ Secure and stable performance\n🧠 Smarter tools backed by community-driven improvements\n\nIf you find value in what we\'re creating, we\'d be honored to have you behind us. Let\'s build something extraordinary—together.',
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.grey[700],
//                             height: 1.6,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                       const SizedBox(height: 24),
//
//                       // Subscription options
//                       _buildPlanOption(1, '1 Month Plan – NPR 875'),
//                       _buildPlanOption(2, '3 Month Plan – NPR 2400'),
//                       _buildPlanOption(3, '1 Year Plan – NPR 8400'),
//
//                       const SizedBox(height: 30),
//
//                       // Support Button with Stripe Integration
//                       Consumer<PaymentProvider>(
//                         builder: (context, paymentProvider, child) {
//                           return Container(
//                             width: double.infinity,
//                             height: 56,
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 colors: [
//                                   AppColors.secondary,
//                                   AppColors.primary,
//                                 ],
//                                 begin: Alignment.centerLeft,
//                                 end: Alignment.centerRight,
//                               ),
//                               borderRadius: BorderRadius.circular(16),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: AppColors.secondary.withOpacity(0.3),
//                                   blurRadius: 12,
//                                   offset: const Offset(0, 6),
//                                 ),
//                               ],
//                             ),
//                             child: ElevatedButton(
//                               onPressed: paymentProvider.isProcessing
//                                   ? null
//                                   : () => _handlePayment(context),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.transparent,
//                                 elevation: 0,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(16),
//                                 ),
//                               ),
//                               child: paymentProvider.isProcessing
//                                   ? const Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         SizedBox(
//                                           width: 20,
//                                           height: 20,
//                                           child: CircularProgressIndicator(
//                                             strokeWidth: 2,
//                                             valueColor:
//                                                 AlwaysStoppedAnimation<Color>(
//                                                   Colors.white,
//                                                 ),
//                                           ),
//                                         ),
//                                         SizedBox(width: 12),
//                                         Text(
//                                           'Processing...',
//                                           style: TextStyle(
//                                             color: Colors.white,
//                                             fontSize: 18,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                       ],
//                                     )
//                                   : const Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.center,
//                                       children: [
//                                         Icon(
//                                           Icons.favorite,
//                                           color: Colors.white,
//                                           size: 20,
//                                         ),
//                                         SizedBox(width: 12),
//                                         Text(
//                                           'Support Our Journey',
//                                           style: TextStyle(
//                                             color: Colors.white,
//                                             fontSize: 18,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                             ),
//                           );
//                         },
//                       ),
//
//                       const SizedBox(height: 40),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPlanOption(int value, String label) {
//     final bool isSelected = _selectedPlan == value;
//
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _selectedPlan = value;
//         });
//       },
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 6),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         decoration: BoxDecoration(
//           color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: isSelected ? AppColors.primary : Colors.grey.shade300,
//             width: 1.5,
//           ),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 20,
//               height: 20,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: isSelected ? AppColors.primary : Colors.grey,
//                   width: 2,
//                 ),
//               ),
//               child: Center(
//                 child: Container(
//                   width: 10,
//                   height: 10,
//                   decoration: BoxDecoration(
//                     color: isSelected ? AppColors.primary : Colors.transparent,
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                   color: isSelected ? AppColors.primary : Colors.grey[800],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// Handle the complete payment process
//   Future<void> _handlePayment(BuildContext context) async {
//     final paymentProvider = Provider.of<PaymentProvider>(
//       context,
//       listen: false,
//     );
//     final subscriptionId = _planToSubscriptionId[_selectedPlan]!;
//
//     try {
//       // Step 1: Initialize payment sheet
//       _showSnackBar('Initializing payment...', AppColors.primary, Icons.info);
//
//       final initSuccess = await paymentProvider.initializePaymentSheet(
//         subscriptionId,
//       );
//
//       if (!initSuccess) {
//         _showSnackBar(
//           paymentProvider.errorMessage ?? 'Failed to initialize payment',
//           Colors.red,
//           Icons.error,
//         );
//         return;
//       }
//
//       // Step 2: Present payment sheet
//       final paymentResult = await paymentProvider.presentPaymentSheet();
//
//       // Step 3: Handle result
//       if (paymentResult.isSuccess) {
//         _showPaymentSuccessDialog(paymentResult.data!);
//       } else if (paymentResult.isCancelled) {
//         _showSnackBar('Payment cancelled', Colors.orange, Icons.cancel);
//       } else {
//         _showSnackBar(
//           paymentResult.errorMessage ?? 'Payment failed',
//           Colors.red,
//           Icons.error,
//         );
//       }
//     } catch (e) {
//       _showSnackBar('Unexpected error: $e', Colors.red, Icons.error);
//     }
//   }
//
//   /// Show payment success dialog
//   void _showPaymentSuccessDialog(Map<String, dynamic> successData) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Row(
//             children: [
//               Icon(Icons.check_circle, color: Colors.green, size: 30),
//               SizedBox(width: 10),
//               Text("Payment Successful!"),
//             ],
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text("Thank you for supporting our journey!"),
//               const SizedBox(height: 10),
//               Text("Plan: ${_getPlanName(_selectedPlan)}"),
//               const SizedBox(height: 10),
//               if (successData.containsKey('message'))
//                 Text("Message: ${successData['message']}"),
//               if (successData.containsKey('transaction_id'))
//                 Text("Transaction ID: ${successData['transaction_id']}"),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 Navigator.of(context).pop(); // Go back to previous screen
//               },
//               style: TextButton.styleFrom(foregroundColor: AppColors.primary),
//               child: const Text("OK"),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   String _getPlanName(int planId) {
//     switch (planId) {
//       case 1:
//         return '1 Month Plan – NPR 875';
//       case 2:
//         return '3 Month Plan – NPR 2400';
//       case 3:
//         return '1 Year Plan – NPR 8400';
//       default:
//         return 'Unknown Plan';
//     }
//   }
//
//   /// Show snackbar with message
//   void _showSnackBar(String message, Color color, IconData icon) {
//     if (!mounted) return;
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             Icon(icon, color: Colors.white),
//             const SizedBox(width: 10),
//             Expanded(child: Text(message)),
//           ],
//         ),
//         backgroundColor: color,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         duration: const Duration(seconds: 3),
//       ),
//     );
//   }
// }
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../core/constants/appColors.dart';
import '../../data/providers/payment_provider.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedPlan = 1; // Default selection is 1 Month Plan
  bool _isDownloading = false;

  // Mapping subscription plans to IDs (adjust according to your backend)
  final Map<int, int> _planToSubscriptionId = {
    1: 1, // 1 Month Plan
    2: 2, // 3 Month Plan
    3: 3, // 1 Year Plan
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const Expanded(
                    child: Text(
                      'Support Our Growth',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🌱', style: TextStyle(fontSize: 60)),
                      const SizedBox(height: 16),
                      Text(
                        'Your Support Fuels Our Growth',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Every contribution helps us build faster, debug deeper, and design better. This app is more than just lines of code—it\'s a commitment to empowering teams and simplifying work life.\n\nYour support ensures:\n🔧 Reliable updates and new features\n🛡️ Secure and stable performance\n🧠 Smarter tools backed by community-driven improvements\n\nIf you find value in what we\'re creating, we\'d be honored to have you behind us. Let\'s build something extraordinary—together.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Subscription options
                      _buildPlanOption(1, '1 Month Plan – NPR 875'),
                      _buildPlanOption(2, '3 Month Plan – NPR 2400'),
                      _buildPlanOption(3, '1 Year Plan – NPR 8400'),

                      const SizedBox(height: 30),

                      // Support Button with Stripe Integration
                      Consumer<PaymentProvider>(
                        builder: (context, paymentProvider, child) {
                          return Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.secondary,
                                  AppColors.primary,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.secondary.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: paymentProvider.isProcessing
                                  ? null
                                  : () => _handlePayment(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: paymentProvider.isProcessing
                                  ? const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  Colors.white,
                                                ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Processing...',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    )
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.favorite,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          'Support Our Journey',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanOption(int value, String label) {
    final bool isSelected = _selectedPlan == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPlan = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey,
                  width: 2,
                ),
              ),
              child: Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? AppColors.primary : Colors.grey[800],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handle the complete payment process
  Future<void> _handlePayment(BuildContext context) async {
    final paymentProvider = Provider.of<PaymentProvider>(
      context,
      listen: false,
    );
    final subscriptionId = _planToSubscriptionId[_selectedPlan]!;

    try {
      // Step 1: Initialize payment sheet
      _showSnackBar('Initializing payment...', AppColors.primary, Icons.info);

      final initSuccess = await paymentProvider.initializePaymentSheet(
        subscriptionId,
      );

      if (!initSuccess) {
        _showSnackBar(
          paymentProvider.errorMessage ?? 'Failed to initialize payment',
          Colors.red,
          Icons.error,
        );
        return;
      }

      // Step 2: Present payment sheet
      final paymentResult = await paymentProvider.presentPaymentSheet();

      // Step 3: Handle result
      if (paymentResult.isSuccess) {
        _showPaymentSuccessDialog(paymentResult.data!);
      } else if (paymentResult.isCancelled) {
        _showSnackBar('Payment cancelled', Colors.orange, Icons.cancel);
      } else {
        _showSnackBar(
          paymentResult.errorMessage ?? 'Payment failed',
          Colors.red,
          Icons.error,
        );
      }
    } catch (e) {
      _showSnackBar('Unexpected error: $e', Colors.red, Icons.error);
    }
  }

  /// Show payment success dialog
  void _showPaymentSuccessDialog(Map<String, dynamic> successData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 30),
              SizedBox(width: 10),
              Text("Payment Successful!"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Thank you for supporting our journey!"),
              const SizedBox(height: 10),
              Text("Plan: ${_getPlanName(_selectedPlan)}"),
              const SizedBox(height: 10),
              if (successData.containsKey('message'))
                Text("Message: ${successData['message']}"),
              if (successData.containsKey('transaction_id'))
                Text("Transaction ID: ${successData['transaction_id']}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Show download dialog after closing success dialog
                _showDownloadDialog(successData);
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  /// Show download invoice dialog
  void _showDownloadDialog(Map<String, dynamic> paymentData) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.file_download, color: Colors.blue, size: 30),
              SizedBox(width: 10),
              Text("Download Invoice"),
            ],
          ),
          content: const Text(
            "Would you like to download your payment invoice?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Go back to previous screen
              },
              child: const Text("Skip"),
            ),
            ElevatedButton(
              onPressed: _isDownloading
                  ? null
                  : () async {
                      Navigator.of(context).pop();
                      await _downloadInvoice(paymentData);
                      Navigator.of(context).pop(); // Go back to previous screen
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: _isDownloading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text("Download"),
            ),
          ],
        );
      },
    );
  }

  /// Download invoice PDF
  Future<void> _downloadInvoice(Map<String, dynamic> paymentData) async {
    if (!paymentData.containsKey('invoice_url') ||
        paymentData['invoice_url'] == null ||
        paymentData['invoice_url'].toString().isEmpty) {
      _showSnackBar('Invoice URL not available', Colors.red, Icons.error);
      return;
    }

    setState(() {
      _isDownloading = true;
    });

    try {
      // Request storage permission
      final permissionStatus = await _requestStoragePermission();
      if (!permissionStatus) {
        _showSnackBar('Storage permission denied', Colors.red, Icons.error);
        return;
      }

      final invoiceUrl = paymentData['invoice_url'].toString();

      // Get download directory
      Directory? downloadDir;
      if (Platform.isAndroid) {
        downloadDir = Directory('/storage/emulated/0/Download');
        if (!await downloadDir.exists()) {
          downloadDir = await getExternalStorageDirectory();
        }
      } else {
        downloadDir = await getApplicationDocumentsDirectory();
      }

      if (downloadDir == null) {
        throw Exception('Could not access download directory');
      }

      // Generate filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'invoice_${timestamp}.pdf';
      final filePath = '${downloadDir.path}/$fileName';

      // Show download progress
      _showSnackBar(
        'Downloading invoice...',
        AppColors.primary,
        Icons.download,
      );

      // Download the file
      final dio = Dio();
      await dio.download(
        invoiceUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(0);
            print('Download progress: $progress%');
          }
        },
      );

      // Verify file exists
      final file = File(filePath);
      if (await file.exists()) {
        _showSnackBar(
          'Invoice downloaded successfully',
          Colors.green,
          Icons.check_circle,
        );

        // Optionally open the file
        _showOpenFileDialog(filePath);
      } else {
        throw Exception('File download failed');
      }
    } catch (e) {
      _showSnackBar(
        'Download failed: ${e.toString()}',
        Colors.red,
        Icons.error,
      );
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  /// Request storage permission
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 30) {
        // Android 11+ - no need for storage permission for Downloads folder
        return true;
      } else {
        // Android 10 and below
        final status = await Permission.storage.request();
        return status == PermissionStatus.granted;
      }
    }
    return true; // iOS doesn't need explicit storage permission
  }

  /// Show dialog to open downloaded file
  void _showOpenFileDialog(String filePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Download Complete"),
          content: const Text(
            "Invoice downloaded successfully. Would you like to open it?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await OpenFile.open(filePath);
                } catch (e) {
                  _showSnackBar(
                    'Could not open file: ${e.toString()}',
                    Colors.orange,
                    Icons.warning,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text("Open"),
            ),
          ],
        );
      },
    );
  }

  String _getPlanName(int planId) {
    switch (planId) {
      case 1:
        return '1 Month Plan – NPR 875';
      case 2:
        return '3 Month Plan – NPR 2400';
      case 3:
        return '1 Year Plan – NPR 8400';
      default:
        return 'Unknown Plan';
    }
  }

  /// Show snackbar with message
  void _showSnackBar(String message, Color color, IconData icon) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
