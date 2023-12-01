import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';


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

Stream<List<Map<String, dynamic>>> fetchCourseData(String courseName) {
  late final Stream<List<Map<String, dynamic>>> _stream;
  
  _stream = Supabase.instance.client
  .from('courses').stream(primaryKey: ['course_ID']).eq('courseconcat', courseName).limit(1).map((maps) => List<Map<String, dynamic>>.from(maps));
    _stream.map((maps) => print(List<Map<String, dynamic>>.from(maps)));

  return _stream;
}

class _GroupsScreenState extends State<GroupsScreen> {
  
  late final Stream<List<Map<String, dynamic>>> _stream;

  @override
  void initState() {
    super.initState();
    // Fetch all the data of the user using streams 
    User? user = Supabase.instance.client.auth.currentUser;
    _stream = Supabase.instance.client.from('users').stream(primaryKey: [
      'email'
    ]).eq('email', user?.email).limit(1).map((maps) => List<Map<String, dynamic>>.from(maps));
    _stream.map((maps) => print(List<Map<String, dynamic>>.from(maps)));
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
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _stream, // The stream to observe
        // The builder callback that returns a widget based on the latest snapshot
        builder: (context, snapshot) {
          // If the future is still running, show a loading indicator
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // If the stream completes with no data, show a message indicating no items were found
          if (snapshot.data!.isEmpty) {
            return const Center(child: Text('No items found'));
          }
          // If the stream completes with data, get the courses the user is enrolled in and then display them
          final items = snapshot.data!;
          final courses = items[0]['courses'];
          return ListView.builder(
            // how many courses the user is enrolled in
            itemCount: courses.length,
            // Builder callback to create a CourseCard which has the dismissible widegt wrapped around course info.
            itemBuilder: (context, index) {
              final course = courses[index];
              // Fetch data to fetch the stream of data for that course.
              return CourseCard(courseStream: fetchCourseData(course));
           },
          );
        },
      ),
    );
  }
}



// The coursecard is a stateful widegt because I want the card to reload after each dismissible action to prevent it from disapearing .. this allows the user to interact with the group screen without having to manually reload the screen.
class CourseCard extends StatefulWidget {
  const CourseCard({Key? key, required this.courseStream}) : super(key: key);
  final Stream<List<Map<String, dynamic>>> courseStream;
  @override
  // Although I should not be passing logic through this I am doing this as a workaround for passing coursestream.. if anyone finds a better solutions please update this!!
  _CourseCardState createState() => _CourseCardState();
}



class _CourseCardState extends State<CourseCard> {
  _CourseCardState();

  User? user = Supabase.instance.client.auth.currentUser;
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: widget.courseStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.data!.isEmpty) {
          return const Center(child: Text('No items found'));
        }
        // need to add null check here 
        if(snapshot.data!.isEmpty) {
          return GroupCard(courseData: {"course_name": "Course Not Found"});
        }
        // COURSE DATA if snapshot is not empty!!
        final items = snapshot.data!;
        final course = items[0];
        // get the course explorer link -- can be done more efficiently.
        final Uri url = Uri.parse(course['course_explorer_link']);
        // return the dismissible widget.
        return  Dismissible(
          key: UniqueKey(), 
          direction: DismissDirection.horizontal,
          onDismissed: (direction) => {
            if(direction == DismissDirection.endToStart) {
              //launch The course explorer url
              launchUrl(url),
            } else {
              if (!(course['users'].contains(user?.email))) {
                print("Hitting this!"),
                //render the dialog box JoinPopUp
                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return JoinPopUp(
                      courseName: course['course_name'],
                      users: course['users'],
                      user: user?.email as String,
                    );
                  },
                )

              } else {
                // render the dialog box JoinedPopUp
                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return JoinedPopUp(
                      courseName: course['course_name'],
                      users: course['users'],
                      user: user?.email as String,
                    );
                  },
                )
              }
            },
            // Refresh the course card but not the data.
            setState(() {_CourseCardState;})
          },
          background: const ColoredBox(
            color: Colors.red,
            child: Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.chat, color: Colors.white,),
              ),
            ),
          ),
          secondaryBackground: const ColoredBox(
            color: Colors.orange,
            child : Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Icon(Icons.info, color: Colors.white),
                ),
            ),
          ),
          child: Center(
            child: GroupCard(courseData: course)
            )
        );    
      }
    );
  }
}


// the group card renders the actual card itself without the dismissible feature. This is where you can manipulate what is shown on the screen to the user. Working on the styling currently.
class GroupCard extends StatelessWidget {
   const GroupCard({super.key, required this.courseData});

  final Map<String, dynamic> courseData;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    var course_num = courseData['courseconcat'];
    var course_section = courseData['course_section'];
    return Card(
      elevation: 3,
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
            children: [
              Text(courseData['course_name']!, 
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('Course Number:\n$course_num'),
                  Text('Class Type:\n$course_section'),
                ],
              ),
            ],
          ),
      ),
    );
  }
}


// The joinedPopUp 
class JoinedPopUp extends StatelessWidget {
  final String courseName;
  final String user;
  final List<dynamic> users;
  JoinedPopUp({
    required this.courseName,
    required this.users,
    required this.user
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('You have already Joined $courseName.'),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: (){
                users.remove(user);
                Supabase.instance.client
                      .from('courses')
                      .update({ 'users': users})
                      .match({ 'course_name': courseName});  
                Navigator.pop(context);
              },
              child: const Text('Leave'),
            ),
          ],
        ),
      ),
    );
  }
}

class JoinPopUp extends StatelessWidget {
  final String courseName;
  final String user;
  final List<dynamic> users;
  JoinPopUp({
    required this.courseName,
    required this.users,
    required this.user
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Do you want to join $courseName?'),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
            TextButton(
              onPressed: () {
                users.add(user);
                Supabase.instance.client
                      .from('courses')
                      .update({ 'users': users})
                      .match({ 'course_name': courseName}); 
                Navigator.pop(context); 
              },
              child: const Text('Join'),
            ),
          ],
        ),
      ),
    );
  }
}
