import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tutorial/pages/getstarted.dart';


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 5),
      () => Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const getStarted()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF8DEC75),
               Color(0xFF4CAF50),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const SizedBox(height: 50,),
                Image.asset(
                  'assets/icons/pngwing.com.png',
                  height: 250,
                  width: 250,
                ),

                const Text(
                  "TabLU:",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color.fromARGB(255, 5, 70, 20),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic),
                ),
                const Text(
                  'Laguna University Tabulation App',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color.fromARGB(255, 14, 107, 36),
                      fontSize: 17,
                      fontWeight: FontWeight.w500),
                ),
            
              ],
            ),
            const CircularProgressIndicator(color: Color.fromARGB(255, 5, 70, 20),),
          ],
        ),
      ),
    );
  }
}
