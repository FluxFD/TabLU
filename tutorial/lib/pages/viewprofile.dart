import 'package:flutter/material.dart';

class ViewProfile extends StatefulWidget {
   final String username;
  final String email;
   ViewProfile({required this.username, required this.email});

  @override
  State<ViewProfile> createState() => _MyAppState();
}

class _MyAppState extends State<ViewProfile> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    //  title: 'User Profile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProfilePage(),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       backgroundColor: Colors.white,
        iconTheme: const IconThemeData(),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color.fromARGB(255, 5, 78, 7),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        
      ),
      body: Container(
        height: 1000,
      alignment: Alignment.topCenter,
          child: Column(
            //crossAxisAlignment: CrossAxisAlignment.start,
           // mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircleAvatar(
                radius: 80,
                backgroundImage: AssetImage('assets/profile_picture.jpg'),
              ),
              SizedBox(height: 20),
              Text(
                'Username: ',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                'Email: ',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 30,),
              Card(
                elevation: 0.5,
            
                child: Column(
                  children: [
                    Container(
                      height: 300,
                      width: 350,
                      alignment: Alignment.topLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20, left: 20),
                            
                            child: Row(
                              children: [
                                Icon(
                                Icons.home
                                ),
                                SizedBox(width: 10,),
                                Text(
                                'Lives in '//+ $address
                                , style: TextStyle(
                                  fontSize: 18),),
                              ],
                            )
                              ),
                              
                        ),
                        Column(
                  children: [
                    TextButton(onPressed: (){

                    } , child: Text(
                      'Edit Profile'
                    )), 
                    
                  ],
                  )
                  ],
                ),

                  ),
                  
               ] ),
              )
     ) ;
          
      
      
        
    
    
  }
}
