import 'package:flutter/material.dart';

// HomeScreenContent is a StatelessWidget because it does not manage any mutable state.
// It receives data through its constructor and rebuilds whenever the data changes.
// YOU MAY NEED TO MAKE THIS A STATEFUL WIDGET because you may need to manage mutable states, so just keep that in mind.
class HomeScreenContent extends StatelessWidget {
  // Stream of list of maps, each representing an item from the Supabase database.
  final Stream<List<Map<String, dynamic>>> stream;
  // Constructor requires a stream to be passed in so in home_screen, we ensure that we pass in the stream created there.
  const HomeScreenContent({Key? key, required this.stream}) : super(key: key);

  // See Line 50-End of File in groups_screen.dart for the comments regarding this build function

  // The only difference is that we use a Stream Builder instead of a Future Builder because it is designed to listen to a stream of data from the Supabase database,
  // which allows it to receive and display real-time updates. When the data in the database changes, the stream automatically emits the updated data,
  // and the StreamBuilder rebuilds its widget tree to reflect the changes. Future Builder only fetches the data once.

  // We don't have to do that in the Groups_Screen because the widget rebuilds itself automatically whenever the user clicks on the Groups Icon in the Navbar.
  // As such, the Future Builder always fetches the most up to date data.
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: stream,
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
    );
  }
}
