// Copyright (c) 2017, Minerhub. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:pci_utils/src/pci/database/pci_database_device.dart';
import 'package:pci_utils/src/pci/database/pci_database_subsystem.dart';

class PciDatabaseVendor {
  int _vendorId = 0;
  String _vendorName = "";
  Map<int, PciDatabaseDevice> _devices = new Map<int, PciDatabaseDevice>();

  PciDatabaseVendor(int dId, String dName) {
    this._vendorId = dId;
    this._vendorName = dName;
  }

  int get DeviceId => this._vendorId;
  String get Name => this._vendorName;

  void add(PciDatabaseDevice dd) { this._devices[dd.DeviceId] = dd; }
  bool contains(int deviceId) { return this._devices.containsKey(deviceId); }
  PciDatabaseDevice getDevice(int deviceId) { return this._devices[deviceId]; }
}