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
  late final Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = Supabase.instance.client.from('items').select().then((response) {
      if (response == null) {
        print('Error fetching items: ${response.error}');
        return [];
      } else {
        return List<Map<String, dynamic>>.from(response);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.isEmpty) {
            return const Center(child: Text('No items found'));
          }
          final items = snapshot.data!;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item['name']),
                subtitle: Text(item['image_url']),
              );
            },
          );
        },
      ),
    );
  }
}
