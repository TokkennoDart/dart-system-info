// Copyright (c) 2017, Minerhub. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'network_device.dart';
import 'package:system_info/src/utils/linux_utils.dart';
import 'package:system_info/src/pci/pci_device_linux.dart';
import 'package:system_info/src/pci/pci_manager.dart';
import 'dart:async';
import 'dart:io';

class NetworkManager {
  static Future<List<NetworkDevice>> _listLinuxDevices() async {
    List<NetworkInterface> inets = await NetworkInterface.list();
    List<NetworkDevice> devInterfaces = [];

    for (NetworkInterface inet in inets) {
      NetworkDevice current = null;
      String mac = "";

      // Check mac
      String ifconfig = LinuxUtils.sh("ifconfig -a ${inet.name}");
      RegExp macRegex = new RegExp(r"([0-9A-f]{2}:){5}[0-9A-f]{2}");
      List<Match> macs = macRegex.allMatches(ifconfig).toList();
      if (macs.length > 0) mac = macs.first.group(0);

      // Check if is PCI
      String pciBus = null;
      Directory dir = new Directory("/sys/class/net/${inet.name}/device/driver");
      if (dir.existsSync()) {
        for (FileSystemEntity fileOrDir in dir.listSync()) {
          String maskPci = "/0000:";
          if (fileOrDir is Directory && fileOrDir.path.contains(maskPci))
            pciBus = fileOrDir.path.substring(fileOrDir.path.indexOf(maskPci) + maskPci.length);
        }
      }

      // If is a PCI
      if (pciBus != null) {
        for (PciDeviceLinux device in await PciManager.listDevices()) {
          if (PciDeviceLinux.getLinuxBus(device) == pciBus) {
            current = new NetworkDevice.fromPci(device, inet, mac);
          }
        }
      }

      if (current != null) devInterfaces.add(current);
      else devInterfaces.add(new NetworkDevice.fromInfo("Generic Network Device", "Unknown", inet, mac));
    }

    return devInterfaces;
  }

  /// List all PCI devices in the host system.
  static Future<List<NetworkDevice>> listInterfaces() async {
    if (Platform.isLinux) {
      return NetworkManager._listLinuxDevices();
    } else {
      throw new Exception("This operative system is not supported yet.");
    }
  }
}