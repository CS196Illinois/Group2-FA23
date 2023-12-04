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
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final double coverHeight = 100;
  final double profileHeight = 80;

  late final Stream<List<Map<String, dynamic>>> _stream;
  List<String> user_groups = [];

  User? user = Supabase.instance.client.auth.currentUser;

  @override
  void initState() {
    super.initState();
    // Fetching data from the 'items' table in the Supabase database when the widget is initialized
    _stream = Supabase.instance.client
        .from('users')
        .stream(primaryKey: ['email'])
        .eq('email', user?.email)
        .limit(1)
        .map((maps) => List<Map<String, dynamic>>.from(maps));
  }

  void fetchCourses(final groups) async {
    for (int group in groups) {
      final data = await Supabase.instance.client
          .from('courses')
          .select('course_name, users')
          .eq('course_ID', group)
          .single();
      print("hi: ${data['users']}");
      // print(data['users'].contains[user?.email));
      setState(() {
        if (data['users'] != null && data['users'].contains(user?.email)) {
          user_groups.add(data['course_name']);
        }
        // else {
        //   user_groups.add("No groups");
        // }
      });
    }
  }

  bool hasFetched = false;
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
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _stream, // The future to observe
        // The builder callback that returns a widget based on the latest snapshot
        builder: (context, snapshot) {
          // If the future is still running, show a loading indicator
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // If the future completes with no data, show a message indicating no items were found
          if (snapshot.data!.isEmpty) {
            return const Center(child: Text('No items found'));
          }
          // If the future completes with data, display the list of items
          final items = snapshot.data!;
          return ListView.builder(
            // The number of items in the list
            itemCount: items.length,
            // Builder callback to create a ListTile widget for each item in the list
            itemBuilder: (context, index) {
              final item = items[index];
              print(item['name']);
              print(item['email']);
              print(item['major']);
              print(item['bio']);
              print(item['courses']);
              print(item['groups']);
              print(item['matches']);
              if (!hasFetched) {
                fetchCourses(item['groups']);
                hasFetched = true;
              }

              // print(item[]);
              return Center(
                // Display the name of the item
                //title: Text(item['name']),
                // Display the image URL of the item
                //subtitle: Text(item['email']));
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
                      child: Center(
                        child: Text(
                          item['name'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 30),
                        ),
                      ),
                    ),

                    Center(
                      child: Text(
                        item['major'],
                        style: TextStyle(color: Colors.grey[800], fontSize: 16),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 10.0,
                          left: 5.0,
                          right: 5.0,
                        ),
                        child: Text(
                          item['bio'],
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        'Classes',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: item['courses'].map<Widget>((course) {
                        return Container(
                          margin: const EdgeInsets.all(5),
                          color:
                              Colors.grey[200], // You can customize this color
                          child: Text(
                            course, // Assuming 'course' is a String
                            style: const TextStyle(fontSize: 13),
                          ),
                        );
                      }).toList(),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Text(
                        'Groups',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: user_groups.map<Widget>((group) {
                        return Container(
                          margin: const EdgeInsets.all(5),
                          color:
                              Colors.grey[200], // You can customize this color
                          child: Text(
                            group, // Assuming 'course' is a String
                            style: const TextStyle(fontSize: 13),
                          ),
                        );
                      }).toList(),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Text(
                        'Matches ✔️',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: item['matches'].map<Widget>((match) {
                        return Container(
                          margin: const EdgeInsets.all(5),
                          color:
                              Colors.grey[200], // You can customize this color
                          child: Text(
                            match, // Assuming 'course' is a String
                            style: const TextStyle(fontSize: 13),
                          ),
                        );
                      }).toList(),
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
              );
            },
          );
        },
        // Column widget arranges its children in a vertical line
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

// class ProfileCard extends StatefulWidget {
//   final Stream<List name;
//   final String major;
//   final String bio;

//   const Section1({Key? key, required this.name, required this.major, required this.bio}) : super(key: key);

//   @override
//   _Section1State createState() => _Section1State();
// }

// class _Section1State extends State<ProfileScreen> {
//   void initState() {
//     super.initState();
//   }
//   Widget build (BuildContext context) {
//     Column(
//                   // Aligning children to the center of the main axis
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Stack(
//                         clipBehavior: Clip.none,
//                         alignment: Alignment.center,
//                         children: [
//                           buildCoverImage(),
//                           Positioned(
//                             top: 10,
//                             child: buildProfileImage(),
//                           )
//                         ]),
//                     Container(
//                       padding: const EdgeInsets.only(bottom: 8),
//                       child: Center(
//                         child: Text(
//                           item['name'],
//                           style: const TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 30),
//                         ),
//                       ),
//                     ),

//                     Center(
//                       child: Text(
//                         item['major'],
//                         style: TextStyle(color: Colors.grey[800], fontSize: 16),
//                       ),
//                     ),
//                     Center(
//                       child: Padding(
//                         padding: const EdgeInsets.only(
//                           top: 10.0,
//                           left: 5.0,
//                           right: 5.0,
//                         ),
//                         child: Text(
//                           item['bio'],
//                           style: const TextStyle(fontSize: 12),
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                     ),
//                     const Padding(
//                       padding: EdgeInsets.only(top: 10.0),
//                       child: Text(
//                         'Classes',
//                         style: TextStyle(
//                             fontWeight: FontWeight.bold, fontSize: 18),
//                       ),
//                     ),
//                   ]
//     );
//   }
// }