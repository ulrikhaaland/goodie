import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:goodie/bloc/bottom_nav_provider.dart';
import 'package:goodie/bloc/restaurant_provider.dart';
import 'package:goodie/bloc/user_review_provider.dart';
import 'package:goodie/pages/feed/feed_page.dart';
import 'package:goodie/pages/intro/intro_page.dart';
import 'package:goodie/pages/loading_page.dart';
import 'package:goodie/pages/login/login.dart';
import 'package:goodie/pages/review/review_page.dart';
import 'package:provider/provider.dart';

import 'bloc/auth_provider.dart';
import 'bloc/filter_provider.dart';
import 'bloc/location_provider.dart';
import 'data/migration.dart';
import 'model/user.dart';
import 'pages/restaurants/shops/shop_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final authProvider = AuthProvider(); // Create instance
  final restaurantProvider = RestaurantProvider(); // Create instance
  final filterProvider = FilterProvider();
  final reviewProvider = UserReviewProvider();
  final BottomNavigationProvider bottomNavigationProvider =
      BottomNavigationProvider();

  // Move restaurant fetching to a method that can be called on auth changes.
  void fetchRestaurants() async {
    await restaurantProvider.fetchRestaurants(); // Fetch restaurants
    restaurantProvider.fetchMoreRestaurants(500).then((value) {
      filterProvider.countCategoryAppearances(restaurantProvider.restaurants);
      restaurantProvider
          .sortRestaurantCategories(filterProvider.categoryCounts);
    });
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
          value: reviewProvider,
        ),
        ChangeNotifierProvider.value(
          value: bottomNavigationProvider,
        ),
      ],
      child: MainApp(authProvider: authProvider),
    ),
  );
}

const primaryColor = Color(0xFFFF6B6B); // Anchor color
const secondaryColor = Color(0xFFFFA6A6); // Lighter shade of primary
const accent1Color = Color(0xFFFF8D8D); // Slightly different shade of primary
const accent2Color = Color(0xFFFF4A4A); // Darker shade of primary
const bgColor = Color(0xFFFFF2F2); // Very light shade for background
const textColor = Color(0xFF7B3F3F); // Dark shade for text
// amber [900]
const amberColor = Color(0xDDFF6F00);
const highlightColor = Color(0xFFFFB9B9); // Pastel shade for highlights
const highlightColor2 = Color(0xFFFFE3E3); // Pastel shade for highlights
const highlightColor3 = Color(0xFFFFF2F2); // Pastel shade for highlights

// Option 1: Contrast
const bookmarkColorContrast = Color(0xFF4CAF50); // Green

// Option 2: Complementary
const bookmarkColorComplementary = Color(0xFFFCD116); // Light yellow

// Option 3: In Palette
const bookmarkColorInPalette = Color(0xFFFFB9B9); // Same as highlightColor

// Option 4: Neutral
const bookmarkColorNeutral = Color(0xFFA9A9A9); // DarkGray

// Additional Options
// Option 1: Cool Blue
const bookmarkColorCoolBlue = Color(0xFF2196F3); // Blue

// Option 2: Earthy Tone
const bookmarkColorEarthy = Color(0xFF6B8E23); // Olive

// Option 3: Muted Purple
const bookmarkColorPurple = Color(0xFF9370DB); // Medium Purple

// New Additional Options for Natural White Background
// Option 1: Dark Teal
const bookmarkColorDarkTeal = Color(0xFF008080); // Teal

// Option 2: Dark Orange
const bookmarkColorDarkOrange = Color(0xFFFF8C00); // Dark Orange

// Option 3: Royal Blue
const bookmarkColorRoyalBlue = Color(0xFF4169E1); // Royal Blue

class MainApp extends StatefulWidget {
  final AuthProvider authProvider;

  const MainApp({super.key, required this.authProvider});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  LocationProvider? _locationProvider;
  bool loggedIn = false;

  User? get user => widget.authProvider.user.value;

  @override
  void initState() {
    if (widget.authProvider.firebaseUser != null) {
      loggedIn = true;

      _locationProvider = LocationProvider();
      _locationProvider!.initializeLocation();
    }

    widget.authProvider.user.addListener(_handleOnLogin);

    super.initState();
  }

  @override
  void dispose() {
    widget.authProvider.user.removeListener(_handleOnLogin);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        key: const Key("mainApp"), theme: customTheme, home: _getPage());
  }

  _handleOnLogin() async {
    if (user != null) {
      setState(() {
        loggedIn = true;
      });
      UserReviewProvider reviewProvider =
          // ignore: use_build_context_synchronously
          Provider.of<UserReviewProvider>(context, listen: false);

      reviewProvider.fetchReviews();

      _locationProvider = LocationProvider();
      await _locationProvider!.initializeLocation();
    } else {
      setState(() {
        loggedIn = false;
      });
    }
  }

  _getPage() {
    if (loggedIn) {
      if (user == null) {
        return const LoadingPage();
      }
      if (user!.isNewUser) {
        return IntroPage(onDone: () => setState(() {}));
      } else {
        return ChangeNotifierProvider.value(
            value: _locationProvider!,
            child: HomeWithBottomNavigation(
              key: UniqueKey(),
            ));
      }
    } else {
      return LoginPage(
        key: UniqueKey(),
      );
    }
  }
}

class HomeWithBottomNavigation extends StatelessWidget {
  HomeWithBottomNavigation({super.key});

  final List<Widget> _pages = [
    const HomePage(),
    const ListPage(),
    const RestaurantReviewPage(),
    const BookmarksScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final BottomNavigationProvider bottomNavigationProvider =
        Provider.of<BottomNavigationProvider>(context);

    bottomNavigationProvider.index = 0;

    return Scaffold(
        body: ValueListenableBuilder(
          valueListenable: bottomNavigationProvider.currentIndexListener,
          builder: (context, value, child) => IndexedStack(
            index: value,
            children: _pages,
          ),
        ),
        bottomNavigationBar: ValueListenableBuilder(
          valueListenable: bottomNavigationProvider.currentIndexListener,
          builder: (context, value, child) => BottomNavigationBar(
            type: BottomNavigationBarType.shifting,
            backgroundColor: Colors.white,
            selectedItemColor: primaryColor,
            unselectedItemColor: Colors.grey[600],
            currentIndex: bottomNavigationProvider.currentIndexListener.value,
            onTap: (index) => bottomNavigationProvider.index = index,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Hjem'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.list), label: 'Restauranter'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.post_add), label: 'Anmeld'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.bookmarks), label: 'Lagret'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle), label: 'Profil'),
            ],
          ),
        ));
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
    AuthProvider authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Center(
        child: TextButton(
            onPressed: () => authProvider.signOut(),
            child: const Text('Sign out')),
      ),
    );
  }
}
