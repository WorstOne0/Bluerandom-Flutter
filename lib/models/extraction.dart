import 'package:flutter/material.dart';

// All of the extractors
enum ExtractionMethod { oddOrEvenDifference, earlyVonNeumann, oddOrEven }

class Extraction extends ChangeNotifier {
  Extraction();

  // Tell when it is extracting - Not used yet
  bool isExtracting = false;

  // Number total of bytes generated - Temporary
  int _totalBytes = 0;

  // List with 8 bits(Byte) - Temporary
  List<int> _outputByte = <int>[];
  // The number of bits generated, when have 8 bits(1 byte) it resets
  int _count = 0;

  // Recieves a list of devices and extract the bits from it
  void startExtraction(
      List<Map> deviceList, ExtractionMethod extractionMethod) {
    // Tells that it started extracting - Not used yet
    isExtracting = true;

    // Run the extraction for each device
    deviceList.forEach((device) {
      // Extract 1 bit from the RSSI
      int bit = extractBitFromRssi(
          device["rssiNew"], device["rssiOld"], extractionMethod);

      // If its not a invalid bit
      if (bit != -1) {
        _outputByte.add(bit);
        _count++;
      }

      // Byte output
      if (_count == 8) {
        _count = 0;
        _totalBytes++;
        print(_outputByte);
        print(_totalBytes);

        // Just clear the list for now
        _outputByte.clear();
      }
    });
  }

  // Stops Extraction - Not used
  void stopExtraction() => isExtracting = false;

  // Decides witch extractor use
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
    int desloc1 = rssiNew & 0x1, desloc2 = rssiOld & 0x1;

    if (desloc1 == desloc2) {
      return -1;
    }

    return desloc2 == 0 ? 0 : 1;
  }

  // Just odd or even. For each rssi reading.
  int oddOrEven(int rssiNew) {
    return rssiNew % 2 == 0 ? 0 : 1;
  }
}
