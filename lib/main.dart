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
  bool _isDrawerOpen = true;
  int? _hoveredIndex; // Track the index of the currently hovered item

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
      _hoveredIndex = null; // Clear the hover effect after click
    });
  }

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // The Drawer Menu as a side panel with toggleable visibility
          if (_isDrawerOpen)
            SizedBox(
              width: 250, // Adjust width as necessary
              child: Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: <Widget>[
                    const DrawerHeader(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                      ),
                      child: Text(
                        'OrcaNet Menu',
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                    ),
                    _buildDrawerItem(index: 0, title: 'Home', icon: Icons.home),
                    _buildDrawerItem(
                        index: 1, title: 'Status', icon: Icons.info),
                    _buildDrawerItem(
                        index: 2, title: 'Peer', icon: Icons.people),
                    _buildDrawerItem(
                        index: 3, title: 'Market', icon: Icons.show_chart),
                    _buildDrawerItem(
                        index: 4, title: 'Wallet', icon: Icons.wallet),
                    _buildDrawerItem(
                        index: 5, title: 'Mining', icon: Icons.work),
                  ],
                ),
              ),
            ),
          // Column for the arrow button placed at the top
          Column(
            children: [
              GestureDetector(
                onTap: _toggleDrawer,
                child: Icon(
                  _isDrawerOpen
                      ? Icons.arrow_back_ios
                      : Icons.arrow_forward_ios,
                  size: 24,
                ),
              ),
            ],
          ),
          // Main content view
          Expanded(
            child: Center(
              child: _pages.elementAt(_selectedIndex),
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to build each drawer item with hover and click functionality
  Widget _buildDrawerItem(
      {required int index, required String title, required IconData icon}) {
    return MouseRegion(
      onEnter: (_) => setState(() {
        _hoveredIndex = index;
      }),
      onExit: (_) => setState(() {
        _hoveredIndex = null;
      }),
      child: ListTile(
        leading: Icon(icon,
            color: _selectedIndex == index || _hoveredIndex == index
                ? Colors.blue
                : Colors.black),
        title: Text(
          title,
          style: TextStyle(
            color: _selectedIndex == index || _hoveredIndex == index
                ? Colors.blue
                : Colors.black,
          ),
        ),
        tileColor: _selectedIndex == index
            ? Colors.blue.withOpacity(0.1)
            : (_hoveredIndex == index
                ? Colors.blue.withOpacity(0.05)
                : Colors.transparent),
        onTap: () => _onItemTapped(index),
      ),
    );
  }
}
