// Copyright (c) 2017, Minerhub. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io' show File;
import 'package:http/http.dart' as http;

import 'package:system_info/src/pci/database/pci_database_device.dart';
import 'package:system_info/src/pci/database/pci_database_subsystem.dart';
import 'package:system_info/src/pci/database/pci_database_vendor.dart';

/// PCI Database to consult names from device codes.
class PciDatabase {
  static const String _PciDatabaseUrl = "https://raw.githubusercontent.com/pciutils/pciids/master/pci.ids";
  static const String _PciDatabasePath = "./pci.ids";
  static const String _PciDatabaseSystemPath = "/usr/share/hwdata/pci.ids";

  static Map<int, PciDatabaseVendor> _devicesDb = new Map<int, PciDatabaseVendor>();
  static Map<int, String> _classesDb = new Map<int, String>();

  static Future _reload() async {
    _devicesDb.clear();
    _classesDb.clear();

    File idsFile = new File(_PciDatabasePath);

    if (!await idsFile.exists()) {
      idsFile = new File(_PciDatabaseSystemPath);
    }

    if (!await idsFile.exists()) {
      throw new Exception("The database file ${_PciDatabasePath} doesn't exists.");
    }

    String section = "unknown";
    PciDatabaseVendor currentVend;
    PciDatabaseDevice currentDev;

    int classId; String className;
    int subclassId; String subclassName;

    for (String idsLine in await idsFile.readAsLines()) {
      if (idsLine.contains("# Vendors, devices and subsystems")) section = "vedesub";
      else if (idsLine.contains("# List of known device classes")) section = "classes";

      if (!idsLine.startsWith("#")) {
        List<String> idsFields = idsLine.split("\t");

        if (section == "vedesub") {
          // If it is a vendor definition
          if (idsFields.length > 0 && idsFields[0].trim().length > 0) {
            int vendorId = int.parse(
                idsFields[0].substring(0, idsFields[0].indexOf(" ")),
                radix: 16);
            String vendorName = idsFields[0].substring(
                idsFields[0].indexOf(" ")).trim();

            currentVend = new PciDatabaseVendor(vendorId, vendorName);
            currentDev = null;
            _devicesDb[vendorId] = currentVend;
          }
          // If it is a device definition
          else if (idsFields.length > 1 && idsFields[1].trim().length > 0 && currentVend != null) {
            int deviceId = int.parse(
                idsFields[1].substring(0, idsFields[1].indexOf(" ")),
                radix: 16);
            String deviceName = idsFields[1].substring(
                idsFields[1].indexOf(" ")).trim();

            currentDev = new PciDatabaseDevice(deviceId, deviceName);
            currentVend.add(currentDev);
          }
          // If it is a subsystem definition
          else if (idsFields.length > 2 && idsFields[2].trim().length > 0 && currentDev != null) {
            String orih = idsFields[2];

            int svendorId = int.parse(
                idsFields[2].substring(0, idsFields[2].indexOf(" ")),
                radix: 16);

            idsFields[2] = idsFields[2].substring(
                idsFields[2].indexOf(" ")).trim();

            int sdeviceId = int.parse(
                idsFields[2].substring(0, idsFields[2].indexOf(" ")),
                radix: 16);

            String ssName = idsFields[2].substring(
                idsFields[2].indexOf(" ")).trim();

            currentDev.add(new PciDatabaseSubsystem(sdeviceId, svendorId, ssName));
          }
        }
        else if (section == "classes") {
          if (idsLine.startsWith("C")) {
            classId = int.parse(idsLine.substring(2, 4), radix: 16);
            className = idsLine.substring(6).trim();

            int classIdNum = int.parse("${classId.toRadixString(16).padLeft(2, "0")}ffff", radix: 16);
            _classesDb[classIdNum] = className;
          }
          else if (idsLine.split("\t").length == 2) {
            idsLine = idsLine.split("\t")[1].trim();

            subclassId = int.parse(idsLine.substring(0, 2), radix: 16);
            subclassName = idsLine.substring(4).trim();

            int subclassIdNum = int.parse("${classId.toRadixString(16).padLeft(2, "0")}${subclassId.toRadixString(16).padLeft(2, "0")}ff", radix: 16);
            _classesDb[subclassIdNum] = "${className}|${subclassName}";
          }
          else if (idsLine.split("\t").length == 3) {
            idsLine = idsLine.split("\t")[2].trim();

            int piId = int.parse(idsLine.substring(0, 2), radix: 16);
            String piName = idsLine.substring(4).trim();

            int piIdNum = int.parse("${classId.toRadixString(16).padLeft(2, "0")}${subclassId.toRadixString(16).padLeft(2, "0")}${piId.toRadixString(16).padLeft(2, "0")}", radix: 16);
            _classesDb[piIdNum] = "${className}|${subclassName}|${piName}";
          }
        }
      }
    }
  }

  /// Update the PCI device database from Internet.
  static Future update() async {
    var response = await http.get(_PciDatabaseUrl);

    if (response.statusCode == 200) {
      var deviceDbFile = new File("./pci.ids");
      deviceDbFile.writeAsBytes(response.bodyBytes, flush: true);
      _reload();
    }
    else {
      throw new Exception("Can not update the pci.ids device database. Check internet connection.");
    }
  }

  /// Obtains the vendor name from the [vendorId] code.
  static Future<String> getVendor(int vendorId) async {
    if (_devicesDb.length == 0) await _reload();

    if (_devicesDb.containsKey(vendorId)) return _devicesDb[vendorId].Name;

    return "Unknown vendor";
  }

  /// Obtains the device name from the [vendorId] code and the [deviceId] code.
  static Future<String> getDevice(int vendorId, int deviceId) async {
    if (_devicesDb.length == 0) await _reload();

    if (_devicesDb.containsKey(vendorId)) {
      PciDatabaseVendor vendor = _devicesDb[vendorId];
      if (vendor.contains(deviceId)) return vendor.getDevice(deviceId).Name;
    }

    return "Unknown device";
  }

  /// Obtains the device name from the [deviceId] code.
  ///
  /// Note: Use getDevice() if is possible, expend less resources.
  static Future<String> getDeviceById(int deviceId) async {
    if (_devicesDb.length == 0) await _reload();

    for (PciDatabaseVendor vendor in _devicesDb.values) {
      if (vendor.contains(deviceId)) return vendor.getDevice(deviceId).Name;
    }

    return "Unknown device";
  }

  /// Obtains the class description from the [code].
  static String getClass(int code) {

    if (_classesDb.containsKey(code)) {
      String cname = _classesDb[code];
      cname = cname.substring(cname.indexOf("|") + 1);
      return cname.substring(cname.indexOf("|") + 1) + " (" + cname.substring(0, cname.indexOf("|")) + ")";
    }
    else {
      code = int.parse(code.toRadixString(16).padLeft(6).substring(0, 4) + "ff", radix: 16);

      if (_classesDb.containsKey(code)) {
        String cname = _classesDb[code];
        return cname.substring(cname.indexOf("|") + 1) + " (" + cname.substring(0, cname.indexOf("|")) + ")";
      }
      else {
        code = int.parse(code.toRadixString(16).padLeft(6).substring(0, 2) + "ffff", radix: 16);

        if (_classesDb.containsKey(code)) return _classesDb[code];
        else {
          print(code.toRadixString(16)); return "Unassigned class";
        }
      }
    }
  }
}