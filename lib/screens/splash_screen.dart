import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimationLeft;
  late Animation<Offset> _slideAnimationRight;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));

    _slideAnimationLeft = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
    ));

    _slideAnimationRight = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
    ));

    _controller.forward();

    // Navigate to home screen after delay
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: AppTheme.primaryBackgroundColor,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circular Logo with Fade Animation
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Animated Text
              Column(
                children: [
                  // Jeevan Setu text sliding from left
                  SlideTransition(
                    position: _slideAnimationLeft,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Text(
                        'Jeevan Setu',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 2,
                          color: AppTheme.primaryTextColor,
                          fontFamily: 'Helvetica Neue',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Subtitle text sliding from right
                  SlideTransition(
                    position: _slideAnimationRight,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Text(
                        '"Bridge to a Better Life"',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 1,
                          color: AppTheme.secondaryTextColor,
                          fontStyle: FontStyle.italic,
                          fontFamily: 'Helvetica Neue',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 