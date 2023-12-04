import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreenContent extends StatefulWidget {
  final Stream<List<Map<String, dynamic>>> stream;

  const HomeScreenContent({Key? key, required this.stream}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreenContent> {
  late final Stream<List<Map<String, dynamic>>> _stream;
  User? user = Supabase.instance.client.auth.currentUser;

  @override
  void initState() {
    super.initState();
    // Fetching data from the 'items' table in the Supabase database when the widget is initialized
    // _future = Supabase.instance.client.from('items').select().then((response) {
    _stream = Supabase.instance.client
        .from('users')
        .stream(primaryKey: ['email'])
        .neq('email', user?.email)
        .map((maps) => List<Map<String, dynamic>>.from(maps));
    // then((response) {
    //   if (response == null) {
    //     // If there is an error fetching the data, print the error and return an empty list
    //     print('Error fetching items: ${response.error}');
    //     return [];
    //   } else {
    //     // If the data is fetched successfully, return the list of items
    //     return List<Map<String, dynamic>>.from(
    //         response); // casting response into the List<Map<String, dynamic>> type
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.isEmpty) {
          return const Center(child: Text('No items found'));
        }
        final items = snapshot.data!;
        //print(items);
        return ListView.builder(
          itemCount: items.length,
          itemExtent: 100,
          itemBuilder: (context, index) {
            final item = items[index];
            return Center(
              child: ItemWidget(
                userData: item,
                current_user_email: user?.email,
              ),
            );
          },
        );
      },
    );
  }
}

class ItemWidget extends StatelessWidget {
  final userData;
  final current_user_email;

  ItemWidget({Key? key, required this.userData, required this.current_user_email
      //required line
      })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      //margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      margin: EdgeInsets.all(1.0),
      child: SizedBox(
        height: 80,
        width: 550,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: CircularWidget(),
            ),
            const SizedBox(width: 20),
            Text(userData['name']),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  LeftSmallCircle(),
                  InkWell(
                    onTap: () async {
                      final data = await Supabase.instance.client
                          .from('users')
                          .select('matches')
                          .eq('email', current_user_email);
                      List<dynamic> user_matches = [];
                      if (data[0]['matches'] != null) {
                        user_matches = data[0]['matches'];
                      }
                      // print('Here are previous matches: ${user_matches}');
                      if (!(user_matches.contains(userData['email']))) {
                        user_matches.add(userData['email']);
                        await Supabase.instance.client
                            .from('users')
                            .update({'matches': user_matches}).match(
                                {'email': current_user_email});
                        // print('Here are current matches: ${user_matches}');
                      }
                    },
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  RightSmallCircle(),
                  InkWell(
                    onTap: () async {
                      final data = await Supabase.instance.client
                          .from('users')
                          .select('matches')
                          .eq('email', current_user_email);
                      List<dynamic> user_matches = [];
                      if (data[0]['matches'] != null) {
                        user_matches = data[0]['matches'];
                      }
                      print('Here are previous matches: ${user_matches}');
                      if (user_matches.contains(userData['email'])) {
                        user_matches.remove(userData['email']);
                        await Supabase.instance.client
                            .from('users')
                            .update({'matches': user_matches}).match(
                                {'email': current_user_email});
                        if (user_matches.length == 0) {
                          print("You currently have no matches");
                        } else {
                          print('Here are current matches: ${user_matches}');
                        }
                      } else {
                        if (user_matches.length == 0) {
                          print("You currently have no matches");
                        }
                        print(
                            "Cannot remove user who is not already part of your matches");
                      }
                    },
                    child: Icon(
                      Icons.cancel,
                      color: Color.fromARGB(255, 0, 42, 66),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CircularWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 75,
      height: 75,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color.fromARGB(255, 123, 121, 121),
      ),
    );
  }
}

class RightSmallCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color.fromARGB(255, 123, 121, 121),
      ),
    );
  }
}

class LeftSmallCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color.fromARGB(255, 123, 121, 121),
      ),
    );
  }
}

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const _MyHomePage(title: 'App Name + Logo'),
//     );
//   }
// }

// class _MyHomePage extends StatefulWidget {
//   final String title;

//   const _MyHomePage({super.key, required this.title});

//   @override
// }

// class _MyHomePageState  {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//     );
//   }
// }