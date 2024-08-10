import 'package:fast_list/pages/about_page.dart';
import 'package:fast_list/screens/account_screen.dart';
import 'package:fast_list/screens/dashboard_screen.dart';
import 'package:fast_list/screens/home_screen.dart';
import 'package:fast_list/screens/shared_screen.dart';
import 'package:fast_list/services/authentication_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const DashboardScreen(),
    const SharedScreen(),
    const AccountScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final AuthenticationService _authenticationService = AuthenticationService();
  String email = "";

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Verifica se a largura da tela é maior que 600 pixels
    final isWideScreen = screenWidth > 600;

    setState(() {
      email = _authenticationService.getCurrentUserEmail();
    });

    return Scaffold(
      appBar: isWideScreen
          ? AppBar(
              iconTheme:
                  const IconThemeData(color: Color.fromRGBO(26, 93, 26, 100)),
              automaticallyImplyLeading: true,
              elevation: 0,
              title: const Text(
                'FastList',
                style: TextStyle(color: Color.fromRGBO(26, 93, 26, 100)),
              ),
              backgroundColor: Colors.white,
              systemOverlayStyle:
                  const SystemUiOverlayStyle(statusBarColor: Colors.white),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(
                    Icons.info_outline,
                    color: Color.fromRGBO(26, 93, 26, 100),
                  ),
                  tooltip: 'Sobre',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutPage()),
                  ),
                ),
              ],
            )
          : AppBar(
              automaticallyImplyLeading: true,
              elevation: 0,
              title: const Text(
                'FastList',
                style: TextStyle(color: Color.fromRGBO(26, 93, 26, 100)),
              ),
              backgroundColor: Colors.white,
              systemOverlayStyle:
                  const SystemUiOverlayStyle(statusBarColor: Colors.white),
              actions: <Widget>[
                IconButton(
                  icon: const Icon(
                    Icons.info_outline,
                    color: Color.fromRGBO(26, 93, 26, 100),
                  ),
                  tooltip: 'Sobre',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutPage()),
                  ),
                ),
              ],
            ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      drawer: !isWideScreen
          ? null
          : NavigationDrawer(
              onDestinationSelected: _onItemTapped,
              selectedIndex: _selectedIndex,
              indicatorColor: Colors.green,
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 50, 16, 25),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset('assets/images/logo.png'),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        margin: const EdgeInsets.only(right: 8, top: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[300], // Cor de fundo do chip
                          borderRadius:
                              BorderRadius.circular(16), // Borda arredondada
                        ),
                        child: Text(
                          email,
                          style:
                              Theme.of(context).textTheme.titleSmall!.copyWith(
                                    color: Colors.black87, // Cor do texto
                                  ),
                        ),
                      )
                    ],
                  ),
                ),
                const NavigationDrawerDestination(
                    selectedIcon: Icon(
                      Icons.home_outlined,
                      color: Colors.white,
                    ),
                    icon: Icon(
                      Icons.home_outlined,
                      color: Colors.green,
                    ),
                    label: Text("Home")),
                const NavigationDrawerDestination(
                    selectedIcon: Icon(
                      Icons.dashboard_outlined,
                      color: Colors.white,
                    ),
                    icon: Icon(
                      Icons.dashboard_outlined,
                      color: Colors.green,
                    ),
                    label: Text("Dashboard")),
                const NavigationDrawerDestination(
                    selectedIcon: Icon(
                      Icons.share_outlined,
                      color: Colors.white,
                    ),
                    icon: Icon(
                      Icons.share_outlined,
                      color: Colors.green,
                    ),
                    label: Text("Shared")),
                const NavigationDrawerDestination(
                    selectedIcon: Icon(
                      Icons.account_circle_outlined,
                      color: Colors.white,
                    ),
                    icon: Icon(
                      Icons.account_circle_outlined,
                      color: Colors.green,
                    ),
                    label: Text("Account")),
              ],
            ),
      bottomNavigationBar: isWideScreen
          ? null
          : BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.home_outlined,
                    color: Colors.green,
                  ),
                  label: 'Home',
                  tooltip: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.dashboard_outlined,
                    color: Colors.green,
                  ),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.share_outlined,
                    color: Colors.green,
                  ),
                  label: 'Shared',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.account_circle_outlined,
                    color: Colors.green,
                  ),
                  label: 'Account',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: const Color.fromRGBO(26, 93, 26, 100),
              onTap: _onItemTapped,
            ),
    );
  }
}
