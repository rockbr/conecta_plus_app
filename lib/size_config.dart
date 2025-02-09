import 'package:flutter/material.dart';

class SizeConfig {
  final MediaQueryData mediaQueryData;

  SizeConfig({required this.mediaQueryData});

  static SizeConfig of(BuildContext context) =>
      SizeConfig(mediaQueryData: MediaQuery.of(context));

  double dynamicScaleSize(
      {required double size, required double scaleFactorTablet, required double scaleFactorMini}) {
    if (isTablet()) {
      final scaleFactor = (scaleFactorTablet == 0 ? 2 : scaleFactorTablet);
      return size * scaleFactor;
    }

    if (isMini()) {
      final scaleFactor = (scaleFactorMini == 0 ? 0.8 : scaleFactorMini);
      return size * scaleFactor;
    }

    return size;
  }

  /// Defines device type based on logical device pixels. Bigger than 600 means it is a tablet
  bool isTablet() {
    final shortestSide = mediaQueryData.size.shortestSide;
    return shortestSide > 600;
  }

  /// Defines device type based on logical device pixels. Less or equal than 320 means it is a mini device
  bool isMini() {
    final shortestSide = mediaQueryData.size.shortestSide;
    return shortestSide <= 320;
  }
}