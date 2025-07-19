import 'dart:developer';
import 'package:flutter/material.dart';
import '../constants/ResponsiveUtils.dart';
import '../constants/base_url.dart';
import '../services/auth_service.dart';
import '../utils/colors.dart';
import '../widgets/AnimatedButton.dart';
import '../widgets/custom_text_field.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../widgets/showTopSnackBar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  // final _emailController = TextEditingController();
  final _nameController = TextEditingController();

  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeInAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward();
  }


  @override
  void dispose() {
    // _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
if(_nameController.text.trim().isEmpty)
  {
    _setErrorMessage('Please enter your user name.');
return;
  }

if(_passwordController.text.trim().isEmpty)
  {
    _setErrorMessage('Please enter your password.');
    return;
  }
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      if (!mounted) return;
      setState(() => _isLoading = true);

      try {
        final response = await http
            .post(
              // Uri.parse('$localurl/login'),
              Uri.parse('$localurl/login'),

              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
              body: json.encode({
                "name": _nameController.text.trim(),
                "password": _passwordController.text.trim()
              }),
            )
            .timeout(const Duration(seconds: 10));

        final responseData = json.decode(utf8.decode(response.bodyBytes));

        if (mounted) {
          if (response.statusCode == 200 && responseData['status'] == true) {


            final token = responseData['token'] ?? responseData['access_token'];

            if (token != null) {
              await AuthService.saveToken(token);
            }
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else {
            print('error messgae ');
            _setErrorMessage(responseData['message'] ?? 'Login failed');


          }
        }
      } catch (e) {
        print('error $e');
        if (mounted) {
         // showTopRightToast(context,'Error: ${e.toString()}',backgroundColor: Colors.red);
          _setErrorMessage('Error: ${e.toString()}');


        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _setErrorMessage(String message) {
    setState(() {
      _errorMessage = message;
    });
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _errorMessage = null;
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: ResponsiveUtils.scaleWidth(context, 600),
                    minHeight: constraints.maxHeight,
                    // minHeight: 500
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 24,
                        right: 24,
                        top: MediaQuery.of(context).viewInsets.bottom > 0
                            ? 24
                            : 0,
                        bottom: 24,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [


                          FadeTransition(
                            opacity: _fadeInAnimation,
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: _buildLoginCard(),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
         // 'assets/logo.png',
          'assets/company_logo.png',
          height:  ResponsiveUtils.scaleHeight(context, 80),
        ),
        const SizedBox(height: 10),
      /*  Text(
          'Login',
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, 28),
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            letterSpacing: 0.5,
          ),
        ),*/
        Text(
          'Enter your credentials to login',
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, 28),
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 36,vertical: 36),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),

                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  FadeTransition(
                    opacity: _fadeInAnimation,
                    child: _buildLogo(),
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const SizedBox(height: 24),
                        _buildLoginForm(),
                      ],
                    ),
                  ),
              SizedBox(height: 12,)
                ],
              ),
            ),
            if (_errorMessage != null)
              Positioned(
                bottom: 22,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: AppColors.red,
                      fontSize: ResponsiveUtils.fontSize(context, 14),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),

        Text(
          '© 2025 Pooja Healthcare. All rights reserved.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, 12),
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Username',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 16),
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 0.5,
              ),
            ),  Text(
              '   *',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 16),
                fontWeight: FontWeight.bold,
                color: AppColors.red,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        CustomTextField(
          controller: _nameController,
          hintText: 'Enter username',

          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          validator: (value) {
          /*  if (value == null || value.isEmpty) {
              return 'Please enter your user name';
            }
            return null;*/
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              'Password',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 16),
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 16),
                fontWeight: FontWeight.bold,
                color: AppColors.red,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        CustomTextField(
          controller: _passwordController,
          hintText: 'Enter password',

          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: AppColors.textSecondary,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
          validator: (value) {
          /*  if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }

            return null;*/
          },
          onFieldSubmitted: (_) => _login(),
        ),

        const SizedBox(height: 16),


        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Checkbox(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                side: BorderSide(style: BorderStyle.solid),
                  value: false, // You can bind this to a state variable
                  onChanged: (value) {
                    // setState(() => _keepMeLoggedIn = value ?? false);
                  },
                ),
                Text(
                  'Keep me logged in',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 14),
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            GestureDetector(

              onTap: () {
                //Navigator.pushReplacementNamed(context, '/addPatient');
              },
              child: Text(
                'Forgot password?',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 14),
                  color: AppColors.primary,
                  //decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: Animatedbutton(
            title: 'LOGIN',
            isLoading: _isLoading,
            onPressed: _login,
            backgroundColor: AppColors.secondary,
            shadowColor: AppColors.primary,

          ),
        ),



      ],
    );
  }

}
