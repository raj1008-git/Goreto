import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/appColors.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../core/utils/snackbar_helper.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              SnackbarHelper.show(context, "Logged out successfully");

              // Navigate back to login or landing screen
              Navigator.pushReplacementNamed(context, '/loginorregister');
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(
              child: Text(
                "Welcome to Dashboard,\nuser not logged in.",
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${user.name}!',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(Icons.email, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Text(user.email, style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.verified_user, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Text(
                        'Role: ${user.role}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  // Add more dashboard content here
                ],
              ),
            ),
    );
  }
}
