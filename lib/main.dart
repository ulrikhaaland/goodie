import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:goodie/bloc/restaurants.dart';
import 'package:goodie/pages/home.dart';
import 'package:goodie/pages/login.dart';
import 'package:provider/provider.dart';

import 'bloc/auth.dart';
import 'pages/restaurants/list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final restaurantProvider = RestaurantProvider(); // Create instance
  await restaurantProvider.fetchRestaurants(); // Fetch restaurants

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider.value(
            value: restaurantProvider), // Provide the instance
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return MaterialApp(
      home: authProvider.firebaseUser != null
          ? const HomeWithBottomNavigation()
          : const LoginPage(),
    );
  }
}

class HomeWithBottomNavigation extends StatefulWidget {
  const HomeWithBottomNavigation({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeWithBottomNavigationState createState() =>
      _HomeWithBottomNavigationState();
}

class _HomeWithBottomNavigationState extends State<HomeWithBottomNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    const ListPage(),
    const PostScreen(),
    const BookmarksScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.pink[300],
        unselectedItemColor: Colors.grey[600],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'List'),
          BottomNavigationBarItem(icon: Icon(Icons.post_add), label: 'Post'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bookmarks), label: 'Bookmarks'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Welcome to Home Page!'),
      ),
    );
  }
}

class ListScreen extends StatelessWidget {
  const ListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Welcome to Home Page!'),
      ),
    );
  }
}

class PostScreen extends StatelessWidget {
  const PostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Welcome to Home Page!'),
      ),
    );
  }
}

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Welcome to Home Page!'),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Welcome to Home Page!'),
      ),
    );
  }
}
