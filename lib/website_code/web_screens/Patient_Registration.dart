import 'package:flutter/material.dart';
import 'package:poojaheakthcare/widgets/AnimatedButton.dart';
import '../../utils/colors.dart';
import '../../widgets/CustomCheckbox.dart';
import '../../widgets/DatePickerInput.dart';
import '../../widgets/custom_text_field.dart';

class OnboardingForm extends StatefulWidget {
  const OnboardingForm({super.key});

  @override
  State<OnboardingForm> createState() => _OnboardingFormState();
}

class _OnboardingFormState extends State<OnboardingForm> {
  int _currentStep = 0;
  bool _isLoading = false;
  final GlobalKey<FormState> _personalInfoFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _medicalInfoFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _reportsFormKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  bool checkboxValue = false;
  String radioValue = 'option1';
  @override
  Widget build(BuildContext context) {
    return Container(

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Step Indicator
          _buildStepNavigation(),
          const SizedBox(height: 20),

          // Form Content
          IndexedStack(
            index: _currentStep,
            children: [
              _buildPersonalInfoForm(),
              _buildMedicalInfoForm(),
              _buildAdditionalInfoForm(),
            ],
          ),


      /*    const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,

            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_currentStep > 0)
                  Animatedbutton(
                    onPressed: () {
                      setState(() => _currentStep--);
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    shadowColor: Colors.white,
                    titlecolor: AppColors.primary,

                    backgroundColor: Colors.white,
                    borderColor: AppColors.secondary,
                    isLoading: _isLoading,
                    title:  'BACK',
                  )
                else
                  const SizedBox(width: 120),

                SizedBox(width: 10,),
                Animatedbutton(
                  onPressed: () {
                    if (_currentStep < 2) {
                      setState(() => _currentStep++);
                      _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                     // _submitForm();
                    }
                  },
                  shadowColor: Colors.white,
                  backgroundColor: AppColors.secondary,
                  isLoading: _isLoading,
                  title: _currentStep == 2 ? 'SUBMIT' : 'NEXT',
                ),
              ],
            ),
          ),*/
        ],
      ),
    );
  }

  Widget _buildStepNavigation() {
    return Container(
      width: 550,


      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildClickableStep(1, 'Personal Information', 0),
          _buildStepConnector(_currentStep >= 0),
          _buildClickableStep(2, 'Medical Information', 1),
          _buildStepConnector(_currentStep >= 1),
          _buildClickableStep(3, 'Reports & Documents', 2),
        ],
      ),
    );
  }

  Widget _buildClickableStep(int number, String label, int step) {
    return GestureDetector(
      onTap: () {
        bool isValid = true;
        if (_currentStep == 0) {
          isValid = _personalInfoFormKey.currentState?.validate() ?? false;
        } else if (_currentStep == 1) {
          isValid = _medicalInfoFormKey.currentState?.validate() ?? false;
        }

        if (isValid) {
          setState(() => _currentStep = step);
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      child: _buildStepIndicator(number, label, _currentStep >= step),
    );
  }

  Widget _buildStepIndicator(int number, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppColors.secondary : AppColors.numberbackground,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? AppColors.secondary : AppColors.numberbackground,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: TextStyle(
                color: isActive ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.primary : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoForm() {
    return Form(
      key: _personalInfoFormKey,
      child: Container(

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
            const Text(
              '1. Personal Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 20,
              runSpacing: 16,
              children: const [
                FormInput(label: 'First Name',hintlabel: "Enter First Name",),
                FormInput(label: 'Last Name',hintlabel: "Enter Last Name",),
                FormInput(label: 'Phone Number',hintlabel: "Enter Phone Number",),
                FormInput(label: 'PH ID',hintlabel: "Enter PH ID",),
                FormInput(label: 'Address',hintlabel: "Enter Address",),
                FormInput(label: 'City',hintlabel: "Enter City",),
                FormInput(label: 'State',hintlabel: "Enter State",),
                FormInput(label: 'Pin Code',hintlabel: "Enter Pin Code",),
                FormInput(label: 'Country',hintlabel: "Enter Country",),
                FormInput(label: 'Age',hintlabel: "Enter Country",),
                DropdownInput(label: 'Gender',),
                FormInput(label: 'Consultation Date', isDate: true),
                FormInput(label: 'Referral by',hintlabel: "Enter Referral by",),
                DropdownInput(label: 'Clinic Location'),
                FormInput(label: 'Other  Location',hintlabel: "Enter Other  Location",),

                FormInput(label: 'Height (cms)',hintlabel: "Enter Height (cms)",),
                FormInput(label: 'Weight (kg)',hintlabel: "Enter Weight (kg)",),
                FormInput(label: 'BMI (kg/m²)',hintlabel: "Enter BMI (kg/m²)",),

              ],
            ),
            const SizedBox(height: 20),
            _buildFormNavigationButtons(isFirstStep: true),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalInfoForm() {
    return Form(
      key: _medicalInfoFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [


          // 1. Chief Complaints
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
                const Text("1. Chief Complaints",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: AppColors.primary)),

                const SizedBox(height: 8),
                Container(

                    width: double.infinity,
                    child: const FormInput(label: 'Chief Complaints',maxlength: 5,)),

              ],
            ),
          ),

          const SizedBox(height: 20),

          // 2. History
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
                const Text("2. History",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: AppColors.primary)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: const [
                    CustomCheckbox(label: 'H/O DM'),
                    CustomCheckbox(label: 'Hypertension'),
                    CustomCheckbox(label: 'IHD'),
                    CustomCheckbox(label: 'COPD'),
                  ],
                ),
                const SizedBox(height: 8),
                FormInput(label: 'Since when',maxlength: 1,),
                const SizedBox(height: 8),

                Wrap(
                  spacing: 20,
                  runSpacing: 16,
                  children: const [
                    FormInput(label: 'Any Other Illness',maxlength: 5,),
                    FormInput(label: 'Past Surgical History',maxlength: 5),
                    FormInput(label: 'H/O Drug Allergy',maxlength: 5),
                  ],
                ),

              ],

            ),
          ),

          const SizedBox(height: 20),

          // 3. General Examination
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
                const Text("3. General Examination",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: AppColors.primary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 20,
                  runSpacing: 16,
                  children: [

                    Container(
                      width: 275,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Temp",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, color: AppColors.primary)),

                          SizedBox(height: 8,),

                          Row(
                            children: [
                              CustomRadioButton<String>(
                                value: 'option1',
                                groupValue: radioValue,
                                onChanged: (value) {
                                  setState(() => radioValue = value!);
                                },
                                label: 'Option 1',
                              ),
                              SizedBox(width: 8,),
                              CustomRadioButton<String>(
                                value: 'option2',
                                groupValue: radioValue,
                                onChanged: (value) {
                                  setState(() => radioValue = value!);
                                },
                                label: 'Option 2',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),


                    const FormInput(label: 'Pulse (BPM)'),
                    const DropdownInput(label: 'BP (mmHg)'),
                   // const DropdownInput(label: 'Pallor'),
                    Container(
                      width: 275,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Pallor",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, color: AppColors.primary)),

                          SizedBox(height: 8,),

                          Row(
                            children: [
                              CustomRadioButton<String>(
                                value: 'option1',
                                groupValue: radioValue,
                                onChanged: (value) {
                                  setState(() => radioValue = value!);
                                },
                                label: 'Option 1',
                              ),
                              SizedBox(width: 4,),
                              Text("+"),
                              SizedBox(width: 4,),
                              CustomRadioButton<String>(
                                value: 'option2',
                                groupValue: radioValue,
                                onChanged: (value) {
                                  setState(() => radioValue = value!);
                                },
                                label: 'Option 2',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 275,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Icterus",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, color: AppColors.primary)),

                          SizedBox(height: 8,),

                          Row(
                            children: [
                              CustomRadioButton<String>(
                                value: 'option1',
                                groupValue: radioValue,
                                onChanged: (value) {
                                  setState(() => radioValue = value!);
                                },
                                label: 'Option 1',
                              ),
                              SizedBox(width: 4,),
                              Text("+"),
                              SizedBox(width: 4,),
                              CustomRadioButton<String>(
                                value: 'option2',
                                groupValue: radioValue,
                                onChanged: (value) {
                                  setState(() => radioValue = value!);
                                },
                                label: 'Option 2',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 275,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Lymphadenopathy",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, color: AppColors.primary)),

                          SizedBox(height: 8,),

                          Row(
                            children: [
                              CustomRadioButton<String>(
                                value: 'option1',
                                groupValue: radioValue,
                                onChanged: (value) {
                                  setState(() => radioValue = value!);
                                },
                                label: 'Option 1',
                              ),
                              SizedBox(width: 4,),
                              Text("+"),
                              SizedBox(width: 4,),
                              CustomRadioButton<String>(
                                value: 'option2',
                                groupValue: radioValue,
                                onChanged: (value) {
                                  setState(() => radioValue = value!);
                                },
                                label: 'Option 2',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                 Container(
                      width: 275,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Oedema",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, color: AppColors.primary)),

                          SizedBox(height: 8,),

                          Row(
                            children: [
                              CustomRadioButton<String>(
                                value: 'option1',
                                groupValue: radioValue,
                                onChanged: (value) {
                                  setState(() => radioValue = value!);
                                },
                                label: 'Option 1',
                              ),
                              SizedBox(width: 4,),
                              Text("+"),
                              SizedBox(width: 4,),
                              CustomRadioButton<String>(
                                value: 'option2',
                                groupValue: radioValue,
                                onChanged: (value) {
                                  setState(() => radioValue = value!);
                                },
                                label: 'Option 2',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                        width: double.infinity,
                        child: const FormInput(label: 'H/O Present Medication')),
                  ],
                ),

              ],
            ),
          ),


          const SizedBox(height: 20),

          // 4. Systemic Examination
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
                const Text("4. Systemic Examination",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: AppColors.primary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 20,
                  runSpacing: 16,
                  children: const [
                    FormInput(label: 'RS (Respiratory System)'),
                    FormInput(label: 'CVS (Cardio Vascular System)'),
                    FormInput(label: 'CNS (Central Nervous System)'),
                    FormInput(label: 'P/A Per Abdomen'),

                    FormInput(label: 'Upload Attachments'),
                    FormInput(label: 'P/A Abdomen Notes'),
                    FormInput(label: 'P/R Rectum Notes'),
                    SizedBox(
                        width: double.infinity,
                        child: const FormInput(label: 'Local Examination',maxlength: 2,)),
                  ],
                ),

              ],
            ),
          ),


          const SizedBox(height: 20),

          // 5. Diagnosis & Plan
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
                const Text("5. Diagnosis & Plan",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: AppColors.primary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 20,
                  runSpacing: 16,
                  children: const [
                    SizedBox(
                        width: double.infinity,
                        child: FormInput(label: 'Clinical Diagnosis')),
                    SizedBox(
                        width: double.infinity,
                        child: FormInput(label: 'Comorbidities')),
                    SizedBox(

                        width: double.infinity,
                        child: FormInput(label: 'Plan')),
                    SizedBox(
                        width: double.infinity,
                        child: FormInput(label: 'Advice')),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildFormNavigationButtons(),
        ],
      ),
    );
  }


// Add this new helper method
  Widget _buildFormNavigationButtons({
    bool isFirstStep = false,
    bool isLastStep = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (!isFirstStep)
            Animatedbutton(
              onPressed: () {
                setState(() => _currentStep--);
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              shadowColor: Colors.white,
              titlecolor: AppColors.primary,
              backgroundColor: Colors.white,
              borderColor: AppColors.secondary,
              isLoading: _isLoading,
              title: 'BACK',
            )
          else
            const SizedBox(width: 120),

          const SizedBox(width: 10),
          Animatedbutton(
            onPressed: () {
              if (!isLastStep) {
                setState(() => _currentStep++);
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                // _submitForm();
              }
            },
            shadowColor: Colors.white,
            backgroundColor: AppColors.secondary,
            isLoading: _isLoading,
            title: isLastStep ? 'SUBMIT' : 'NEXT',
          ),
        ],
      ),
    );
  }
  Widget _buildAdditionalInfoForm() {
    return Form(
      key: _reportsFormKey,
      child: Column(
        spacing: 10,
        children: [
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
                const Text(
                  '1. Reports',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 20,),
                Row(children: [
                  Text(
                    'Blood Report',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: AppColors.hinttext),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      margin: const EdgeInsets.only(left: 8), // Add some spacing
                      color: AppColors.backgroundcolor,
                    ),
                  ),
                ],),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 20,
                  runSpacing: 16,
                  children: const [
                    SizedBox(
                        width: double.infinity,
                        child: FormInput(label: 'Laboratory')),
                    FormInput(label: 'Hemoglobin'),
                    FormInput(label: 'Total leucocyte count'),
                    FormInput(label: 'ESR'),
                    FormInput(label: 'Platelets'),
                    FormInput(label: 'Urine Routine'),
                    FormInput(label: 'Urine Culture'),
                    FormInput(label: 'BUN'),
                    FormInput(label: 'Serum Creatinine'),
                    FormInput(label: 'Serum Electrolytes'),
                    FormInput(label: 'LFT'),
                    FormInput(label: 'Prothrombin Time / INR'),
                    FormInput(label: 'Blood Sugar Fasting'),
                    FormInput(label: 'Blood Sugar Post Prandial'),
                    FormInput(label: 'HBA1C'),
                    FormInput(label: 'HBSAG'),
                    FormInput(label: 'HIV'),
                    FormInput(label: 'HCV'),
                    FormInput(label: 'Thyroid Function Test T3 T4 TSH'),
                    FormInput(label: 'MISC'),
                    SizedBox(
                        width: double.infinity,
                        child: FormInput(label: 'Findings')),

                  ],
                ),
                SizedBox(height: 20,),
                Row(children: [
                  Text(
                    'X-Ray Report',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: AppColors.hinttext),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      margin: const EdgeInsets.only(left: 8), // Add some spacing
                      color: AppColors.backgroundcolor,
                    ),
                  ),
                ],),
                SizedBox(height: 10,),
                SizedBox(
                    width: double.infinity,
                    child: FormInput(label: 'Findings')),
                SizedBox(height: 10,),
                Row(

                  children: [
                  Text(
                    'CT Scan Report',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: AppColors.hinttext),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      margin: const EdgeInsets.only(left: 8), // Add some spacing
                      color: AppColors.backgroundcolor,
                    ),
                  ),
                ],),
                SizedBox(height: 10,),
                Row(
                  spacing: 10,
                  children: [
                    FormInput(label: 'CT Scan',hintlabel: "Upload CT Scan Reports",),

                    Expanded(

                        child: FormInput(label: 'Media History')),
                  ],
                ),
                SizedBox(height: 10,),
                Row(
                  spacing: 10,
                  children: [
                   // FormInput(label: 'Date',hintlabel: "dd-mm-yyyy",),
                    DatePickerInput(
                      label: 'Date',
                      hintlabel: 'dd-mm-yyyy',
                      onDateSelected: (date) {
                        // Handle selected date
                        print('Date Date: $date');
                      },
                    ),
                    Expanded(

                        child: FormInput(label: 'Findings')),
                  ],
                ),     SizedBox(height: 10,),

                Row(children: [
                  Text(
                    'MRI Report',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: AppColors.hinttext),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      margin: const EdgeInsets.only(left: 8), // Add some spacing
                      color: AppColors.backgroundcolor,
                    ),
                  ),
                ],),
                SizedBox(height: 10,),
                SizedBox(
                    width: double.infinity,
                    child: FormInput(label: 'Findings')),
                SizedBox(height: 10,),
                Row(children: [
                  Text(
                    'PET Scan Report',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: AppColors.hinttext),
                  ),
                  Expanded(
                    child: Container(
                      height: 1,
                      margin: const EdgeInsets.only(left: 8), // Add some spacing
                      color: AppColors.backgroundcolor,
                    ),
                  ),
                ],),
                SizedBox(height: 10,),

                SizedBox(
                    width: double.infinity,
                    child: FormInput(label: 'Findings')),
                SizedBox(height: 10,),
                Row(

                  children: [
                    Text(
                      'ECG Report',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: AppColors.hinttext),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        margin: const EdgeInsets.only(left: 8), // Add some spacing
                        color: AppColors.backgroundcolor,
                      ),
                    ),
                  ],),
                SizedBox(height: 10,),

                Row(
                  spacing: 10,
                  children: [
                    FormInput(label: 'ECG Report',hintlabel: "Upload ECG Reports",),

                    Expanded(

                        child: FormInput(label: 'Media History')),
                  ],
                ),
                SizedBox(height: 10,),
                SizedBox(
          width: double.infinity,
                    child: FormInput(label: 'Findings')),
                SizedBox(height: 10,),

                Row(

                  children: [
                    Text(
                      '2D ECHO Report',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: AppColors.hinttext),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        margin: const EdgeInsets.only(left: 8), // Add some spacing
                        color: AppColors.hinttext,
                      ),
                    ),
                  ],),
                SizedBox(height: 10,),
                SizedBox(
                    width: double.infinity,
                    child: FormInput(label: 'Findings')),
                SizedBox(height: 10,),
                Row(

                  children: [
                    Text(
                      'Echocardiogram Report',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: AppColors.hinttext),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        margin: const EdgeInsets.only(left: 8), // Add some spacing
                        color: AppColors.backgroundcolor,
                      ),
                    ),
                  ],),
                SizedBox(height: 10,),
                SizedBox(
                    width: double.infinity,
                    child: FormInput(label: 'Findings')),
                SizedBox(height: 10,),
                Row(

                  children: [
                    Text(
                      'PFT Report',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,color: AppColors.hinttext),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        margin: const EdgeInsets.only(left: 8), // Add some spacing
                        color: AppColors.backgroundcolor,
                      ),
                    ),
                  ],),
                SizedBox(height: 10,),
                SizedBox(
                    width: double.infinity,
                    child: FormInput(label: 'Findings')),
                SizedBox(height: 10,),
                Row(
                  spacing: 10,
                  children: [
                    FormInput(label: 'MISC',hintlabel: "Upload MISC",),

                    Expanded(

                        child: FormInput(label: 'Media History')),
                  ],
                ),
                SizedBox(height: 10,),
                SizedBox(
                    width: double.infinity,
                    child: FormInput(label: 'Findings')),
                SizedBox(height: 10,),

              ],
            ),
          ),
          Container( width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.Offwhitebackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.Containerbackground),
            ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            const Text(
              '2. Doctor Notes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 20,),
            SizedBox(
                width: double.infinity,
                child: FormInput(label: 'Diagnosis',hintlabel: "Text",maxlength: 5,)),

              SizedBox(height: 10,),
              Row(
                spacing: 10,
                children: [
                  FormInput(label: 'Media Upload',hintlabel: "Upload Media",),


                  Expanded(

                      child: FormInput(label: 'Media History')),
                ],
              ),
              SizedBox(height: 10,),
              DatePickerInput(
                label: 'Follow up date',
                hintlabel: 'dd-mm-yyyy',
                onDateSelected: (date) {
                  // Handle selected date
                  print('Follow up date: $date');
                },
              ),
            //  FormInput(label: 'Follow up date',hintlabel: "dd-mm-yyyy",),
          ],),
          ),
          Container( width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.Offwhitebackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.Containerbackground),
            ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            const Text(
              '2. Misc',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 20,),
            SizedBox(
                width: double.infinity,
                child: FormInput(label: 'Text',hintlabel: "Text",maxlength: 5,)),


          ],),
          ),
          const SizedBox(height: 20),
          _buildFormNavigationButtons(isLastStep: true),
        ],
      ),
    );
  }
}


class FormInput extends StatelessWidget {
  final String label;
  final String hintlabel;
  final bool isDate;
  final int maxlength;
  const FormInput({super.key, required this.label,this.maxlength=1, this.isDate = false,this.hintlabel=""});

  @override
  Widget build(BuildContext context) {
    return SizedBox(

      width: 275,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: AppColors.primary)),
          const SizedBox(height: 4),
          CustomTextField(
            maxLines: maxlength,
            controller: TextEditingController(),
            hintText: hintlabel,

            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            validator: (value) {

              return null;
            },
          ),

        ],
      ),
    );
  }
}

class DropdownInput extends StatelessWidget {
  final String label;
  const DropdownInput({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 275,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: AppColors.primary)),
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: const [
              DropdownMenuItem(value: 'Male', child: Text('Male')),
              DropdownMenuItem(value: 'Female', child: Text('Female')),
            ],
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }
}

class PatientDetailsSidebar extends StatelessWidget {
  const PatientDetailsSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sidebarCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:  [
              Text('PH ID– 75842152', style: TextStyle(fontWeight: FontWeight.w600,fontSize: 20,color: AppColors.primary)),
              SizedBox(height: 8),
              buildInfoBlock("Patient's Name", "Balasubramaniam Tiwari - 42/M"),
              buildInfoBlock("History", "H/O DM  |  IHD  |  COPD"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildInfoBlock("Location", "Pooja Nursing\nHome"),
                  Container(
                    width: 150,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        buildInfoBlock("Occupation", "Service"),
                      ],
                    ),
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildInfoBlock("Diagnosis", "Lorem Ipsum"),
                  Container(  width: 150,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      buildInfoBlock("Surgery Type", "No"),
                    ],
                  )),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildInfoBlock("Chief Complaints", "Lorem Ipsum"),
                  Container(width: 150,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      buildInfoBlock("Clinical Diagnosis", "Lorem Ipsum"),
                    ],
                  )),
                ],
              ),

              SizedBox(height: 12),
              SizedBox(
                  width: double.infinity,
                  child: FormInput(label: 'Summary')),

            ],
          ),
        ),
        const SizedBox(height: 20),
        _sidebarCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Contact Patient",style: TextStyle(fontSize: 14,fontWeight: FontWeight.w500,color: AppColors.secondary),),
              ListTile(
                leading: Image.asset(
                  "assets/whatsapp.png",
                  height: 20,
                ),
                title: const Text('Connect on Whatsapp'),
                onTap: () {},
              ),
              ListTile(
                leading: Image.asset(
                  "assets/call.png",
                  height: 20,
                ),
                title: const Text('Connect on Call'),
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget buildInfoBlock(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 14, color: Colors.black),
          children: [
            TextSpan(
              text: '$title\n',
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                color: Color(0xFF5B5B5B),
              ),
            ),
            TextSpan(
              text: content,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Color(0xFF132A3E),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _sidebarCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}
