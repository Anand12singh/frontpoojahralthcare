import 'package:flutter/material.dart';
import '../../widgets/AnimatedButton.dart';
import '../../widgets/DatePickerInput.dart';
import 'Patient_Registration.dart';
 // Ensure correct import for FormInput widget
import '../../utils/colors.dart';

class FollowUpsTabContent extends StatefulWidget {
  const FollowUpsTabContent({super.key});

  @override
  State<FollowUpsTabContent> createState() => _FollowUpsTabContentState();
}

class _FollowUpsTabContentState extends State<FollowUpsTabContent> {
  List<int> followUpList = [1, 2]; // Initial follow-ups
  bool _isLoading = false;
  void _addFollowUp() {
    setState(() {
      followUpList.add(followUpList.length + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...followUpList.map(
                (index) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Follow up $index',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 12,

                      children:  [

                        DatePickerInput(
                          label: 'Date',
                          hintlabel: 'dd-mm-yyyy',
                          onDateSelected: (date) {
                            // Handle selected date
                            print('Date Date: $date');
                          },
                        ),
                        Expanded(child: FormInput(label: 'Notes', hintlabel: 'Text', maxlength: 4)),
                        Expanded(child: FormInput(label: 'Treatment', hintlabel: 'Text', maxlength: 4)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
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

          const SizedBox(height: 32),
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
