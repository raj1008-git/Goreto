// lib/providers/payment_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:goreto/core/services/dio_client.dart';
import 'package:goreto/data/datasources/remote/payment_api_service.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentApiService _paymentService = PaymentApiService(DioClient().dio);

  bool _isPaymentReady = false;
  bool _isProcessing = false;
  Map<String, dynamic>? _currentPaymentData;
  String? _errorMessage;

  // Getters
  bool get isPaymentReady => _isPaymentReady;
  bool get isProcessing => _isProcessing;
  Map<String, dynamic>? get currentPaymentData => _currentPaymentData;
  String? get errorMessage => _errorMessage;

  /// Initialize the payment sheet with your backend API
  Future<bool> initializePaymentSheet(int subscriptionId) async {
    _setProcessing(true);
    _setPaymentReady(false);
    _setError(null);

    try {
      // Step 1: Create payment intent using your backend API
      final paymentData = await _paymentService.createPaymentIntent(
        subscriptionId: subscriptionId,
        paymentMethodTypes: ["card"],
      );

      _currentPaymentData = paymentData;

      // Step 2: Initialize Stripe payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          // Required parameters
          paymentIntentClientSecret: paymentData['client_secret'],
          merchantDisplayName: 'GoReTo',

          // Optional parameters for better UX
          style: ThemeMode.system,

          // Google Pay configuration (optional) - keeping this for Android
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'NP',
            testEnv: true, // Set to false for production
          ),

          // Billing details (optional)
          billingDetails: const BillingDetails(
            address: Address(
              country: 'NP',
              city: '',
              line1: '',
              line2: '',
              postalCode: '',
              state: '',
            ),
          ),

          // UI customization (optional)
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(primary: Colors.blue),
          ),
        ),
      );

      _setPaymentReady(true);
      _setProcessing(false);
      return true;
    } catch (e) {
      _setError("Failed to initialize payment: $e");
      _setProcessing(false);
      _setPaymentReady(false);
      return false;
    }
  }

  /// Present the payment sheet to the user
  Future<PaymentResult> presentPaymentSheet() async {
    if (_currentPaymentData == null) {
      return PaymentResult.error("Please initialize payment first");
    }

    _setProcessing(true);

    try {
      // Present the payment sheet
      await Stripe.instance.presentPaymentSheet();

      final paymentResult = await _handlePaymentSuccess();
      return paymentResult;
    } on StripeException catch (e) {
      _setProcessing(false);

      if (e.error.code == FailureCode.Canceled) {
        return PaymentResult.cancelled();
      } else {
        return PaymentResult.error("Payment failed: ${e.error.message}");
      }
    } catch (e) {
      _setProcessing(false);
      return PaymentResult.error("Payment failed: $e");
    }
  }

  // Future<PaymentResult> _handlePaymentSuccess() async {
  //   try {
  //     if (_currentPaymentData == null) {
  //       throw Exception("No payment data available");
  //     }
  //
  //     final userId = _currentPaymentData!['user_id'] as int;
  //     final paymentId = _currentPaymentData!['payment_id'] as int;
  //
  //     // Call backend to confirm success
  //     final successResponse = await _paymentService.confirmPaymentSuccess(
  //       userId: userId,
  //       paymentId: paymentId,
  //     );
  //
  //     // Save the data before nullifying it
  //     final data = _currentPaymentData;
  //
  //     _setProcessing(false);
  //     _setPaymentReady(false);
  //     _currentPaymentData = null;
  //
  //     // Return a full success result
  //     return PaymentResult.success(data!);
  //   } catch (e) {
  //     _setProcessing(false);
  //     _setError("Payment completed but confirmation failed: $e");
  //     return PaymentResult.error(
  //       "Payment confirmed but app failed to handle it: $e",
  //     );
  //   }
  // }
  Future<PaymentResult> _handlePaymentSuccess() async {
    try {
      if (_currentPaymentData == null) {
        throw Exception("No payment data available");
      }

      final userId = _currentPaymentData!['user_id'] as int;
      final paymentId = _currentPaymentData!['payment_id'] as int;

      // Call backend to confirm success
      final successResponse = await _paymentService.confirmPaymentSuccess(
        userId: userId,
        paymentId: paymentId,
      );

      // Merge the API response with current payment data
      final completePaymentData = {
        ..._currentPaymentData!,
        ...successResponse, // This should include invoice_url from your API
      };

      _setProcessing(false);
      _setPaymentReady(false);
      _currentPaymentData = null;

      // Return success with complete data including invoice_url
      return PaymentResult.success(completePaymentData);
    } catch (e) {
      _setProcessing(false);
      _setError("Payment completed but confirmation failed: $e");
      return PaymentResult.error(
        "Payment confirmed but app failed to handle it: $e",
      );
    }
  }

  /// Reset payment state
  void resetPaymentState() {
    _isPaymentReady = false;
    _isProcessing = false;
    _currentPaymentData = null;
    _errorMessage = null;
    notifyListeners();
  }

  // Private helper methods
  void _setProcessing(bool processing) {
    _isProcessing = processing;
    notifyListeners();
  }

  void _setPaymentReady(bool ready) {
    _isPaymentReady = ready;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }
}

/// Payment result class to handle different outcomes
class PaymentResult {
  final bool isSuccess;
  final bool isCancelled;
  final String? errorMessage;
  final Map<String, dynamic>? data;

  PaymentResult.success(this.data)
    : isSuccess = true,
      isCancelled = false,
      errorMessage = null;

  PaymentResult.cancelled()
    : isSuccess = false,
      isCancelled = true,
      errorMessage = null,
      data = null;

  PaymentResult.error(this.errorMessage)
    : isSuccess = false,
      isCancelled = false,
      data = null;
}
