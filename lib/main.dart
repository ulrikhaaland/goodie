import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:goodie/bloc/restaurants.dart';
import 'package:goodie/pages/home.dart';
import 'package:goodie/pages/login.dart';
import 'package:provider/provider.dart';

import 'bloc/auth.dart';
import 'bloc/filter.dart';
import 'bloc/location.dart';
import 'pages/restaurants/shops/shop_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final authProvider = AuthProvider(); // Create instance
  final restaurantProvider = RestaurantProvider(); // Create instance
  final filterProvider = FilterProvider();
  final locationProvider = LocationProvider();

  // Move restaurant fetching to a method that can be called on auth changes.
  void fetchRestaurants() async {
    if (authProvider.firebaseUser != null) {
      await restaurantProvider.fetchRestaurants(); // Fetch restaurants
      restaurantProvider.fetchMoreRestaurants(500).then((value) =>
          filterProvider
              .countCategoryAppearances(restaurantProvider.restaurants));
    }
  }

  authProvider
      .addListener(fetchRestaurants); // Fetch restaurants when user logs in.
  fetchRestaurants(); // Also fetch restaurants when the app starts.

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
            value: authProvider), // Provide the instance
        ChangeNotifierProvider.value(
            value: restaurantProvider), // Provide the instance
        ChangeNotifierProvider.value(
          value: filterProvider,
        ),
        ChangeNotifierProvider.value(
          value: locationProvider,
        )
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Hjem'),
          BottomNavigationBarItem(
              icon: Icon(Icons.list), label: 'Restauranter'),
          BottomNavigationBarItem(icon: Icon(Icons.post_add), label: 'Post'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmarks), label: 'Lagret'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle), label: 'Profil'),
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
