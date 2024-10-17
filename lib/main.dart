import 'package:flutter/material.dart';
import 'sidepanel/home_page.dart';
import 'sidepanel/status_page.dart';
import 'sidepanel/peer_page.dart';
import 'sidepanel/market_page.dart';
import 'sidepanel/wallet_page.dart';
import 'sidepanel/mining_page.dart';
import 'sidepanel/settings_page.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
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
    StatusPage(),
    PeerPage(),
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
    return Scaffold(
      body: Row(
        children: [
          // Navigation Rail for the side menu
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            labelType: NavigationRailLabelType.all, // Show all labels
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
                label: Text('Peer'),
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
                    color: Colors.grey.shade300,
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
