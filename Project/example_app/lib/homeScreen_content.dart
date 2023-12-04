import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreenContent extends StatefulWidget {
  final Stream<List<Map<String, dynamic>>> current_user_stream;

  const HomeScreenContent({Key? key, required this.current_user_stream})
      : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreenContent> {
  late final Stream<List<Map<String, dynamic>>> _stream;
  User? user = Supabase.instance.client.auth.currentUser;

  @override
  void initState() {
    super.initState();
    _stream = Supabase.instance.client
        .from('users')
        .stream(primaryKey: ['email'])
        .neq('email', user?.email) // not equal to current user
        .map((maps) => List<Map<String, dynamic>>.from(maps));
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
        final users = snapshot.data!;
        //print(items);
        return ListView.builder(
          itemCount: users.length,
          itemExtent: 100,
          itemBuilder: (context, index) {
            final one_user = users[index];
            return Center(
              child: ItemWidget(
                cardUserData: one_user,
                current_user_email: user?.email,
              ),
            );
          },
        );
      },
    );
  }
}

// Needs to be stateful widget now because the background color
// needs to change dynamically (green for match) based on user interactions
class ItemWidget extends StatefulWidget {
  const ItemWidget(
      {Key? key, required this.cardUserData, required this.current_user_email})
      : super(key: key);

  final cardUserData;
  final current_user_email;

  @override
  _ItemWidgetState createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  Color cardColor = Colors.white; // default color
  List<dynamic> current_user_matches = [];
  List<dynamic> card_user_matches = [];

  void _setInitialCardColor() async {
    // fetch current_user_matches
    final current_user_match_res = await Supabase.instance.client
        .from('users')
        .select('matches')
        .eq('email', widget.current_user_email)
        .single();
    current_user_matches = current_user_match_res['matches'];
    card_user_matches = widget.cardUserData['matches'];
    // setting initial Card Color
    // if card_user_matches contains current_user, then set to green
    // check if widget is still mounted before calling setState()
    print("${widget.cardUserData["name"]}'s matches: ${card_user_matches}\n");
    print("${widget.current_user_email}'s matches: ${current_user_matches}\n");
    if (mounted) {
      setState(() {
        // ternary operator if true, then set to Green else white
        cardColor = card_user_matches.contains(widget.current_user_email)
            ? Colors.green
            : Colors.white;
        print("For ${widget.cardUserData["name"]}, the color is ${cardColor}");
      });
    }
    // if () {
    //   cardColor = Colors.green; // set to green if they are matches
    // }
  }

  @override
  void initState() {
    super.initState();
    _setInitialCardColor(); // call this when page first loads
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      //margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      margin: const EdgeInsets.all(1.0),
      color: cardColor,
      child: SizedBox(
        height: 80,
        width: 550,
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 10),
              child: CircularWidget(),
            ),
            const SizedBox(width: 20),
            Text(widget.cardUserData['name']),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const LeftSmallCircle(),
                  InkWell(
                    onTap: () async {
                      print(
                          "Here is ${widget.cardUserData['name']}'s matches ${widget.cardUserData['matches']}");
                      // print('Here are previous matches: ${card_user_matches}');
                      final current_user_match_res = await Supabase
                          .instance.client
                          .from('users')
                          .select('matches')
                          .eq('email', widget.current_user_email)
                          .single();
                      current_user_matches = current_user_match_res['matches'];
                      if (!(current_user_matches
                          .contains(widget.cardUserData['email']))) {
                        // add to current user's matches array
                        current_user_matches.add(widget.cardUserData['email']);
                        // also add to that specific card user's matches as well
                        card_user_matches.add(widget.current_user_email);
                        // update current user's matches
                        await Supabase.instance.client
                            .from('users')
                            .update({'matches': current_user_matches}).match(
                                {'email': widget.current_user_email});
                        // update the card user's matches
                        await Supabase.instance.client
                            .from('users')
                            .update({'matches': card_user_matches}).match(
                                {'email': widget.cardUserData['email']});
                        // print('Here are current matches: ${card_user_matches}');
                        setState(() {
                          cardColor = Colors.green;
                        });
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
                  const RightSmallCircle(),
                  InkWell(
                    onTap: () async {
                      print(
                          "Here are ${widget.cardUserData['name']}'s previous matches ${widget.cardUserData['matches']}");
                      // since .remove has no effect if value wasn't in list, we can just remove directly without checking
                      // if it contains or not. however, to still print a message, we can base it
                      // off of what remove() returns which is:
                      //    true if value was in the list, false otherwise

                      // remove current user email from the card user
                      final current_user_match_res = await Supabase
                          .instance.client
                          .from('users')
                          .select('matches')
                          .eq('email', widget.current_user_email)
                          .single();
                      current_user_matches = current_user_match_res['matches'];
                      if (!card_user_matches
                          .remove(widget.current_user_email)) {
                        // enters in here if current_user_email was never a match of card user
                        print(
                            "Cannot remove user who is not already part of your matches!");
                      }
                      // remove card user email from the current user
                      current_user_matches.remove(widget.cardUserData['email']);
                      // update current user's matches
                      await Supabase.instance.client
                          .from('users')
                          .update({'matches': current_user_matches}).match(
                              {'email': widget.current_user_email});
                      // update the card user's matches
                      await Supabase.instance.client
                          .from('users')
                          .update({'matches': card_user_matches}).match(
                              {'email': widget.cardUserData['email']});
                      setState(() {
                        cardColor = Colors.white;
                      });
                    },
                    child: const Icon(
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
  const CircularWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 75,
      height: 75,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color.fromARGB(255, 123, 121, 121),
      ),
    );
  }
}

class RightSmallCircle extends StatelessWidget {
  const RightSmallCircle({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color.fromARGB(255, 123, 121, 121),
      ),
    );
  }
}

class LeftSmallCircle extends StatelessWidget {
  const LeftSmallCircle({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color.fromARGB(255, 123, 121, 121),
      ),
    );
  }
}
