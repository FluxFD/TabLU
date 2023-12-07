import 'package:flutter/material.dart';
import 'package:tutorial/pages/login.dart';
import 'package:tutorial/pages/signin.dart';

class getStarted extends StatelessWidget {
  const getStarted({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Image.asset('assets/icons/jury.png'),
                    ),
                    const Spacer(),
                    Container(
                      height: 294,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 238, 248, 220),
                          borderRadius: BorderRadius.all(
                            Radius.circular(50),
                          )),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Column(children: [
                          const SizedBox(height: 13,),
                          const Text(
                            'Start together with TabLU',
                            style: TextStyle(
                              color: Color.fromARGB(255, 5, 70, 20),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          const Text(
                              'A Laguna University \n smart solution for tabulating events data',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color.fromARGB(255, 5, 70, 20),
                              )),
                          const SizedBox(
                            height: 30,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Login()));
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors
                                  .transparent, 
                              onPrimary: Colors
                                  .transparent, 
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    16.0), 
                              ),
                              elevation: 0, 
                              shadowColor: Colors
                                  .transparent, 
                              padding: EdgeInsets.zero, 
                            ),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF8DEC75),
                                    Color(0xFF4CAF50),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(
                                    16.0), 
                              ),
                              child: Container(
                                constraints: const BoxConstraints(
                                    maxWidth: 250.0,
                                    minHeight: 45.0),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Get Started',
                                  style: TextStyle(
                                      color: Colors.white), 
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Signin()));
                            },
                            child: const Text("Sign Up",
                                style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600,),
                                
                          )
                      )]),
                      ),
                    ),
                    const SizedBox(height: 20,)
                  ],
                ))));
  }
}
