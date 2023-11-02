// import 'dart:html';

import 'dart:html';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple,),
        useMaterial3: true,
        fontFamily: 'roboto'
      ),
      home: const GroupPage(title: 'Current Course Study Groups'),
    );
  }
}

class GroupPage extends StatefulWidget {
  const GroupPage({super.key, required this.title});
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.
  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final String title;

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  int _counter = 0;
  Map<String, List<String>> queriedCourses = {
    'CS124' : [''],
    'MATH231' : [''],
    'LEEDS116' : [''],
    'ENG100' : [''],
    'ECON102' : [''],
    'HIST103' : ['']
  };

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  Widget infoSection = Container(
    padding: const EdgeInsets.all(16),
    child: Row(
      mainAxisAlignment:  MainAxisAlignment.spaceAround,
      children: [
        Icon(Icons.info),
        Icon(Icons.swipe),
        Icon(Icons.chat)
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the GroupPage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          children: <Widget>[
            infoSection,
            const SizedBox(height: 15,),
            GroupList(queriedCourses)
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


class GroupList extends StatelessWidget {
  late Map<String, List<String>> userCourses;
  GroupList(Map<String, List<String>> initCourses) {
    userCourses = initCourses;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Container(
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.all(10),
      /*child: 
      userCourses.forEach((key, value) {
        StaticGroupCard card = 
      }) */

    );
  }
}

class DismissibleAddOn extends StatelessWidget {
  late StaticGroupCard statGC;
  late String courseName;
  late String courseUrl;
  DismissibleAddOn(StaticGroupCard initCard, String initCourse, String initUrl) {
    statGC = initCard;
    courseName = initCourse;
    courseUrl = initUrl;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Dismissible(
      key: UniqueKey(), 
      direction: DismissDirection.horizontal,
      onDismissed: (direction) => {
        if(direction == DismissDirection.endToStart) {

        } else {

        }
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
      child: statGC
    );
  }
}


class StaticGroupCard extends StatelessWidget {
  late String courseName;
  late String lectureTime;
  late String profName;
  late String classType;
  StaticGroupCard(String initCourse, String initTime, String initName, String initType) {
    courseName = initCourse;
    lectureTime = initTime;
    profName = initName;
    classType = initType;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      elevation: 12,
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
            children: [
              Text(courseName, 
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('Professor:\n$profName'),
                  Text('Class Type:\n$classType'),
                  Text('Timings:\n$lectureTime')
                ],
              ),
            ],
          ),
      ),
    );
  }
}