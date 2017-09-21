// Copyright (c) 2017, Minerhub. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library system_info;

import 'dart:io' show Platform;
import 'package:system_info/cpu/cpu_info.dart';
export 'package:system_info/cpu/cpu_info.dart';

/// Allows obtain system information of various subsystems.
/// It works in lazy mode (Only load information when is requested the first time).
class SystemInfo {
  static CpuInfo _cpuInfo = null;

  /// Obtains technical information about the system processor
  static CpuInfo get CPU {
    if (_cpuInfo == null) {
      if (Platform.isLinux) _cpuInfo = new CpuInfo.loadLinux();
      else throw new Exception("The library system_info don't implements CPU module on this platform.");
    }

    return _cpuInfo;
  }
}