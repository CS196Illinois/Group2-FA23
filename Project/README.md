# Study Buddies Example App
Here, you can find an example Flutter App that is connected with Supabase as its backend.

<!-- ## Overview -->

<!-- Study Buddies is a Flutter application designed to help users manage and participate in study groups. The app allows users to view their profile, manage items related to their study groups, and view a list of available groups. -->

## Structure

The app is structured into several key screens and components (all the screens have detailed comments inside):

1. **Login Screen (`login_screen.dart`)**: This is the first screen that users interact with. It provides email authentication for users to sign in or sign up.

2. **Home Screen (`home_screen.dart`)**: Once authenticated, users are navigated to the Home Screen, which serves as the main dashboard. It contains three main sections accessible via a bottom navigation bar:
   - Profile: Displays the user's email and provides a sign-out button.
   - Home: Displays a list of items.
   - Groups: Displays a list of items.

3. **Profile Screen (`profile_screen.dart`)**: Displays the current user's email and provides an option to sign out.

4. **Groups Screen (`groups_screen.dart`)**: Displays a list of items which was fetched from the table in the Supabase database. 

5. **Home Screen Content (`homeScreen_content.dart`)**: A separate component used in the Home Screen to display the list of items. It is separated into its own file for modularity and cleaner code organization.

Home Screen Content is separated because as the application grows, having each widget in its own file helps keep the codebase organized and makes it easier to maintain. Changes to HomeScreenContent can be made independently of HomeScreen, reducing the risk of introducing bugs. Each file has a single responsibility. homeScreen_content.dart is solely responsible for displaying the content of the home screen, while home_screen.dart manages the state and navigation of the home screen.

## How to Run the App Locally

1. **Pull the changes on the master branch to your local master branch**: First, make sure that any changes that you
made on the master branch that you want to keep are stored somewhere else on your laptop. Then do `git checkout master` and `git pull` in your terminal. 

2. **Pull the changes to your screen branch**: First, make sure that any changes that you
made on your branch that you want to keep are stored somewhere else on your laptop. Then do `git checkout name_of_screen` and `git pull` in your terminal. **If you saved all your previous work somewhere else, you can forcefully pull rewriting all the work on your current screen branch.**

3. **Create A Supabase Account (Illinois Email) thru Invite**: If you haven't already, accept the invite I sent to your Illinois Email and create your Supabase account.
You should be able to see a project called **Study-Buddies[124HFA23]**. It should look like this: ![Study Buddies Project on Supabase](https://i.imgur.com/mmCdplw.png)

3. **Get Dependencies**: Navigate to the project directory (`Group2-FA23/Project/example_app`) in your terminal and run `flutter pub get` to install all the necessary dependencies.

5. **Run the App**: 
   - Ensure you have an emulator running or a device connected to your computer or CHROME.
   - Run `flutter run` in the terminal to start the app.

6. **Sign In/Sign Up**: Use the login screen to sign in or sign up. You'll need to create a new user so just sign up with your illinois email and you'll get a verification link sent to your email and once you verify your account. You'll be able to login and view all the screens.

7. **Explore the App**: Navigate through the app using the bottom navigation bar to explore different screens and functionalities.

## Functionality

- **User Authentication**: Users can sign in or sign up using their email addresses.
- **Real-time Data**: The Home Screen and Groups Screen display lists of items, fetched from a Supabase database. The data is updated in real-time. So you can test it out! Add a row to the items table and see your flutter app update to reflect that change.
- **Navigation**: Users can navigate between different sections of the app using the bottom navigation bar.
- **Sign Out**: Users can sign out from the Profile Screen. Your login state is preserved so you won't have to keep logging in and out

