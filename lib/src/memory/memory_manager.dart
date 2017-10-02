// Copyright (c) 2017, Minerhub. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'memory_device.dart';
import 'package:size_type/size_type.dart';
import 'package:system_info/src/utils/linux_utils.dart';
import 'dart:async';
import 'dart:io';

class MemoryManager {
  static Future<List<MemoryDevice>> _listMemoriesLinux() async {
    const String dmicommand =
        "dmidecode -t memory | grep -iE 'Memory Device|\tSize:|\tType:|\tSpeed:|\tManufacturer:|\tForm Factor:|\tBank Locator:|\tPart Number:|\tConfigured Clock Speed:'";

    List<MemoryDevice> memDevices = [];

    Size size = const Size(0);
    int location = -1;
    String type = "";
    String manufacturer = "";
    String model = "";
    String formfactor = "";
    double freq = 0.0;
    double maxFreq = 0.0;

    for (String line in LinuxUtils.sh(dmicommand, asUser: "root").split("\n")) {
      if (line.contains("Memory Device")) {
        if (size > const Size(0)) {
          memDevices.add(new MemoryDevice.fromInfo(model, manufacturer,
              size: size,
              formFactor: formfactor,
              bank: location,
              memoryType: type,
              freq: freq,
              maxFreq: maxFreq));

          size = const Size(0);
          location = -1;
          type = "";
          manufacturer = "";
          model = "";
          formfactor = "";
          freq = 0.0;
          maxFreq = 0.0;
        }
      }
      if (line.contains("Size:") && !line.contains("No Module")) size = Size.parse(line.split(":")[1].trim());
      if (line.contains("Form Factor:")) formfactor = line.split(":")[1].trim().toLowerCase();
      if (line.contains("Type:")) type = line.split(":")[1].trim().toLowerCase();
      if (line.contains("Manufacturer:")) manufacturer = line.split(":")[1].trim();
      if (line.contains("Part Number:")) model = line.split(":")[1].trim();
      if (line.contains("Bank Locator:")) location = int.parse(line.split(":")[1].trim().substring(4));
    }

    if (size > const Size(0)) {
      memDevices.add(new MemoryDevice.fromInfo(model, manufacturer,
          size: size,
          formFactor: formfactor,
          bank: location,
          memoryType: type,
          freq: freq,
          maxFreq: maxFreq));
    }

    return memDevices;
  }

  /// List all PCI devices in the host system.
  static Future<List<MemoryDevice>> listMemories() async {
    if (Platform.isLinux) {
      return MemoryManager._listMemoriesLinux();
    } else
      throw new Exception("This operative system is not supported yet.");
  }
}
