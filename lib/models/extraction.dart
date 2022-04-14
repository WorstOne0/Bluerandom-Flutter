import 'package:flutter/material.dart';

enum ExtractionMethod { oddOrEvenDifference, earlyVonNeumann, oddOrEven }

class Extraction extends ChangeNotifier {
  Extraction();

  bool isExtracting = false;

  late int _outputByte;
  int _count = 0;

  void startExtraction(
      List<Map> deviceList, ExtractionMethod extractionMethod) {
    isExtracting = true;

    deviceList.forEach((device) {
      // var bit = extractBitFromRssi(
      //     device["rssiNew"], device["rssiOld"], extractionMethod);

      _count++;
      if (_count == 8) {
        _count = 0;
      }
      print(_count);
    });
  }

  void stopExtraction() => isExtracting = false;

  int extractBitFromRssi(
      int rssiNew, int rssiOld, ExtractionMethod extractionMethod) {
    // Selects the extraction method
    switch (extractionMethod) {
      case ExtractionMethod.oddOrEvenDifference:
        return oddOrEvenDifference(rssiNew, rssiOld);
      case ExtractionMethod.earlyVonNeumann:
        return earlyVonNeumann(rssiNew, rssiOld);
      case ExtractionMethod.oddOrEven:
        return oddOrEven(rssiNew);
    }
  }

  // Odd or Even Difference
  int oddOrEvenDifference(int rssiNew, int rssiOld) {
    int diference = rssiNew - rssiOld;

    if (diference != 0) {
      return diference % 2 == 0 ? 0 : 1;
    }

    return -1;
  }

  // "Early" Von neumann (last bit of two consecutive RSSI readings)
  int earlyVonNeumann(int rssiNew, int rssiOld) {
    return 0;
  }

  // Just odd or even. For each rssi reading.
  int oddOrEven(int rssiNew) {
    return rssiNew % 2 == 0 ? 0 : 1;
  }
}
