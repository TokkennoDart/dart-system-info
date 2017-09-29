// Copyright (c) 2017, Minerhub. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:system_info/pci_utils.dart';
import 'package:system_info/src/common/device_type.dart';
import 'package:system_info/src/common/status/fan_status.dart';
import 'package:system_info/src/common/status/temp_status.dart';
import 'dart:async';
import 'dart:developer';

/// Represents a system GPU
class GpuDevice extends PciDevice {
  GpuDevice.fromPci(PciDevice pci)
      : super.fromInfo(pci.name, pci.vendor, pciType: pci.type, pciTypeName: pci.pciTypeName) {
    this.pciOS = pci.pciOS;
    if (pci.type != DeviceType.GPU) throw new Exception("This pci don't is a GPU");
  }

  /// Obtains the driver version
  Future<String> getDriverVersion() async {
    return "";
  }

  /// Obtains an array of temperatures with the tuple current_temperature <=> max_temperature for all sensors of the GPU
  Future<List<TempStatus>> getTemperatures() async {
    log("Temperature monitor is not supported in this system",
        level: 50, zone: Zone.current);
    return [];
  }

  /// Obtains an array of temperatures with the tuple current_temperature <=> max_temperature for all sensors of the GPU
  Future<List<FanStatus>> getFans() async {
    log("Fan monitor is not supported in this system",
        level: 50, zone: Zone.current);
    return [];
  }

  /// Set the fan power to [pwr]%. Can select a concrete fan with the [index] param.
  Future setFan(double pwr, [int index = -1]) async {
    log("Fan monitor is not supported in this system",
        level: 50, zone: Zone.current);
    return [];
  }

  /// Set the fan power to auto. Can select a concrete fan with the [index] param.
  Future setFanAuto([int index = -1]) async {
    log("Fan monitor is not supported in this system",
        level: 50, zone: Zone.current);
    return [];
  }
}
