# group_page

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Current Group Page features
- The current state of the group page has three custom objects:
- GroupList:
  - Responsible for the rendering of all the study courses, The groupList is Stateless and accepts a Map of the following format: <br>
``
Map<String, List<String>> = {
    'CourseName' : [ 'CourseTime' , 'ProfesssorName', 'ClassType (Online or Lecture)', 'courseExplorerUrl' ] 
}
``
  - The Map will be formed when we query to the database when the page is rendered. This shall be done in the _groupPage -part of the code. (Yet to be implemented)
  - The groupList returns a container which uses a forEach loop to access data from the Map and create Dismissible Elements.

- DismissibleAddOn:
  - Uses the Dismissible Feautre to wrap the StaticGroupCard into a responsive feature.
  - Uses two separate backgrounds -> Orange on the left and Red on the right.
  - Swiping from the right to left takes the user to the group chat/ forum.
  - Swiping the other way take teh user to the course explorer.

- StaticGroupCard
  - Object which renders a card with a Spaced layout which contains the following charectoristics of the course:
      - CourseName
      - LectureTime
      - Professor
      - Type

## Imporvements needed:
- Solving the forEach problem (Line: 163) (I need to read docs)
- Adding pipes in between the charecteristics of the groupCard
- Removing template styles
- Swapping the chat and info icons in the infosection.
