// Copyright (c) 2017, Minerhub. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library system_info;

import 'dart:io' show Platform;
import 'package:system_info/cpu/cpu_info.dart';
export 'package:system_info/cpu/cpu_info.dart';

class SystemInfo {
  static CpuInfo _cpuInfo = null;

  static CpuInfo get CPU {
    if (_cpuInfo == null) {
      if (Platform.isLinux) _cpuInfo = new CpuInfo.loadLinux();
      else throw new Exception("The library system_info don't implements CPU module on this platform.");
    }

    return _cpuInfo;
  }
}