import 'package:flutter/material.dart';
import 'sidepanel/home_page.dart';
import 'sidepanel/file_page.dart';
import 'sidepanel/wallet_page.dart';
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
        colorScheme: const ColorScheme.light(
          primary: Color.fromARGB(255, 255, 255, 255), // // Card Backgorund
          onPrimary: Color.fromARGB(250, 21, 101, 192),
          secondary: Color.fromARGB(255, 209, 241, 255),
          onSecondary: Colors.black,
          surface: Color.fromARGB(255, 255, 253, 253), // Entire Backgorund
          onSurface: Colors.black,
          tertiary: Color.fromARGB(250, 21, 101, 192),
          onTertiary:
              Color.fromARGB(255, 255, 255, 255), // side panel label color
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
  int? _hoveredIndex;

  static const List<Widget> _pages = <Widget>[
    HomePage(),
    FilePage(),
    ProxyPage(),
    WalletPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void myWidget() {}

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            labelType: NavigationRailLabelType.none,
            extended: true,
            minExtendedWidth: 230,
            selectedIconTheme: const IconThemeData(
              color: Colors.white,
              size: 30,
            ),
            unselectedIconTheme: IconThemeData(
              color: colorScheme.tertiary,
              size: 30,
            ),
            indicatorColor: colorScheme.tertiary,
            backgroundColor: Color.fromARGB(248, 216, 230, 248),
            selectedLabelTextStyle: TextStyle(
              color: colorScheme.tertiary,
            ),
            unselectedLabelTextStyle: TextStyle(
              color: colorScheme.tertiary,
            ),
            groupAlignment: -1.0,
            destinations: List.generate(
              _destinations.length,
              (index) => _buildHoverableDestination(
                index,
                _destinations[index]['icon'] as IconData,
                _destinations[index]['label'] as String,
                colorScheme,
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Orcanet',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
          ),

          // Main content view wrapped in a Container for styling
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.grey,
                border: Border(
                  left: BorderSide(
                    color: Colors.grey,
                    width: 0,
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

  NavigationRailDestination _buildHoverableDestination(
    int index,
    IconData iconData,
    String label,
    ColorScheme colorScheme,
  ) {
    return NavigationRailDestination(
      icon: MouseRegion(
        onEnter: (_) {
          setState(() {
            _hoveredIndex = index;
          });
        },
        onExit: (_) {
          setState(() {
            _hoveredIndex = null;
          });
        },
        cursor: SystemMouseCursors.click,
        child: Container(
          decoration: BoxDecoration(
            color: _hoveredIndex == index
                ? colorScheme.tertiary.withOpacity(0.2)
                : null,
            borderRadius: BorderRadius.circular(30.0),
          ),
          padding: const EdgeInsets.all(8.0),
          child: Icon(iconData),
        ),
      ),
      selectedIcon: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Icon(iconData),
        ),
      ),
      label: MouseRegion(
        onEnter: (_) {
          setState(() {
            _hoveredIndex = index;
          });
        },
        onExit: (_) {
          setState(() {
            _hoveredIndex = null;
          });
        },
        cursor: SystemMouseCursors.click,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Text(label),
        ),
      ),
    );
  }
}

const List<Map<String, dynamic>> _destinations = [
  {'icon': Icons.home, 'label': 'Home'},
  {'icon': Icons.insert_drive_file, 'label': 'File'},
  {'icon': Icons.people, 'label': 'Proxy'},
  {'icon': Icons.wallet, 'label': 'Wallet'},
];
