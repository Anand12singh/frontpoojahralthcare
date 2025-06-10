import 'package:flutter/material.dart';
import '../../widgets/AnimatedButton.dart';
import '../../widgets/CustomCheckbox.dart';
import 'Patient_Registration.dart';
// Ensure path is correct
import '../../utils/colors.dart';

class DischargeTabContent extends StatefulWidget {
  const DischargeTabContent({super.key});

  @override
  State<DischargeTabContent> createState() => _DischargeTabContentState();
}

class _DischargeTabContentState extends State<DischargeTabContent> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // 1. Information
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.Offwhitebackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.Containerbackground),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('1. Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                const SizedBox(height: 16),
                Wrap(
                  spacing: 20,
                  runSpacing: 16,
                  children: const [
                    FormInput(label: 'Consultant', hintlabel: 'Text'),
                    FormInput(label: 'Contact', hintlabel: 'Text'),
                    FormInput(label: 'Qualifications', hintlabel: 'Text'),
                    FormInput(label: 'Indoor Reg No', hintlabel: 'Text'),
                    FormInput(label: 'Admission Date', hintlabel: 'dd-mm-yyyy', isDate: true),
                    FormInput(label: 'Admission Time', hintlabel: '00:12:30'),
                    FormInput(label: 'Discharge Date', hintlabel: 'dd-mm-yyyy', isDate: true),
                    FormInput(label: 'Discharge Time', hintlabel: '00:12:30'),


                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  spacing: 10,
                  children: [
                    Expanded(child: FormInput(label: 'Operation Type', hintlabel: 'Text')),
                    Expanded(child: FormInput(label: 'Any drug allergy reported/noted', hintlabel: 'Text')),
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  spacing: 10,
                  children: [
                    Expanded(child: FormInput(label: 'Diagnosis', hintlabel: 'Text', maxlength: 4)),
                    Expanded(child: FormInput(label: 'Chief complaints', hintlabel: 'Text', maxlength: 4)),
                  ],
                ),

              ],
            ),
          ),

          const SizedBox(height: 32),

          // 2. Past History
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.Offwhitebackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.Containerbackground),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('2. Past History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: const [
                      CustomCheckbox(label: 'H/O DM'),
                    CustomCheckbox(label: 'Hypertension'),
                    CustomCheckbox(label: 'IHD'),
                    CustomCheckbox(label: 'COPD'),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: const [
                    FormInput(label: 'Surgical History', hintlabel: 'Text', maxlength: 2),
                    FormInput(label: 'Personal History', hintlabel: 'Text', maxlength: 2),
                    FormInput(label: 'Other Illness', hintlabel: 'Text', maxlength: 2),
                    FormInput(label: 'History of Present Medication', hintlabel: 'Text', maxlength: 2),
                    FormInput(label: 'Family History', hintlabel: 'Text', maxlength: 2),
                    FormInput(label: 'On Examination', hintlabel: 'Text', maxlength: 2),
                    FormInput(label: 'Treatment given', hintlabel: 'Text', maxlength: 2),
                    FormInput(label: 'Course during hospitalization', hintlabel: 'Text', maxlength: 2),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // 3. Upload Documents
          Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.Offwhitebackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.Containerbackground),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('3. Upload Documents', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Row(
                    spacing: 10,
                    children: [
                      Expanded(child: FormInput(label: 'Upload Documents',hintlabel: "Upload Documents",)),

                      Expanded(

                          child: FormInput(label: 'Media History')),
                    ],
                  ),


                ],
              )),

          const SizedBox(height: 32),

          // 4. Investigations
          Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.Offwhitebackground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.Containerbackground),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('4. Investigations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

              const SizedBox(height: 16),
              Row(
                spacing: 12,

                children: const [
                  FormInput(label: 'Investigations Date', hintlabel: 'dd-mm-yyyy', isDate: true),
                  Expanded(child: FormInput(label: 'Test', hintlabel: 'Text',maxlength: 4,)),
                  Expanded(child: FormInput(label: 'Positive Findings', hintlabel: 'Text',maxlength: 4,)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.add_box,color: AppColors.secondary,size: 40,),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),

            ],
          )),

          const SizedBox(height: 32),
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

class CheckboxTile extends StatelessWidget {
  final String label;

  const CheckboxTile({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(value: false, onChanged: (val) {}),
        Text(label),
      ],
    );
  }
}
