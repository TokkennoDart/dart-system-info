// Copyright (c) 2017, Minerhub. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

/// Abstraction layer over pci_utils to handle GPU devices
library system_info;

export 'package:system_info/src/common/status/fan_status.dart';
export 'package:system_info/src/common/status/temp_status.dart';
export 'package:system_info/src/cpu/cpu_device.dart';
export 'package:system_info/src/gpu/gpu_device.dart';

import 'dart:async';
import 'package:system_info/src/cpu/cpu_device.dart';
import 'package:system_info/src/cpu/cpu_manager.dart';
import 'package:system_info/src/gpu/gpu_device.dart';
import 'package:system_info/src/gpu/gpu_manager.dart';

/// Allows obtain system information of various subsystems.
/// It works in lazy mode (Only load information when is requested the first time).
class SystemInfo {
  /// Obtains technical information about the system processor
  static Future<List<CpuDevice>> get CPUs async { return CpuManager.listCpus(); }
  /// Obtains technical information about the system gpus
  static Future<List<GpuDevice>> get GPUs async { return GpuManager.listGpus(); }
}