// Copyright (c) 2017, Minerhub. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:system_info/src/pci/pci_device.dart';
import 'package:system_info/src/pci/pci_device_linux.dart';
import 'dart:async';
import 'dart:io' show Platform, File;
import 'package:system_info/src/pci/database/pci_database.dart' show PciDatabase;
import 'package:binary/binary.dart';

/// Static methods to work with PCI devices.
class PciManager {
  static Future<List<PciDeviceLinux>> _listLinuxDevices() async {
    var procPciDevicesFile = new File("/proc/bus/pci/devices");
    var procPciDevices = await procPciDevicesFile.readAsString();

    List<PciDeviceLinux> devices = new List<PciDeviceLinux>();

    for (var procPciDevice in procPciDevices.split("\n")) {
      if (procPciDevice.length > 0) {
        List<String> pciFields = procPciDevice.split("\t");

        String bus_dev = pciFields[0].trim();
        String vendor_device = pciFields[1].trim();

        int vendorId = int.parse(vendor_device.substring(0, 4), radix: 16);
        int deviceId = int.parse(vendor_device.substring(4, 8), radix: 16);

        String vendorName = await PciDatabase.getVendor(vendorId);
        String deviceName = await PciDatabase.getDevice(vendorId, deviceId);

        int devfn = int.parse(bus_dev.substring(2, 4), radix: 16);

        List<int> busDevBit = uint8.toIterable(devfn).skip(3).toList();
        busDevBit.addAll([0,0,0]);
        int busDev = uint8.fromBits(busDevBit.reversed.toList());

        List<int> busFnBit = uint8.toIterable(devfn).take(3).toList();
        busFnBit.add(0);
        int busFn = uint8.fromBits(busFnBit.reversed.toList());

        PciDeviceLinux dev = new PciDeviceLinux(
          int.parse(bus_dev.substring(0, 2), radix: 16), // Bus id
          busDev,   // Bus dev
          busFn,    // Bus func
          vendorId, // Vendor id
          deviceId, // Device id
          vendorName,
          deviceName
        );

        // Class loader
        devices.add(dev);
      }
    }

    return devices;
  }

  /// List all PCI devices in the host system.
  static Future<List<PciDevice>> listDevices() async {
    if (Platform.isLinux) {
      return PciManager._listLinuxDevices();
    }
    else {
      throw new Exception("This operative system is not supported yet.");
    }
  }
}