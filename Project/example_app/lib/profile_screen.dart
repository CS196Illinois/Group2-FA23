// ignore_for_file: slash_for_doc_comments

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ProfileScreen widget, which provides UI for the user's profile
/**
 * The `ProfileScreen` widget is defined as a `StatelessWidget` because it does not manage any mutable state within itself. 
 * In Flutter, a `StatelessWidget` is a widget that describes part of the user interface which can depend only 
 * on the configuration information (the arguments passed to the widget) and the `BuildContext` in which the widget is inflated. 
 * In the case of `ProfileScreen`, all the data it needs is fetched directly within the `build` method, and it does not need to maintain any mutable state over time. 
 * The user's email is fetched from the `Supabase` instance, and the UI is built based on this data. 
 * When the user signs out, the `Supabase` instance handles the state change, and `ProfileScreen` does not need to manage any state related to this action.
 * If there were any mutable state that needed to be managed within `ProfileScreen` (for example, if there were interactive elements on the screen that change over time)
 * ,then it would be necessary to convert `ProfileScreen` to a `StatefulWidget`. 
 * However, since all state management related to user authentication is handled by the `Supabase` instance, and `ProfileScreen` simply reflects the current state of authentication, 
 * a `StatelessWidget` is sufficient.
 * 
 * This is just for THE EXAMPLE APP. You may have to turn this into a `StatefulWidget` widget as you continue building this screen as your matches may change over time.
 * Look at the groups_screen.dart or home_screen.dart for an example of `StatefulWidget`.
 */
class ProfileScreen extends StatelessWidget {
  // Constructor for the ProfileScreen widget
  const ProfileScreen({Key? key}) : super(key: key);
  final double coverHeight = 100;
  final double profileHeight = 80;

  @override
  Widget build(BuildContext context) {
    // Fetching the current user from Supabase
    final user = Supabase.instance.client.auth.currentUser;

    // Scaffold widget provides a high-level structure for the screen
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      // Center widget centers its child widget
      body: Center(
        // Column widget arranges its children in a vertical line
        child: Column(
          // Aligning children to the center of the main axis
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  buildCoverImage(),
                  Positioned(
                    top: 10,
                    child: buildProfileImage(),
                  )
                ]),
            Container(
              padding: const EdgeInsets.only(bottom: 8),
              child: const Center(
                child: Text(
                  'Jenni Sanford',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
                ),
              ),
            ),

            Center(
              child: Text(
                'Computer Science',
                style: TextStyle(color: Colors.grey[800], fontSize: 16),
              ),
            ),
            const Center(
              child: Padding(
                padding: EdgeInsets.only(
                  top: 10.0,
                  left: 5.0,
                  right: 5.0,
                ),
                child: Text(
                  'Hey, I’m Jenni! I love math and computer science. Here’s my Insta if you wanna study together: @jenni__sanford',
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Text(
                'Classes',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(5),
              color: const Color.fromARGB(255, 232, 180, 176),
              child: const Text(
                'Computer Science Orientation (CS 100)',
                style: TextStyle(fontSize: 13),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(5),
              color: const Color.fromARGB(255, 190, 236, 237),
              child: const Text(
                'Writing and Research (RHET 105)',
                style: TextStyle(fontSize: 13),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(5),
              color: const Color.fromARGB(255, 187, 176, 232),
              child: const Text(
                'Calculus II (Math 231)',
                style: TextStyle(fontSize: 13),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(5),
              color: const Color.fromARGB(255, 181, 232, 176),
              child: const Text(
                'Intro to Computer Science (CS 124)',
                style: TextStyle(fontSize: 13),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Text(
                'Groups',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 3.0),
              child: Text(
                'Calculus II Study Group',
                style: TextStyle(fontSize: 13),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 3.0),
              child: Text(
                'CS 124 Study Group',
                style: TextStyle(fontSize: 13),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 3.0),
              child: Text(
                'RHET 105 Group',
                style: TextStyle(fontSize: 13),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Text(
                'Matches ✔️',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            // Displaying the user's email
            Text('Email: ${user?.email}'),
            // SizedBox widget provides a box with a specified size
            const SizedBox(height: 20),
            // ElevatedButton widget provides a Material Design raised button
            ElevatedButton(
              // Callback function when the button is pressed
              onPressed: () async {
                // Signing out the user from Supabase
                await Supabase.instance.client.auth
                    .signOut(); // takes them back to the login screen
              },
              // Text widget provides a label for the button
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCoverImage() => Container(
        color: Colors.grey,
        child: Image.network(
          "https://img.rawpixel.com/s3fs-private/rawpixel_images/website_content/v1016-c-08_1-ksh6mza3.jpg?w=800&dpr=1&fit=default&crop=default&q=65&vib=3&con=3&usm=15&bg=F4F4F3&ixlib=js-2.2.1&s=f584d8501c27c5f649bc2cfce50705c0",
          width: double.infinity,
          height: coverHeight,
          fit: BoxFit.cover,
        ),
      );

  Widget buildProfileImage() => CircleAvatar(
        radius: profileHeight / 2,
        backgroundColor: Colors.grey.shade800,
        backgroundImage: NetworkImage(
            "https://static.generated.photos/vue-static/face-generator/landing/wall/7.jpg"),
      );
}
