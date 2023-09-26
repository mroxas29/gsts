import 'package:flutter/material.dart';
import 'package:sysadmindb/gradstudent_screen.dart';
import 'package:sysadmindb/gsc_screen.dart';

void main() {
  runApp(const MaterialApp(
    title: 'Navigation Basics',
    home: FirstRoute(),
  ));
}

class FirstRoute extends StatelessWidget {
  const FirstRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
 
      appBar: AppBar(
        title: const Text('Graduate student tracking system'),
        backgroundColor: Color.fromRGBO(18, 128, 86, 100),
      ),
      body: Container(
       
        decoration: BoxDecoration(
         image: DecorationImage(image: AssetImage("assets/images/bg.png"), fit: BoxFit.cover)
        ),
        child:Center(
        
        child: SizedBox(
        
        width: 400,
        height: 400,
        child: Container(
       
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color.fromRGBO(31, 47, 41, 0.711),

        ),

        child:Column(
          children: [
                    SizedBox(height: 20),
          Padding(padding: EdgeInsets.symmetric(horizontal: 1),
            
            child: Text('Login',
            style: TextStyle(fontSize: 40,
            fontFamily: 'inter',color: Colors.white),textAlign: TextAlign.justify,),
          ),

          Padding(padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),

            child: TextField(
              
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'ID Number',
                hintText: 'Enter ID number here',
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          
          ),

         Padding(padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),

            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
                hintText: 'Enter password here',
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          
          ),

          Padding(padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          
          child:  
              ElevatedButton(
              child: const Text('Coordinator Screen'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Gscscreen()),
                );
              },
            ),
          
          ),
     
        Padding(padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child:          
                ElevatedButton(
                child: const Text('Graduate Student Screen'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GradStudentscreen()),
                  );
                },
              ), 
          ),

        ],) 

    
      ),

      ) ,
      )
      )
    );
  }
}
