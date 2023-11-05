import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/**
 * The `GroupsScreen` widget is defined as a `StatefulWidget` because it manages mutable state within itself, specifically the state of the future `_future` that holds the data fetched from the Supabase database.
 * 1. `Data Fetching and State Management`: `GroupsScreen` fetches data from the Supabase database in its `initState` method and stores this data in a `Future`. 
 *    The state of this `Future` (whether it is still loading, has completed with data, or has completed with an error) determines what is displayed on the screen. 
 *    This is mutable state that changes over time (as the `Future` completes), and so it needs to be managed within a `StatefulWidget`.
 * 2. `Lifecycle Methods`: `GroupsScreen` uses the `initState` lifecycle method to initiate the data fetching when the widget is first created. 
 *    `StatefulWidget` provides lifecycle methods like `initState`, `didUpdateWidget`, and `dispose` that allow you to manage the widget's state and 
 *    resources over its lifecycle, which is not possible with a `StatelessWidget`.

 * On the other hand, `ProfileScreen` is a `StatelessWidget` because it does not manage any mutable state within itself. 
 * It simply displays the current user's email address, which is fetched directly from the Supabase instance, and provides a button to sign out. 
 * There are no internal state changes in `ProfileScreen` that need to be tracked over time, and so a `StatelessWidget` is sufficient FOR THIS EXAMPLE APP.

In summary, the key difference is that `GroupsScreen` manages mutable state (the result of a future) and 
has a more complex lifecycle (it fetches data when it is first created), while `ProfileScreen` simply displays data based on the current state of the Supabase instance 
and does not manage any internal state.
 */
class GroupsScreen extends StatefulWidget {
  const GroupsScreen({Key? key}) : super(key: key);

  @override
  _GroupsScreenState createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  // A Future that holds a list of maps, each map representing an item fetched from the database
  late final Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    // Fetching data from the 'items' table in the Supabase database when the widget is initialized
    _future = Supabase.instance.client.from('items').select().then((response) {
      if (response == null) {
        // If there is an error fetching the data, print the error and return an empty list
        print('Error fetching items: ${response.error}');
        return [];
      } else {
        // If the data is fetched successfully, return the list of items
        return List<Map<String, dynamic>>.from(
            response); // casting response into the List<Map<String, dynamic>> type
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold widget provides the basic visual structure for the screen
    return Scaffold(
      // AppBar widget displays a Material Design app bar at the top of the screen
      appBar: AppBar(
        title: const Text('Groups'),
      ),
      // FutureBuilder widget rebuilds its part of the widget tree based on the latest snapshot of the future
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future, // The future to observe
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
              return ListTile(
                // Display the name of the item
                title: Text(item['name']),
                // Display the image URL of the item
                subtitle: Text(item['image_url']),
              );
            },
          );
        },
      ),
    );
  }
}
