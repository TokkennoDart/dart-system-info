// Copyright (c) 2017, Minerhub. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'package:meta/meta.dart';
import 'package:system_info/src/common/device.dart';
import 'package:system_info/src/common/device_type.dart';

/// Represent a PCI device in the host system.
abstract class PciDevice extends Device {
  /// Type of device as string.
  final String pciTypeName = "";

  PciDevice.fromInfo(String name, String vendor,
      {DeviceType pciType = DeviceType.PCI_Unknown, String pciTypeName = ""})
      : super.fromInfo(name, vendor, pciType) {}

  // OS dependant information
  @protected
  Map<String, String> pciOS = new Map<String, String>();

  /// Reset the device.
  /// Warning: Incompatible with some operative system. Handle the exception
  /// properly in all cases.
  Future reset() async {
    throw new Exception("reset() is not supported for this device");
  }

  String toString() {
    return "PciDevice: ${this.name} (${this.vendor})";
  }
}
