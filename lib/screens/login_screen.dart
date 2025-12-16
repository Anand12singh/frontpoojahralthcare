import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/ResponsiveUtils.dart';
import '../constants/base_url.dart';
import '../provider/PermissionService.dart';
import '../services/auth_service.dart';
import '../utils/colors.dart';
import '../widgets/AnimatedButton.dart';
import '../widgets/custom_text_field.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
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
    _nameController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchGlobalPermissions(String token) async {
    if (token.isEmpty) {
      if (mounted) {
        Navigator.of(context).pop();
        showTopRightToast(
            context, 'Authentication token not found. Please login again.');
      }
      return;
    }

    try {
      final url = Uri.parse('$localurl/global_permission');
      final response = await http.post(url, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      }, body: {}).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = json.decode(utf8.decode(response.bodyBytes));
        if (responseData['status'] == true) {
          // Store permissions first
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
              'global_permissions', json.encode(responseData['data']));

          // Then initialize PermissionService
          //  await PermissionService().initialize();

          // Verify initialization
          if (!PermissionService().isInitialized ||
              PermissionService().initializationFailed) {
            if (mounted) {
              // showTopRightToast(context, 'Permission system initialization failed');
            }
            return;
          }

          // Only navigate after everything is ready
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
        }
      } else {
        if (mounted) {
          showTopRightToast(
              context, 'Failed to fetch permissions: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (mounted) {
        showTopRightToast(
            context, 'Failed to fetch permissions: ${e.toString()}');
      }
    }
  }

  Future<void> _login() async {
    if (_nameController.text.trim().isEmpty) {
      _setErrorMessage('Please enter your user name.');
      return;
    }

    if (_passwordController.text.trim().isEmpty) {
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
              // Fetch and store permissions after successful login
              await _fetchGlobalPermissions(token);
              WidgetsFlutterBinding.ensureInitialized();
              PermissionService().initialize();
            }
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else {
            _setErrorMessage(responseData['message'] ?? 'Login failed');
          }
        }
      } catch (e) {
        _setErrorMessage('Error: ${e.toString()}');
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
            final bool isMobile = constraints.maxWidth < 600 || !kIsWeb;

        

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: ResponsiveUtils.scaleWidth(context, 600),
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: isMobile ? 16 : 24,
                        right: isMobile ? 16 : 24,
                        top: MediaQuery.of(context).viewInsets.bottom > 0
                            ? (isMobile ? 16 : 24)
                            : 0,
                        bottom: isMobile ? 16 : 24,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FadeTransition(
                            opacity: _fadeInAnimation,
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: _buildLoginCard(isMobile: isMobile),
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

  Widget _buildLogo({bool isMobile = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/company_logo.png',
          height: isMobile ? 60 : ResponsiveUtils.scaleHeight(context, 80),
        ),
        const SizedBox(height: 10),
        Text(
          'Enter your credentials to login',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isMobile ? 20 : ResponsiveUtils.fontSize(context, 28),
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard({bool isMobile = false}) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 36,
                vertical: isMobile ? 24 : 36,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: isMobile
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              child: Column(
                children: [
                  FadeTransition(
                    opacity: _fadeInAnimation,
                    child: _buildLogo(isMobile: isMobile),
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: isMobile ? 20 : 24),
                        _buildLoginForm(isMobile: isMobile),
                      ],
                    ),
                  ),
                  SizedBox(height: isMobile ? 8 : 12),
                ],
              ),
            ),
            if (_errorMessage != null)
              Positioned(
                bottom: isMobile ? 18 : 22,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: AppColors.red,
                      fontSize:
                          isMobile ? 12 : ResponsiveUtils.fontSize(context, 14),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: isMobile ? 8 : 10),
        kIsWeb
            ? Text(
                '© 2025 Pooja Healthcare. All rights reserved.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize:
                      isMobile ? 10 : ResponsiveUtils.fontSize(context, 12),
                  color: isMobile ? const Color(0xFF666666) : Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
              )
            : SizedBox(),
      ],
    );
  }

  Widget _buildLoginForm({bool isMobile = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Username',
              style: TextStyle(
                fontSize: isMobile ? 14 : ResponsiveUtils.fontSize(context, 16),
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              '   *',
              style: TextStyle(
                fontSize: isMobile ? 14 : ResponsiveUtils.fontSize(context, 16),
                fontWeight: FontWeight.bold,
                color: AppColors.red,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        SizedBox(height: isMobile ? 2 : 4),
        CustomTextField(
          controller: _nameController,
          hintText: 'Enter username',
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          // Mobile-specific padding
          contentPadding: isMobile
              ? const EdgeInsets.symmetric(horizontal: 12, vertical: 14)
              : null,
          validator: (value) {
            /*  if (value == null || value.isEmpty) {
              return 'Please enter your user name';
            }
            return null;*/
          },
        ),
        SizedBox(height: isMobile ? 12 : 16),
        Row(
          children: [
            Text(
              'Password',
              style: TextStyle(
                fontSize: isMobile ? 14 : ResponsiveUtils.fontSize(context, 16),
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(
                fontSize: isMobile ? 14 : ResponsiveUtils.fontSize(context, 16),
                fontWeight: FontWeight.bold,
                color: AppColors.red,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        SizedBox(height: isMobile ? 2 : 4),
        CustomTextField(
          controller: _passwordController,
          hintText: 'Enter password',
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          // Mobile-specific padding
          contentPadding: isMobile
              ? const EdgeInsets.symmetric(horizontal: 12, vertical: 14)
              : null,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color:
                  isMobile ? const Color(0xFF666666) : AppColors.textSecondary,
              size: isMobile ? 20 : 24,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            padding: isMobile ? const EdgeInsets.all(8) : null,
          ),
          validator: (value) {
            /*  if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            return null;*/
          },
          onFieldSubmitted: (_) => _login(),
        ),
        SizedBox(height: isMobile ? 12 : 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Visibility(
              visible: false,
              child: Row(
                children: [
                  Checkbox(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4))),
                    side: BorderSide(style: BorderStyle.solid),
                    value: false,
                    onChanged: (value) {
                      // setState(() => _keepMeLoggedIn = value ?? false);
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  Text(
                    'Keep me logged in',
                    style: TextStyle(
                      fontSize:
                          isMobile ? 12 : ResponsiveUtils.fontSize(context, 14),
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                _nameController.clear();
                _passwordController.clear();

                if (_errorMessage != null) {
                  setState(() => _errorMessage = null);
                }

                showTopRightToast(context,
                    'Please contact the admin to change your password.',
                    backgroundColor: Colors.red);
              },
              child: Text(
                'Forgot password?',
                style: TextStyle(
                  fontSize:
                      isMobile ? 12 : ResponsiveUtils.fontSize(context, 14),
                  color: isMobile ? const Color(0xFF2E3192) : AppColors.primary,
                  fontWeight: isMobile ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: isMobile ? 12 : 14),
        SizedBox(
          width: double.infinity,
          child: Animatedbutton(
            title: 'LOGIN',
            isLoading: _isLoading,
            onPressed: _login,
            backgroundColor: AppColors.secondary,
            shadowColor: AppColors.primary,
          ),
        )
      ],
    );
  }
}
