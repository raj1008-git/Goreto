import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class SignupPage extends StatelessWidget {
  final themeColor = const Color(0xFFFFA726); // Orange gradient start

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.arrow_back, size: 28),
            const SizedBox(height: 40),
            Text(
              "Hello! Register to get started",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: themeColor,
              ),
            ),
            const SizedBox(height: 30),

            // Username Field
            _buildTextField("Username"),
            const SizedBox(height: 16),

            // Email Field
            _buildTextField("Email"),
            const SizedBox(height: 16),

            // Password Field
            _buildTextField("Password", obscure: true),
            const SizedBox(height: 16),

            // Confirm Password Field
            _buildTextField("Confirm password", obscure: true),
            const SizedBox(height: 24),

            // Register Button
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [Color(0xFFFFA726), Color(0xFFFFCC80)],
                ),
              ),
              child: ElevatedButton(
                onPressed: () {
                  // Registration logic here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text("Register"),
              ),
            ),

            const SizedBox(height: 30),

            // Divider with text
            Row(
              children: <Widget>[
                Expanded(child: Divider(thickness: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text("Or Register with"),
                ),
                Expanded(child: Divider(thickness: 1)),
              ],
            ),
            const SizedBox(height: 20),

            // Google Button
            Center(
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/4/4a/Logo_2013_Google.png',
                  width: 28,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Already have account
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.login);
                },
                child: Text.rich(
                  TextSpan(
                    text: "Already have an account? ",
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: "Login Now",
                        style: TextStyle(color: themeColor),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, {bool obscure = false}) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
