import 'package:flutter/material.dart';

/// Enum describing device sizes
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

class ResponsiveUtils {
  static DeviceType getDeviceType(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return DeviceType.mobile;
    } else if (width < 1024) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  static bool isMobile(BuildContext context) =>
      getDeviceType(context) == DeviceType.mobile;

  static bool isTablet(BuildContext context) =>
      getDeviceType(context) == DeviceType.tablet;

  static bool isDesktop(BuildContext context) =>
      getDeviceType(context) == DeviceType.desktop;

  /// Example common width for cards or popups
  static double getPopupWidth(BuildContext context) {
    switch (getDeviceType(context)) {
      case DeviceType.mobile:
        return MediaQuery.of(context).size.width * 0.9;
      case DeviceType.tablet:
        return 600;
      case DeviceType.desktop:
        return 740;
    }
  }

  /// Example default font size scaling
  static double fontSize(BuildContext context, double size) {
    if (isMobile(context)) {
      return size * 0.85;
    } else if (isTablet(context)) {
      return size * 1.0;
    } else {
      return size * 1;
    }
  }

  /// Height scaling
  static double scaleHeight(BuildContext context, double height) {
    if (isMobile(context)) {
      return height * 0.85;
    } else if (isTablet(context)) {
      return height * 0.95;
    } else {
      return height;
    }
  }

  /// Width scaling
  static double scaleWidth(BuildContext context, double width) {
    if (isMobile(context)) {
      return width * 0.9;
    } else if (isTablet(context)) {
      return width * 0.95;
    } else {
      return width;
    }
  }

  /// Example for field horizontal padding
  static EdgeInsets fieldPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
    } else {
      return const EdgeInsets.symmetric(horizontal: 20, vertical: 12);
    }
  }
}
