// Copyright (c) 2017, Minerhub. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library system_info;

import 'package:system_info/cpu/cpu.dart';
import 'package:system_info/cpu_info.dart';
export 'package:system_info/cpu_info.dart';

/// Allows obtain system information of various subsystems.
/// It works in lazy mode (Only load information when is requested the first time).
class SystemInfo {
  /// Obtains technical information about the system processor
  static List<Cpu> get CPU { return CpuInfo.getInfo(); }
}