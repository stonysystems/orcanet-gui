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
  bool _isDrawerOpen = true; // Track whether the Drawer is open

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

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('OrcaNet'),
      // ),
      body: Row(
        children: [
          // The Drawer Menu itself as a side panel with toggleable visibility
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
                    ListTile(
                      title: const Text('Home'),
                      onTap: () => _onItemTapped(0),
                    ),
                    ListTile(
                      title: const Text('Status'),
                      onTap: () => _onItemTapped(1),
                    ),
                    ListTile(
                      title: const Text('Peer'),
                      onTap: () => _onItemTapped(2),
                    ),
                    ListTile(
                      title: const Text('Market'),
                      onTap: () => _onItemTapped(3),
                    ),
                    ListTile(
                      title: const Text('Wallet'),
                      onTap: () => _onItemTapped(4),
                    ),
                    ListTile(
                      title: const Text('Mining'),
                      onTap: () => _onItemTapped(5),
                    ),
                    ListTile(
                      title: const Text('Settings'),
                      onTap: () => _onItemTapped(6),
                    ),
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
                  _isDrawerOpen ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
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
}
