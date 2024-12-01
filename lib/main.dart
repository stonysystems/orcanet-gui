import 'package:flutter/material.dart';
import 'sidepanel/home_page.dart';
import 'sidepanel/file_page.dart';
import 'sidepanel/market_page.dart';
import 'sidepanel/wallet_page.dart';
import 'sidepanel/mining_page.dart';
import 'sidepanel/settings_page.dart';
import 'sidepanel/proxy_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OrcaNet',
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        colorScheme: ColorScheme.light(
          primary: const Color.fromARGB(255, 241, 240, 243),
          onPrimary: const Color.fromARGB(250, 21, 101, 192),
          secondary: const Color.fromARGB(255, 209, 241, 255),
          onSecondary: Colors.black,
          surface: Colors.white,
          onSurface: Colors.black,
          error: Colors.red,
          onError: Colors.white,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomePage(),
    FilePage(),
    ProxyPage(),
    MarketPage(),
    WalletPage(),
    MiningPage(),
    SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Row(
        children: [
          // Navigation Rail for the side menu
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            labelType: NavigationRailLabelType.all,
            selectedIconTheme: IconThemeData(
              color: colorScheme.primary, // Consistent icon color for selected
            ),
            unselectedIconTheme: IconThemeData(
              color:
                  colorScheme.onPrimary, // Consistent icon color for unselected
            ),
            indicatorColor:
                Colors.transparent, // Disable background indicator color
            backgroundColor: Colors.transparent, // Ensure consistent background
            selectedLabelTextStyle: const TextStyle(
              color: Colors.black, // Custom text color for selected labels
            ),
            unselectedLabelTextStyle: const TextStyle(
              color: Colors.black, // Custom text color for unselected labels
            ),
            // Show all labels
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.home),
                selectedIcon: Icon(Icons.home_filled),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.insert_drive_file),
                selectedIcon: Icon(Icons.insert_drive_file_sharp),
                label: Text('File'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                selectedIcon: Icon(Icons.people_outline),
                label: Text('Proxy'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.show_chart),
                selectedIcon: Icon(Icons.show_chart_outlined),
                label: Text('Market'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.wallet),
                selectedIcon: Icon(Icons.wallet_travel),
                label: Text('Wallet'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.work),
                selectedIcon: Icon(Icons.work_outline),
                label: Text('Mining'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings),
                selectedIcon: Icon(Icons.settings_outlined),
                label: Text('Settings'),
              ),
            ],
          ),
          // Main content view wrapped in a Container for styling
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  left: BorderSide(
                    color: Colors.white,
                    width: 1,
                  ),
                ),
              ),
              child: Center(
                child: _pages.elementAt(_selectedIndex),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
