// Copyright (c) 2017, Minerhub. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:pci_utils/src/pci/database/pci_database_subsystem.dart';

class PciDatabaseDevice {
  int _deviceId = 0;
  String _deviceName;
  Map<int, PciDatabaseSubsystem> _ssystems = new Map<int, PciDatabaseSubsystem>();


  PciDatabaseDevice(int dId, String dName) {
    this._deviceId = dId;
    this._deviceName = dName;
  }

  int get DeviceId => this._deviceId;
  String get Name => this._deviceName;

  void add(PciDatabaseSubsystem ss) { this._ssystems[ss.SubvendorId] = ss; }
}