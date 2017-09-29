// Copyright (c) 2017, Minerhub. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:system_info/src/common/device_type.dart';
import 'package:system_info/src/pci/pci_device.dart';
import 'package:system_info/src/pci/pci_device_linux.dart';
import 'dart:async';
import 'dart:io' show Platform, File;
import 'package:system_info/src/pci/database/pci_database.dart'
    show PciDatabase;
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

        int busId = int.parse(bus_dev.substring(0, 2), radix: 16);
        int devfn = int.parse(bus_dev.substring(2, 4), radix: 16);

        List<int> busDevBit = uint8.toIterable(devfn).skip(3).toList();
        busDevBit.addAll([0, 0, 0]);
        int busDev = uint8.fromBits(busDevBit.reversed.toList());

        List<int> busFnBit = uint8.toIterable(devfn).take(3).toList();
        busFnBit.add(0);
        int busFn = uint8.fromBits(busFnBit.reversed.toList());

        // Consultamos el pciType
        String busName =
            "${busId.toString().padLeft(2, '0')}:${busDev.toRadixString(16)
            .padLeft(2, '0')}.${busFn.toRadixString(16)}";
        DeviceType pciType = DeviceType.PCI_Unknown;
        String pciTypeName = "";
        File classFile = new File("/sys/bus/pci/devices/0000:${busName}/class");
        if (classFile.existsSync()) {
          pciTypeName = PciDatabase.getClass(
              int.parse(classFile.readAsStringSync().substring(2), radix: 16));

          if (pciTypeName.toLowerCase().contains("vga compatible") ||
              pciTypeName.toLowerCase().contains("xga compatible") ||
              pciTypeName.toLowerCase().contains("3d controller") ||
              pciTypeName.toLowerCase().contains("display controller"))
            pciType = DeviceType.GPU;
          else if (pciTypeName.toLowerCase().contains("audio"))
            pciType = DeviceType.Audio;
          else if (pciTypeName.toLowerCase().contains("network controller"))
            pciType = DeviceType.Network;
          else if (pciTypeName.toLowerCase().contains("usb controller"))
            pciType = DeviceType.USB;
          else if (pciTypeName.toLowerCase().contains("mass storage") ||
              pciTypeName.toLowerCase().contains("ata controller") ||
              pciTypeName.toLowerCase().contains("sata controller") ||
              pciTypeName.toLowerCase().contains("scsi controller") ||
              pciTypeName.toLowerCase().contains("non-volatile memory"))
            pciType = DeviceType.StorageController;
        }

        PciDeviceLinux dev = new PciDeviceLinux.fromInfo(
            deviceName,
            vendorName,
            busId, // Bus id
            busDev, // Bus dev
            busFn, // Bus func
            vendorId, // Vendor id
            deviceId, // Device id
            pciType: pciType,
            pciTypeName: pciTypeName);

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
    } else {
      throw new Exception("This operative system is not supported yet.");
    }
  }
}
