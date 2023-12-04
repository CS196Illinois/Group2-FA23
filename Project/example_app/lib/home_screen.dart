// importing packages
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// importing local files in the same directory
import 'profile_screen.dart';
import 'groups_screen.dart';
import 'homeScreen_content.dart';

/**
 * `HomeScreen` is a stateful widget that serves as the main screen of the application. It's stateful because it manages mutable state.
 *    Specifically, the _selectedScreenIndex, which keeps track of the currently selected tab in the BottomNavigationBar, is the mutable state.
 *    This state determines which screen or content is currently displayed to the user. 
 *    When a different tab is tapped, _onItemTapped is called, updating the _selectedScreenIndex state and causing the widget to rebuild 
 *    and display the content of the newly selected tab.
 * 
 * It contains a bottom navigation bar to switch between different sections: Profile, Home, and Groups.
 * The Home screen itself simply displays a list of items fetched from the Supabase database.
 * 
 * For the difference between StatefulWidget and StatelessWidget, look at the comments in `profile_screen.dart` and `groups_screen.dart`.
 */
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Stream for displaying the list of items from the Supabase database
  late final Stream<List<Map<String, dynamic>>> _stream;
  User? user = Supabase.instance.client.auth.currentUser;
  // index for selecting which screen the user is currently viewing
  int _selectedScrennIndex =
      1; // set to 1 because in our list below, we have the homeScreen in the list[1] position so we want to display the home screen first after user logs in

  @override
  void initState() {
    super.initState();
    // Initializing the stream to fetch data from the 'users' table in the Supabase database
    _stream = Supabase.instance.client
        .from('users')
        .stream(primaryKey: ['email'])
        .eq("email", user?.email)
        .limit(1)
        .map((maps) => List<Map<String, dynamic>>.from(maps));
  }

  // Function to handle item taps on the BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedScrennIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // List of widgets to display based on selected index
    // First is profiel with the second one being the home screen content to be displayed and finally the groups screen
    // adding more screens would mean you just create a new `new_screen.dart` file and then add it to this list after importing at the top
    List<Widget> widgetOptions = <Widget>[
      const ProfileScreen(),
      HomeScreenContent(
          current_user_stream: _stream), // ensuring we pass in a stream
      const GroupsScreen(),
      // another screen if necessary
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Buddies'),
      ),
      // Center widget centers its child widget
      body: Center(
        // Displaying the widget based on the currently selected index.
        child: widgetOptions.elementAt(_selectedScrennIndex),
      ),
      // bottom Navigation Bar widget with three icons
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Groups',
          ),
        ],
        currentIndex: _selectedScrennIndex,
        selectedItemColor: Colors.amber[800],
        // callback function so that whenever the user taps one of the icons on our navigation bar,
        // we show the corresponding screen by rebuilding the widget
        onTap: _onItemTapped,
      ),
    );
  }
}
