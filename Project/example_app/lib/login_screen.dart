import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
// importing files
import 'home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SupaEmailAuth(
          redirectTo: null, // Update this according to your setup
          onSignInComplete: (response) {
            // Handle sign in complete
            if (response.user != null) {
              print('Sign in complete: $response');
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()));
            } else {
              print('Sign in user: ${response.user}');
            }
          },
          onSignUpComplete: (response) {
            // Handle sign up complete
            if (response.user != null) {
              print('Sign up complete: $response');
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()));
            } else {
              print('Sign in user: ${response.user}');
            }
          },
          metadataFields: [
            MetaDataField(
              prefixIcon: const Icon(Icons.person),
              label: 'Username',
              key: 'username',
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Please enter something';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
