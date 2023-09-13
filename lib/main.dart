import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:goodie/bloc/restaurants.dart';
import 'package:goodie/pages/home.dart';
import 'package:goodie/pages/login.dart';
import 'package:goodie/pages/review/review_page.dart';
import 'package:provider/provider.dart';

import 'bloc/auth.dart';
import 'bloc/filter.dart';
import 'bloc/location.dart';
import 'data/migration.dart';
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
      restaurantProvider.fetchMoreRestaurants(500).then((value) {
        filterProvider.countCategoryAppearances(restaurantProvider.restaurants);
        restaurantProvider
            .sortRestaurantCategories(filterProvider.categoryCounts);
      });
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

const primaryColor = Color(0xFFFF6B6B); // Anchor color
const secondaryColor = Color(0xFFFFA6A6); // Lighter shade of primary
const accent1Color = Color(0xFFFF8D8D); // Slightly different shade of primary
const accent2Color = Color(0xFFFF4A4A); // Darker shade of primary
const bgColor = Color(0xFFFFF2F2); // Very light shade for background
const textColor = Color(0xFF7B3F3F); // Dark shade for text
const highlightColor = Color(0xFFFFB9B9); // Pastel shade for highlights

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Create a custom theme using the defined colors
    final customTheme = ThemeData(
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        background: bgColor,
        onBackground: textColor,
        surface: bgColor,
        onSurface: textColor,
        primaryContainer: accent1Color,
        secondaryContainer: accent2Color,
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: highlightColor,
      ),
      // Add other theme properties if needed
    );

    return MaterialApp(
      theme: customTheme,
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
    const HomePage(),
    const ListPage(),
    const RestaurantReviewPage(),
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
        selectedItemColor: primaryColor,
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
          BottomNavigationBarItem(icon: Icon(Icons.post_add), label: 'Anmeld'),
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
