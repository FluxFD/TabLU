import 'package:flutter/material.dart';

class Winner extends StatefulWidget {
  const Winner({super.key});

  @override
  State<Winner> createState() => _WinnerState();
}

class _WinnerState extends State<Winner> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.3,
        centerTitle: true,
        title: const Text(
          'Score Ranking',
          style: TextStyle(
            fontSize: 18,
            color: Color(0xFF054E07),
          ),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF054E07),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Container(
                child: Center(
                    child: Image.asset(
                  'assets/icons/trophy.png',
                  height: 300,
                  width: 300,
                )),
              ),
            ),
            const Text(
              'Congratulation to the Winners!',
              style: TextStyle(
                  color: Color(0xFF054E07),
                  fontSize: 18,
                  fontWeight: FontWeight.w500),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 75, right: 25, top: 25),
              child: Column(
                children: [
                  Container(
                    child: Center(
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/icons/1st.png',
                            height: 50,
                            width: 50,
                          ),
                          const SizedBox(
                            width: 25,
                          ),
                          const Text('Juan Dela Cruz'),
                          const SizedBox(
                            width: 25,
                          ),
                          const Text('99%')
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    child: Center(
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/icons/2nd.png',
                            height: 50,
                            width: 50,
                          ),
                          const SizedBox(
                            width: 25,
                          ),
                          const Text('Juan Dela Cruz'),
                          const SizedBox(
                            width: 25,
                          ),
                          const Text('98%')
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    child: Center(
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/icons/3rd.png',
                            height: 50,
                            width: 50,
                          ),
                          const SizedBox(
                            width: 25,
                          ),
                          const Text('Juan Dela Cruz'),
                          const SizedBox(
                            width: 25,
                          ),
                          const Text('97%')
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              height: 5,
              width: 350,
              child: const Divider(
                color: Colors.black,
                thickness: 0.5,
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            Text(
              'Better luck next time',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF054E07),
              ),
            ),
            const SizedBox(
                    height: 10,
                  ),
            Padding(
              padding: const EdgeInsets.only(left: 120, top: 16, bottom: 30 ),
              child: Container(child: Column(children: [
            
                Row(
                  children: [
                    Text('Juan Dela Cruz'),
                      SizedBox(height: 20, width: 25,),
                Text('80%'),
                  ],
                ),
                const SizedBox(
                    height: 20,
                  ),
              
            Row(
                  children: [
                    Text('Juan Dela Cruz'),
                      SizedBox(height: 20, width: 25,),
                Text('80%'),
                  ],
                ),
                const SizedBox(
                    height: 20,
                  ),

                 Row(
                  children: [
                    Text('Juan Dela Cruz'),
                      SizedBox(height: 20, width: 25,),
                Text('80%'),
                  ],
                ),
            
              ])),
            )
          ],
        ),
      ),
    );
  }
}
