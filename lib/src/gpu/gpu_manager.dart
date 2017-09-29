// Copyright (c) 2017, Minerhub. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:system_info/pci_utils.dart';
import 'package:system_info/src/gpu/gpu_device.dart';
import 'package:system_info/src/gpu/gpu_device_linux.dart';
import 'dart:async';
import 'dart:io' show Platform;

/// Alternative of PciManager that handle only the system GPUs
class GpuManager {
  /// Get a list with GPUs in the system
  static Future<List<GpuDevice>> listGpus() async {
    List<GpuDevice> gpus = [];

    for (PciDevice device in await PciManager.listDevices()) {
      if (device.pciType == PciDeviceType.GPU) {
        if (Platform.isLinux) gpus.add(new GpuDeviceLinux.fromPci(device));
        else gpus.add(new GpuDevice.fromPci(device));
      }
    }

    return gpus;
  }
}