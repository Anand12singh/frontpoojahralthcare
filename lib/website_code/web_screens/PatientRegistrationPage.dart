import 'package:flutter/material.dart';

import '../../utils/colors.dart';
import '../../widgets/AnimatedButton.dart';
import '../../widgets/custom_text_field.dart';

class PatientRegistrationPage extends StatefulWidget {
  const PatientRegistrationPage({super.key});

  @override
  State<PatientRegistrationPage> createState() => _PatientRegistrationPageState();
}

class _PatientRegistrationPageState extends State<PatientRegistrationPage> {
  @override
  Widget build(BuildContext context) {
    final TextEditingController firstNameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    bool _isLoading = false;
    return Scaffold(
      backgroundColor: AppColors.backgroundColor, // Light blue background
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Patient Registration',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C3B70),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Quickly onboard a patient into the system.',
                textAlign: TextAlign.center,
                style: TextStyle(color:AppColors.secondary ),
              ),
              const SizedBox(height: 24),
              _buildField('First Name', 'Enter first name', firstNameController),
              const SizedBox(height: 16),
              _buildField('Last Name', 'Enter last name', lastNameController),
              const SizedBox(height: 16),
              _buildField('Phone Number', 'Enter Phone Number', phoneController),
              const SizedBox(height: 24),
              Animatedbutton(
                title: 'Add Patient',
                isLoading: _isLoading,
                onPressed: () {

                },
                backgroundColor: AppColors.secondary,
                shadowColor: AppColors.primary,
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
      String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: AppColors.primary)),
        const SizedBox(height: 4),
        CustomTextField(
          controller: controller,
          hintText: hint,

          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          validator: (value) {

            return null;
          },
        ),

      ],
    );
  }
}
