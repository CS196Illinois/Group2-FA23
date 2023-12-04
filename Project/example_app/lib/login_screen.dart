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
class LoginScreen extends StatefulWidget {
  // Constructor for the LoginScreen widget
  const LoginScreen({Key? key}) : super(key: key);
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // late final Future<List<Map<String, dynamic>>> _future;
  @override
  void initState() {
    super.initState();
    // Fetching data from the 'users' table in the Supabase database when the widget is initialized
    
  }

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
          onSignUpComplete: (response) async {
            if (response.user != null) {
              String major = response.user?.userMetadata?['major'] ?? '';
              String bio = response.user?.userMetadata?['bio'] ?? '';
              String name = response.user?.userMetadata?['name'] ?? '';
              String rawCourses = response.user?.userMetadata?['courses'] ?? '';
              List<String> courses = rawCourses.split(',').map((course) => course.trim()).toList();
              print(major);
              print(rawCourses);
              print("Hello see if others print");
              List<String> formattedCourses = courses.map((course) {
                //TODO formatting of array
                return course;
              }).toList();
              final supabase = Supabase.instance.client;
              if (supabase != null && response.user?.email != null) {
                // Update the Supabase database with the user's major and courses
                final insertResponse = await supabase.from('users').insert({
                  'email': response.user?.email,
                  'name': name,
                  'major': major,
                  'bio': bio,
                  'courses': formattedCourses,
                  'matches': [],
                  'groups': [],
                  'created_at': response.user?.createdAt,
                });

                print('Insert response: $insertResponse');
                
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              } else {
                print('Supabase instance or user email is null');
              }
            } else {
              print('Sign up failed');
            }
          },
// ...



          // List of additional metadata fields for the form
          metadataFields: [
            MetaDataField(
              // Icon for the username field
              prefixIcon: const Icon(Icons.person),
              // Label for the username field
              label: 'Name',
              // Key for the metadata field
              key: 'name',
              // Validator function for the username field
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Please enter something';
                }
                return null;
              },
            ),

            MetaDataField(
              // Icon for the major field
              prefixIcon: const Icon(Icons.school),
              // Label for the major field
              label: 'Major',
              // Key for the metadata field
              key: 'major',
              // Validator function for the major field
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Please enter something';
                }
                return null;
              },
            ),

            MetaDataField(
              // Icon for the username field
              prefixIcon: const Icon(Icons.pentagon),
              // Label for the username field
              label: 'Bio',
              // Key for the metadata field
              key: 'bio',
              // Validator function for the username field
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Please enter something';
                }
                return null;
              },
            ),

            MetaDataField(
              // Icon for the username field
              prefixIcon: const Icon(Icons.book_sharp),
              // Label for the username field
              label: 'Courses',
              // Key for the metadata field
              key: 'courses',
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
