// Copyright (c) 2017, Minerhub. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io' show NetworkInterface;
import 'package:system_info/src/pci/pci_device.dart';
import 'package:system_info/src/common/device.dart';
import 'package:system_info/src/common/device_type.dart';

class NetworkDevice extends Device {
  /// Dart interface
  final NetworkInterface interface;
  final String mac;

  NetworkDevice.fromInfo(String name, String vendor,
      NetworkInterface interface, [String mac = ""])
      : this.interface = interface,
        this.mac = mac,
        super.fromInfo(name, vendor, DeviceType.Network);

  NetworkDevice.fromPci(PciDevice pci,
      NetworkInterface interface, [String mac = ""])
      : this.interface = interface,
        this.mac = mac,
        super.fromInfo(pci.name, pci.vendor, DeviceType.Network);
}