import 'package:flutter/material.dart';
import 'package:poojaheakthcare/utils/colors.dart';


class ShowDialogs {
  static void showSnackBar(BuildContext context, String message) {
    // Determine if the device is a tablet based on screen width


    double snackBarWidth = MediaQuery.of(context).size.width * 0.9;
    final snackBar = SnackBar(


      content: Text(
        message,
        style: TextStyle(
          color: AppColors.primary, // Custom text color
          fontSize: 14.0, // Font size
          fontFamily: 'Inter', // Assuming 'Inter' is your font
        ),
        textAlign:TextAlign.center , // Optional: center text on tablet
      ),
      backgroundColor: AppColors.primaryLight, // Background color
      behavior: SnackBarBehavior.floating, // Makes the snackbar float above other content
      duration: Duration(seconds: 2), // Duration for which the snackbar will be displayed

    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
