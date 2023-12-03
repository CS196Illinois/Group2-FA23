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
  @override
  void initState() {
    super.initState();
    // Fetching data from the 'items' table in the Supabase database when the widget is initialized
    // _future = Supabase.instance.client.from('items').select().then((response) {
    User? user = Supabase.instance.client.auth.currentUser;
    _stream = Supabase.instance.client.from('users').stream(primaryKey: [
      'email'
    ]).map((maps) => List<Map<String, dynamic>>.from(maps));
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
            itemBuilder: (context, index) {
              final item = items[index];
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ItemWidget(text: item['name']),
                      ],
                    ),
                  ),
                ),
              );
            });
      },
    );
  }
}

class ItemWidget extends StatelessWidget {
  final String text;

  ItemWidget({
    Key? key,
    required this.text,
    //required line
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: SizedBox(
        height: 80,
        width: 550,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: CircularWidget(),
            ),
            SizedBox(width: 20),
            Text(text),
            Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  LeftSmallCircle(),
                  InkWell(
                    onTap: () async {
                      final data = await supabase
                          .from('users')
                          .select('matches')
                          .eq('email', user?.email);
                      List<dynamic> user_matches = data[0]['matches'];
                      print('Here is match: ${user_matches}');
                      user_matches.add(item['email']);
                      await supabase
                          .from('users')
                          .update({'matches': user_matches}).match(
                              {'email': user?.email});
                      print('Here is matches: ${user_matches}');

                      print('Favorite Icon Clicked');
                    },
                    child: Icon(
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
                    onTap: () {
                      print('Cancel Icon Clicked');
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
