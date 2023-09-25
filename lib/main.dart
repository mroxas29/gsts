import 'package:flutter/material.dart';
import 'package:side_navigation/side_navigation.dart';

void main() {
  runApp(MaterialApp(home: MainView()),
   );
}

class MainView extends StatefulWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  /// Views to display
  List<Widget> views = const [
    Center(
      child: Text(
        'Dashboard', 
        textDirection: TextDirection.ltr,
        style: TextStyle(fontFamily: 'Inter'),),
      
    ),
    Center(
      child: Text('Account',
      textDirection:TextDirection.ltr,
      style: TextStyle(fontFamily: 'Inter', ),),
    ),
    Center(
      child: Text('Settings',
      textDirection: TextDirection.ltr,
      style: TextStyle(fontFamily: 'Inter', fontSize: 100),),
    ),
  ];

  /// The currently selected index of the bar
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      // The row is needed to display the current view

      body: Row( 
        children: [
          /// Pretty similar to the BottomNavigationBar!
          SideNavigationBar(
            
            header: SideNavigationBarHeader( 
            image: CircleAvatar(),
            title: Text('Graduate Student Tracking System', style: TextStyle(color: Colors.white, fontSize: 11),),
            subtitle: Text('GSTS',style: TextStyle(color: Color(0xFF747475)),)),

            footer: SideNavigationBarFooter(
              label: Column(
              children: <Widget>[
                  Row(children:<Widget> [
                              Icon(Icons.person),
                                  SizedBox( 
                                    child: Column(
                                            
                                            mainAxisAlignment: MainAxisAlignment.center,   
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            
                                              children: [
                                                          SizedBox(
                                                            child:Text("Marion O. Paguia",
                                                            style: TextStyle(
                                                            color: Colors.white,
                                                            fontFamily: 'inter',
                                                            fontSize: 13,)) ,
                                                          ),
                                                          
                                                          SizedBox(
                                                              child: Text("marion_paguia@dlsu.edu.ph",
                                                                    style: TextStyle(
                                                                    color: Color(0xFF747475),
                                                                    fontFamily: 'inter',
                                                                    fontSize: 10,
                                                                    )),
                                                          ),
                                                ],
                                                    
                                            ),
                                    )
                              ],
                    )  
                  ],
               )
            ),
            
            selectedIndex: selectedIndex,
            items: const [
              SideNavigationBarItem(
                icon: Icons.dashboard,
                label:'Dashboard',
              ),
              SideNavigationBarItem(
                icon: Icons.person,
                label: 'Account',
              ),
              SideNavigationBarItem(
                icon: Icons.settings,
                label: 'Settings',
              ),
            ],
            onTap: (index) {
                setState(() {
                selectedIndex = index;
              });
            },

            
            theme: SideNavigationBarTheme(
              
              itemTheme: SideNavigationBarItemTheme(
                labelTextStyle: TextStyle(fontFamily: 'Inter', fontSize:14),
                unselectedItemColor: Color(0xFF747475),
                selectedItemColor: const Color.fromARGB(255, 255, 255, 255),
                iconSize: 20,
              ),
              backgroundColor: Color(0xF0151718),
              togglerTheme: SideNavigationBarTogglerTheme.standard(),
              dividerTheme: SideNavigationBarDividerTheme.standard(),
              
            ),
          ),

          Expanded(
            child: views.elementAt(selectedIndex),
          )

        ],
        
        
      ),
    );
  }
}