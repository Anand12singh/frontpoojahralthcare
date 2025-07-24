import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../constants/ResponsiveUtils.dart';
import '../../constants/base_url.dart';
import '../../services/api_services.dart';
import '../../services/auth_service.dart';
import '../../utils/colors.dart';
import '../../widgets/AnimatedButton.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/showTopSnackBar.dart';

class Forgotpassword extends StatefulWidget {
  const Forgotpassword({super.key});

  @override
  State<Forgotpassword> createState() => _ForgotpasswordState();
}

class _ForgotpasswordState extends State<Forgotpassword>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;
  String? _errorMessage;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeInAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _newPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  bool _validatePassword(String password) {
    // At least 8 characters
    if (password.length < 8) {
      _passwordError = 'Password must be at least 8 characters long';
      return false;
    }

    // At least one uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) {
      _passwordError = 'Password must contain at least one uppercase letter';
      return false;
    }

    // At least one lowercase letter
    if (!password.contains(RegExp(r'[a-z]'))) {
      _passwordError = 'Password must contain at least one lowercase letter';
      return false;
    }

    // At least one digit
    if (!password.contains(RegExp(r'[0-9]'))) {
      _passwordError = 'Password must contain at least one number';
      return false;
    }

    // At least one special character
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      _passwordError = 'Password must contain at least one special character';
      return false;
    }

    _passwordError = null;
    return true;
  }

  Future<void> _resetPassword() async {
    if (_nameController.text.trim().isEmpty) {
      _setErrorMessage('Please enter your username');
      return;
    }

    final password = _newPasswordController.text.trim();
    if (password.isEmpty) {
      _setErrorMessage('Please enter your new password');
      return;
    }

    if (!_validatePassword(password)) {
      _setErrorMessage(_passwordError!);
      return;
    }

    try {
      setState(() => _isLoading = true);

      await APIManager().apiRequest(
        context,
        API.fogotpassword,
        params: {
          "name": _nameController.text.trim(),
          "new_password": password
        },
        onSuccess: (responseBody) {
          final data = json.decode(responseBody);
          if (data['status'] == true) {
            showTopRightToast(context, 'Password reset successfully',
                backgroundColor: Colors.green);
            Navigator.pop(context);
          } else {
            _setErrorMessage(data['message'] ?? 'Password reset failed');
          }
        },
        onFailure: (error) {
          _setErrorMessage('Error: ${error.toString()}');
        },
      );
    } catch (e) {
      _setErrorMessage('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
                              child: _buildResetCard(),
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
          'assets/company_logo.png',
          height: ResponsiveUtils.scaleHeight(context, 80),
        ),
        const SizedBox(height: 10),
        Text(
          'Reset Your Password',
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

  Widget _buildResetCard() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 36),
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
                        _buildResetForm(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
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

  Widget _buildResetForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Username Field
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
            ),
            Text(
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
        ),
        const SizedBox(height: 16),

        // New Password Field
        Row(
          children: [
            Text(
              'New Password',
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
          controller: _newPasswordController,
          hintText: 'Enter new password',
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
          onChanged: (value) {
            if (value.isNotEmpty) {
              _validatePassword(value);
              setState(() {});
            }
          },
          onFieldSubmitted: (_) => _resetPassword(),
        ),
        if (_passwordError != null && _newPasswordController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              _passwordError!,
              style: TextStyle(
                color: AppColors.red,
                fontSize: ResponsiveUtils.fontSize(context, 12),
              ),
            ),
          ),
        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(
                  'Back to Login',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 14),
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        // Submit Button
        SizedBox(
          width: double.infinity,
          child: Animatedbutton(
            title: 'RESET PASSWORD',
            isLoading: _isLoading,
            onPressed: _resetPassword,
            backgroundColor: AppColors.secondary,
            shadowColor: AppColors.primary,
          ),
        ),
      ],
    );
  }
}