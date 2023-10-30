// importing packages
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// importing local files in the same directory
import 'profile_screen.dart';
import 'groups_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // for displaying the list of items in table
  late final Stream<List<Map<String, dynamic>>> _stream;
  // for selecting which screen user clicks on
  int _selectedScrennIndex = 1;
  // list of screens

  @override
  void initState() {
    super.initState();
    _stream = Supabase.instance.client.from('items').stream(primaryKey: [
      'id'
    ]).map((maps) => List<Map<String, dynamic>>.from(maps));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedScrennIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // List of widgets with the first one being the content to be displayed
    List<Widget> widgetOptions = <Widget>[
      const ProfileScreen(),
      StreamBuilder<List<Map<String, dynamic>>>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.isEmpty) {
            return const Center(child: Text('No items found'));
          }
          final items = snapshot.data!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Items List',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      title: Text(item['name']),
                      subtitle: Text(item['image_url']),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      const GroupsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Buddies'),
      ),
      body: Center(
        child: widgetOptions.elementAt(_selectedScrennIndex),
      ),
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
        onTap: _onItemTapped,
      ),
    );
  }
}
