import 'package:flutter/material.dart';
import '../../widgets/AnimatedButton.dart';
import '../../widgets/custom_text_field.dart';
import 'Patient_Registration.dart';

import '../../utils/colors.dart'; // For AppColors.primary

class SurgeryTabContent extends StatefulWidget {
  const SurgeryTabContent({super.key});

  @override
  State<SurgeryTabContent> createState() => _SurgeryTabContentState();

  static InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    );
  }
}

class _SurgeryTabContentState extends State<SurgeryTabContent> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('1. Surgery Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // Row 1
          Row(
            children: const [
              Expanded(child: FormInput(label: 'Surgery', hintlabel: 'Text')),
              SizedBox(width: 12),
              FormInput(label: 'Date', hintlabel: 'dd-mm-yyyy', isDate: true),
              SizedBox(width: 12),
              FormInput(label: 'Surgeon', hintlabel: 'Text'),
            ],
          ),
          const SizedBox(height: 12),

          // Row 2
          Row(
            children:  [
              FormInput(label: 'Assistant', hintlabel: 'Text'),
              SizedBox(width: 12),
              FormInput(label: 'Anaesthetist/s', hintlabel: 'Text'),
              SizedBox(width: 12),
              FormInput(label: 'Anaesthesia', hintlabel: 'Text'),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Time taken:', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.primary)),
                  SizedBox(width: 12),
                  Row(
                    children: [

                      SizedBox(
                        width: 60,
                        child:   CustomTextField(
                          controller: TextEditingController(),
                          hintText: '00',

                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          validator: (value) {

                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Hr',style: const TextStyle(
                          fontWeight: FontWeight.w600, color: AppColors.primary)),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 60,
                        child:   CustomTextField(
                          controller: TextEditingController(),
                          hintText: '00',

                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          validator: (value) {

                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Min',style: const TextStyle(
                          fontWeight: FontWeight.w600, color: AppColors.primary)),
                    ],
                  ),
                ],
              ),
            ],
          ),



          const SizedBox(height: 12),

          // Row 4
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              FormInput(label: 'Findings', hintlabel: 'Text', maxlength: 2),
              SizedBox(width: 12),
              FormInput(label: 'Implants used, if any', hintlabel: 'Text', maxlength: 2), SizedBox(width: 12),
              FormInput(label: 'Upload Implants ', hintlabel: 'Upload Implants ', maxlength: 1),
              SizedBox(width: 12),
               FormInput(label: 'Complications, if any', hintlabel: 'Text', maxlength: 2),
              // Implants Upload (Custom)
            ],
          ),




          const SizedBox(height: 12),

          SizedBox(
              width: double.infinity,
              child: const FormInput(label: 'Procedure', hintlabel: 'Text', maxlength: 4)),
          const SizedBox(height: 12),

          SizedBox(

              width: double.infinity,
              child: const FormInput(label: 'Notes', hintlabel: 'Text', maxlength: 2)),
          const SizedBox(height: 20),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Animatedbutton(
                onPressed: () {

                },
                shadowColor: Colors.white,
                titlecolor: AppColors.primary,

                backgroundColor: Colors.white,
                borderColor: AppColors.secondary,
                isLoading: _isLoading,
                title:  'Cancel',
              ),
              const SizedBox(width: 12),
              Animatedbutton(
                onPressed: () {

                },
                shadowColor: Colors.white,
                backgroundColor: AppColors.secondary,
                isLoading: _isLoading,
                title:   'Save',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
