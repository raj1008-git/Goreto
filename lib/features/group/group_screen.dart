import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/providers/group_provider.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/services/dio_client.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  void _showPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Limit Reached"),
          content: const Text(
            "You've reached the maximum number of groups. Please subscribe to create more.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _initiateStripePayment(context); // 🔁 Stripe logic in next step
              },
              child: const Text("Subscribe Now"),
            ),
          ],
        );
      },
    );
  }

  void _initiateStripePayment(BuildContext context) async {
    final Dio dio = DioClient().dio;

    debugPrint("💰 Initiating Stripe payment...");

    try {
      final response = await dio.post(
        "${ApiEndpoints.baseUrl}/payments",
        data: {
          "type": "group_subscription",
          "subscription_id": 1, // Explicitly added for debugging
          "payment_method_types": ["card"],
        },
      );

      debugPrint("🟢 Payment response: ${response.data}");

      final String url = response.data['payment_url'];
      debugPrint("🔗 Payment URL: $url");

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        throw Exception('❌ Could not launch payment URL');
      }
    } on DioError catch (e) {
      debugPrint("❌ Payment failed: ${e.response?.data}");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Payment failed: ${e.response?.data['message'] ?? e.message}",
          ),
        ),
      );
    }
  }

  void _createGroup() async {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      debugPrint("⚠️ No group name entered");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a group name")),
      );
      return;
    }

    debugPrint("📥 [UI] Trying to create group with name: $name");

    setState(() {
      _isLoading = true;
    });

    try {
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
      final group = await groupProvider.createGroup(name);
      if (!mounted) return;

      debugPrint("🟢 [UI] Group '${group.name}' created successfully");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Group '${group.name}' created successfully")),
      );
      _controller.clear(); // clear input
    } on DioError catch (e) {
      debugPrint("❌ [UI] DioError when creating group: ${e.response?.data}");

      if (!mounted) return;
      final message = e.response?.data['message'];

      if (message ==
          "Group creation limit reached. Please subscribe to create more groups.") {
        debugPrint("🚧 Group limit hit - prompting for payment");
        _showPaymentDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message ?? "Failed to create group")),
        );
      }
    } catch (e) {
      debugPrint("❌ [UI] Unknown error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Unexpected error occurred.")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create a Group")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Group Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _createGroup,
                    icon: const Icon(Icons.group_add),
                    label: const Text("Create Group"),
                  ),
          ],
        ),
      ),
    );
  }
}
