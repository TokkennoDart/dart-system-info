library system_info;

import 'dart:io' show Platform;
import 'src/cpu_info.dart';
export 'src/cpu_info.dart';

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