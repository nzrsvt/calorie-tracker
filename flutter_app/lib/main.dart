import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'home_page.dart';
import 'search_page.dart';
import 'meals_page.dart';
import 'profile_page.dart';
import 'splash_screen.dart';

void main() {
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        ColorScheme lightColorScheme;
        ColorScheme darkColorScheme;

        if (lightDynamic != null && darkDynamic != null) {
          lightColorScheme = lightDynamic.harmonized();
          darkColorScheme = darkDynamic.harmonized();
        } else {
          lightColorScheme = ColorScheme.fromSeed(seedColor: Colors.blue);
          darkColorScheme = ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark);
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Calorie Tracker',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightColorScheme,
            textTheme: const TextTheme(
              bodyLarge: TextStyle(fontFamily: 'Roboto'),
              bodyMedium: TextStyle(fontFamily: 'Roboto'),
              bodySmall: TextStyle(fontFamily: 'Roboto'),
              displayLarge: TextStyle(fontFamily: 'Roboto'),
              displayMedium: TextStyle(fontFamily: 'Roboto'),
              displaySmall: TextStyle(fontFamily: 'Roboto'),
              headlineLarge: TextStyle(fontFamily: 'Roboto'),
              headlineMedium: TextStyle(fontFamily: 'Roboto'),
              headlineSmall: TextStyle(fontFamily: 'Roboto'),
              titleLarge: TextStyle(fontFamily: 'Roboto'),
              titleMedium: TextStyle(fontFamily: 'Roboto'),
              titleSmall: TextStyle(fontFamily: 'Roboto'),
              labelLarge: TextStyle(fontFamily: 'Roboto'),
              labelMedium: TextStyle(fontFamily: 'Roboto'),
              labelSmall: TextStyle(fontFamily: 'Roboto'),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkColorScheme,
          ),
          themeMode: ThemeMode.system,
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/login': (context) => const LoginPage(),
            '/register': (context) => const RegisterPage(),
            '/home': (context) => const MainScreen(),
            '/search': (context) => const SearchPage(),
            '/meals': (context) => const MealsPage(),
            '/profile': (context) => const ProfilePage(),
          },
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const MyHomePage(),
    const SearchPage(),
    const MealsPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: _onItemTapped,
        selectedIndex: _selectedIndex,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(Icons.restaurant),
            label: 'Meals',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
