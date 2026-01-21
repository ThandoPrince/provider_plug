import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreenOne extends StatefulWidget {
  const OnboardingScreenOne({super.key});

  @override
  State<OnboardingScreenOne> createState() => _OnboardingScreenOneState();
}

class _OnboardingScreenOneState extends State<OnboardingScreenOne> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isFirstTime = prefs.getBool('isFirstTime');

    if (isFirstTime == null || isFirstTime == true) {
      setState(() {
        _loading = false;
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go('/login'); // Navigate to login if not first time
        }
      });
    }
  }

  Future<void> _completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
       
      );
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 25),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlueAccent, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 100),

            // Provider icon or logo
            SizedBox(
              height: 100,
              child: Image.asset(
                'assets/icons/plug_splash.png', // Ensure this asset is included
              ),
            ),

            const SizedBox(height: 40),

            const Text(
              'Welcome to Plug Provider 👷‍♂️',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            const Text(
              'Your journey to earning with your skills starts here.\n\nReceive service requests from real clients in your area.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            const Text(
              'Plug gives you control, flexibility,\nand real opportunities to get better at your skills.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

                      const Text(
              'At your pace.',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),  

            const Spacer(),

         

            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
