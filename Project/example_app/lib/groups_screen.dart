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
  // late final Stream<List<Map<String, dynamic>>> _stream;
  return Supabase.instance.client
      .from('courses')
      .stream(primaryKey: ['course_ID'])
      .eq('courseconcat', courseName)
      .limit(1)
      .map((maps) => List<Map<String, dynamic>>.from(maps));
  // return _stream;
}

class _GroupsScreenState extends State<GroupsScreen> {
  late final Stream<List<Map<String, dynamic>>> _stream;
  final supabase = Supabase.instance.client;
  User? user = Supabase.instance.client.auth.currentUser;

  @override
  void initState() {
    super.initState();
    // Fetch all the data of the user using streams
    _stream = supabase
        .from('users')
        .stream(primaryKey: ['email'])
        .eq('email', user?.email)
        .limit(1)
        .map((maps) => List<Map<String, dynamic>>.from(maps));
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
          final userData = snapshot.data!;
          final courses = userData[0]['courses']; // gets the users's courses
          final groups = userData[0]['groups']; // gets the user's groups
          return ListView.builder(
            // how many courses the user is enrolled in
            itemCount: courses.length,
            // Builder callback to create a CourseCard which has the dismissible widegt wrapped around course info.
            itemBuilder: (context, index) {
              final course = courses[index];
              // Fetch data to fetch the stream of data for that course.
              return CourseCard(
                  courseStream: fetchCourseData(course), user_groups: groups);
            },
          );
        },
      ),
    );
  }
}

// The coursecard is a stateful widegt because I want the card to reload after each dismissible action to prevent it from disapearing
// This allows the user to interact with the group screen without having to manually reload the screen.
class CourseCard extends StatefulWidget {
  // parameters that will be passed in from the GroupScreenState
  final Stream<List<Map<String, dynamic>>> courseStream;
  final user_groups;
  const CourseCard(
      {Key? key, required this.courseStream, required this.user_groups})
      : super(key: key);

  @override
  // Although I should not be passing logic through this I am doing this as a workaround for passing coursestream.. if anyone finds a better solutions please update this!!
  _CourseCardState createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  User? user = Supabase.instance.client.auth.currentUser;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
          if (snapshot.data!.isEmpty) {
            return const GroupCard(
                courseData: {"course_name": "Course Not Found"});
          }
          // COURSE DATA if snapshot is not empty!!
          final courseData = snapshot.data!;
          final course = courseData[0];
          // get the course explorer link -- can be done more efficiently.
          // return the dismissible widget.
          return Dismissible(
              key: UniqueKey(),
              direction: DismissDirection.horizontal,
              onDismissed: (direction) => {
                    if (direction == DismissDirection.endToStart)
                      {
                        // grab URL and launch it
                        launchUrl(Uri.parse(course['course_explorer_link'])),
                      }
                    else
                      {
                        // if course group doesn't contain user, then add a Join Popup
                        if (!(course['users'].contains(user?.email)))
                          {
                            print(
                                "This is a course that the user would like to join!"),
                            // render the dialog box JoinPopUp
                            showDialog(
                              context: context,
                              builder: (BuildContext dialogContext) {
                                return JoinPopUp(
                                    courseName: course['course_name'],
                                    courseID: course['course_ID'],
                                    users: course['users'],
                                    user_groups: widget.user_groups,
                                    current_user_email: user?.email as String);
                              },
                            )
                          }
                        else
                          {
                            // render the dialog box JoinedPopUp
                            print(
                                "This course is a course that the user has already joined!"),
                            showDialog(
                              context: context,
                              builder: (BuildContext dialogContext) {
                                return JoinedPopUp(
                                    courseName: course['course_name'],
                                    courseID: course['course_ID'],
                                    users: course['users'],
                                    user_groups: widget.user_groups,
                                    current_user_email: user?.email as String);
                              },
                            )
                          }
                      },
                    // Refresh the course card but not the data.
                    setState(() {
                      _CourseCardState;
                    })
                  },
              background: const ColoredBox(
                color: Colors.red,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.chat,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              secondaryBackground: const ColoredBox(
                color: Colors.orange,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(Icons.info, color: Colors.white),
                  ),
                ),
              ),
              child: Center(child: GroupCard(courseData: course)));
        });
  }
}

// the group card renders the actual card itself without the dismissible feature.
// This is where you can manipulate what is shown on the screen to the user. Working on the styling currently.
class GroupCard extends StatelessWidget {
  final Map<String, dynamic> courseData;
  const GroupCard({super.key, required this.courseData});

  @override
  Widget build(BuildContext context) {
    var course = courseData['courseconcat'];
    var courseSection = courseData['course_section'];
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              courseData['course_name']!,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Course:\n$course'),
                Text('Course Section:\n$courseSection'),
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
  final int courseID;
  final List<dynamic> users;
  final List<dynamic> user_groups;
  final String current_user_email;
  JoinedPopUp(
      {required this.courseName,
      required this.courseID,
      required this.users,
      required this.user_groups,
      required this.current_user_email});

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
              onPressed: () async {
                print(users);
                users.remove(current_user_email);
                user_groups.remove(courseID);
                await Supabase.instance.client
                    .from('courses')
                    .update({'users': users}).match({'course_ID': courseID});
                await Supabase.instance.client
                    .from('users')
                    .update({'groups': user_groups}).match(
                        {'email': current_user_email});
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
  final int courseID;
  final List<dynamic> users;
  final List<dynamic> user_groups;
  final String current_user_email;

  JoinPopUp(
      {required this.courseName,
      required this.courseID,
      required this.users,
      required this.user_groups,
      required this.current_user_email});

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
              onPressed: () async {
                users.add(current_user_email);
                user_groups.add(courseID);
                await Supabase.instance.client
                    .from('courses')
                    .update({'users': users}).match({'course_ID': courseID});
                await Supabase.instance.client
                    .from('users')
                    .update({'groups': user_groups}).match(
                        {'email': current_user_email});
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
