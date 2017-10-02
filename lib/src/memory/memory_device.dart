// Copyright (c) 2017, Minerhub. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:size_type/size_type.dart';
import 'package:system_info/src/common/device.dart';
import 'package:system_info/src/common/device_type.dart';

/// Represents a system primary memory (RAM)
class MemoryDevice extends Device {
  final Size size;
  final String formFactor;
  final int bank;
  final String memoryType;
  final double frequency;
  final double maxFrequency;

  MemoryDevice.fromInfo(String name, String vendor,
      {Size size = const Size(0),
      String formFactor,
      int bank = -1,
      String memoryType = "Unknown",
      double freq = 0.0,
      double maxFreq = 0.0})
      : size = size,
        formFactor = formFactor,
        bank = bank,
        memoryType = memoryType,
        frequency = freq,
        maxFrequency = maxFreq,
        super.fromInfo(name, vendor, DeviceType.Memory);

  String toString() {
    return "MemoryDevice: ${this.name} (${this.vendor})";
  }
}
