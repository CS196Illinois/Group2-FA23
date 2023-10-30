// importing packages
import 'package:flutter/material.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart'; // supabase already has auth ui that I used for this example
/**
 * ALL CODE FROM HERE:
 *  https://supabase.com/docs/guides/auth/auth-helpers/flutter-auth-ui
 * */
// importing files in same directory
import 'home_screen.dart';

// LoginScreen widget, which provides UI for user authentication
class LoginScreen extends StatelessWidget {
  // Constructor for the LoginScreen widget
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Scaffold widget provides a high-level structure for the screen
    return Scaffold(
      // Padding widget adds space around the child widget
      body: Padding(
        // EdgeInsets.all(16.0) adds 16 logical pixels of padding on all sides
        padding: const EdgeInsets.all(16.0),
        // SupaEmailAuth widget provides UI for email authentication
        /**
         * Use a SupaEmailAuth widget to create an email and password signin and signup form. 
         * It also contains a button to toggle to display a forgot password form.
         * You can pass metadataFields to add additional fields to the form to pass as metadata to Supabase.
         * In the future, use OAuth with Azure
         */
        child: SupaEmailAuth(
          redirectTo:
              null, // currently because it's just email, we don't need to set a redirectTo. If using OAuth, you do
          // Callback function when sign-in is complete
          onSignInComplete: (response) {
            // Handle sign in complete
            if (response.user != null) {
              // if user isn't null, go to Home Screen
              print('Sign in complete: $response');
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()));
            } else {
              // if user is null, print response
              print('Sign in user: ${response.user}');
            }
          },
          // Callback function when sign-up is complete
          onSignUpComplete: (response) {
            // Handle sign up complete
            if (response.user != null) {
              // If user is not null, navigate to the HomeScreen
              print('Sign up complete: $response');
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()));
            } else {
              print('Sign in user: ${response.user}');
            }
          },
          // List of additional metadata fields for the form
          metadataFields: [
            MetaDataField(
              // Icon for the username field
              prefixIcon: const Icon(Icons.person),
              // Label for the username field
              label: 'Username',
              // Key for the metadata field
              key: 'username',
              // Validator function for the username field
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
