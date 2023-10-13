import 'package:flutter/material.dart';
import 'package:side_navigation/side_navigation.dart';
import 'package:sysadmindb/main.dart';

void main() {
  runApp(
    MaterialApp(home: Gscscreen()),
  );
}

class Gscscreen extends StatefulWidget {
  const Gscscreen({Key? key}) : super(key: key);

  @override
  _MainViewState createState() => _MainViewState();
}


class _MainViewState extends State<Gscscreen> {
  void changeScreen(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override

  /// Views to display
  List<Widget> views = [
    Center(
      child: Text(
        'Dashboard',
        textDirection: TextDirection.ltr,
        style: TextStyle(fontFamily: 'Inter'),
      ),
    ),
    Center(
      child: Text(
        'Program Management',
        textDirection: TextDirection.ltr,
        style: TextStyle(
          fontFamily: 'Inter',
        ),
      ),
    ),

    Center(
      child: Text(
        'Calendar',
        textDirection: TextDirection.ltr,
        style: TextStyle(fontFamily: 'Inter', fontSize: 100),
      ),
    ),
    Center(
      child: Text(
        'Inbox',
        textDirection: TextDirection.ltr,
        style: TextStyle(fontFamily: 'Inter', fontSize: 100),
      ),
    ),
  ];

  /// The currently selected index of the bar
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        // The row is needed to display the current view

        body: Row(
          children: [
            /// Pretty similar to the BottomNavigationBar!
            SideNavigationBar(
              header: SideNavigationBarHeader(
                  image: CircleAvatar(),
                  title: Text(
                    "${currentUser!.displayname['firstname']!} ${currentUser!.displayname['lastname']!}",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  subtitle: Text(
                    emailTextController.text,
                    style: TextStyle(
                      color: Color(0xFF747475),
                      fontSize: 12,
                    ),
                  )),
              footer: SideNavigationBarFooter(
                  label: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(
                      Icons.logout,
                      color: Color(0xFF747475),
                    ),
                    label: Text(
                      'Log Out',
                      style: TextStyle(color: Color(0xFF747475)),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                  ),
                ],
              )),
              selectedIndex: selectedIndex,
              items: const [
                SideNavigationBarItem(
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                ),
                SideNavigationBarItem(
                  icon: Icons.book,
                  label: 'Program Management',
                ),
                SideNavigationBarItem(
                  icon: Icons.school,
                  label: 'Student Management',
                ),
                SideNavigationBarItem(
                  icon: Icons.event,
                  label: 'Calendar',
                ),
                SideNavigationBarItem(
                  icon: Icons.inbox,
                  label: 'Inbox',
                ),
              ],
              onTap: (index) {
                setState(() {
                  changeScreen(index);
                });
              },
              toggler: SideBarToggler(
                  expandIcon: Icons.keyboard_arrow_right,
                  shrinkIcon: Icons.keyboard_arrow_left,
                  onToggle: () {
                    print('Toggle');
                  }),
              theme: SideNavigationBarTheme(
                itemTheme: SideNavigationBarItemTheme(
                  labelTextStyle: TextStyle(fontFamily: 'Inter', fontSize: 14),
                  unselectedItemColor: Color(0xFF747475),
                  selectedItemColor: const Color.fromARGB(255, 255, 255, 255),
                  iconSize: 20,
                ),
                backgroundColor: Color(0xF0151718),
                togglerTheme: SideNavigationBarTogglerTheme(
                    expandIconColor: Colors.white,
                    shrinkIconColor: Colors.white),
                dividerTheme: SideNavigationBarDividerTheme.standard(),
              ),
            ),

            Expanded(
              child: views.elementAt(selectedIndex),
            )
          ],
        ),
      ),
    );
  }
}
