import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../services/api_services.dart';
import '../utils/colors.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;
  String _currentVersion = '1.0.0'; // Default version
  bool _versionChecked = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeApp();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _logoAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _textAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  Future<void> _initializeApp() async {
    await _controller.forward();
    await _getAppVersion();
    await _checkAppVersion();
    _checkLoginStatus();
  }

  Future<void> _getAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _currentVersion = packageInfo.version;
      });
    } catch (e) {
      debugPrint('Error getting package info: $e');
    }
  }

  Future<void> _checkAppVersion() async {
    try {
      final response = await ApiService().get('/api/get_version');

      if (response != null &&
          response['data'] != null &&
          response['data'].isNotEmpty) {
        final serverVersion = response['data'][0]['app_version'] as String;
        log('serverVersion $serverVersion');
        log('_currentVersion $_currentVersion');

        if (serverVersion != _currentVersion && mounted) {
          await _showUpdateDialog(serverVersion);
        }
      }
    } catch (e) {
      debugPrint('Error checking version: $e');
    } finally {
      setState(() {
        _versionChecked = true;
      });
    }
  }

  Future<void> _showUpdateDialog(String newVersion) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Available'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current Version: $_currentVersion'),
              Text('New Version: $newVersion'),
              const SizedBox(height: 16),
              const Text(
                  'A new version of the app is available. Please update for the best experience.'),
            ],
          ),
          actions: [
            TextButton(
              child: const Text(
                'Ok',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Add logic to open app store/play store
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkLoginStatus() async {
    if (!_versionChecked) return;

    bool isLoggedIn = await AuthService.isLoggedIn();
    if (mounted) {
      Navigator.pushReplacementNamed(
        context,
        isLoggedIn ? '/patientInfo' : '/login',
      );
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
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _logoAnimation,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/app_icon.png',
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 30),
            FadeTransition(
              opacity: _textAnimation,
              child: Text(
                'Pooja Healthcare',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 10),
            FadeTransition(
              opacity: _textAnimation,
              child: Text(
                'Medical Records System',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            // const SizedBox(height: 20),
            // FadeTransition(
            //   opacity: _textAnimation,
            //   child: Text(
            //     'Version $_currentVersion',
            //     style: TextStyle(
            //       fontSize: 12,
            //       color: AppColors.textSecondary.withOpacity(0.7),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
