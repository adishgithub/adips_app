import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Dashboard".toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold
          ),),
          backgroundColor: Colors.blue
      ),
      body: Center(
        child: Text.rich(
          TextSpan(
            text: 'Hello',
            children: [
              TextSpan(
                text: 'Welcome',
                style: TextStyle(fontSize: 40.0, fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: 'Adipsians',
                style: TextStyle(fontSize: 20.0, color: Colors.blue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
