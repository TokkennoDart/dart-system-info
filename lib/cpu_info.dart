// Copyright (c) 2017, Minerhub. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:size_type/size_type.dart';
import 'package:report/report.dart';
import 'dart:io' show Platform;

import 'package:system_info/utils/linux_utils.dart';
import 'package:system_info/cpu/cpu.dart';
import 'package:system_info/cpu/cpu_architecture.dart';
import 'package:system_info/cpu/cpu_cache.dart';
import 'package:system_info/cpu/cpu_endianness.dart';
import 'package:system_info/cpu/cpu_flag.dart';

/// Contains information about a processor
@Report(title: "CPU Information")
class CpuInfo {
  /// Load the processor information of the current machine processor if the
  /// operative system is Linux.
  ///
  /// Dependencies:
  /// - arch
  ///
  /// TODO: Improve for multi-architecture processor, multiple processor and SoCs
  static List<Cpu> _getInfoLinux() {
    List<Map<String, String>> cpuinfo = LinuxUtils.getProcCpuinfo();

    String vendor = cpuinfo.first["vendor_id"];
    String model = cpuinfo.first["model name"];

    int modelId = int.parse(cpuinfo.first["model"]);
    int familyId = int.parse(cpuinfo.first["cpu family"]);
    int steppingId = int.parse(cpuinfo.first["stepping"]);

    int frequency = LinuxUtils.getSysValueAsInt(
        "/bus/cpu/devices/cpu0/cpufreq/cpuinfo_max_freq",
        radix: 10,
        defaultValue: 0);
    int minFrequency = LinuxUtils.getSysValueAsInt(
        "/bus/cpu/devices/cpu0/cpufreq/cpuinfo_min_freq",
        radix: 10,
        defaultValue: 0);

    List<String> coreslist = [];
    for (Map<String, String> threadinfo in cpuinfo) {
      String coreid =
          threadinfo["physical id"].trim() + "_" + threadinfo["core id"].trim();

      // Recheck for hyper threading. Same core id on multiple threads.
      if (!coreslist.contains(coreid))
        coreslist.add(coreid);
    }

    int cores = coreslist.length;
    int threads = cpuinfo.length;

    Size l1 = Size.parse(
            LinuxUtils.getSysValue("/bus/cpu/devices/cpu0/cache/index0/size")) +
        Size.parse(
            LinuxUtils.getSysValue("/bus/cpu/devices/cpu0/cache/index1/size"));
    Size l2 = Size.parse(cpuinfo.first["cache size"]);
    Size l3 = Size.parse(
        LinuxUtils.getSysValue("/bus/cpu/devices/cpu0/cache/index3/size"));
    CpuCache cache = new CpuCache(L1: l1, L2: l2, L3: l3);

    CpuEndianness endian = int.parse(LinuxUtils.sh(
                "echo -n I | od -to2 | head -n1 | cut -f2 -d\" \" | cut -c6")) == 1
        ? CpuEndianness.Little
        : CpuEndianness.Big;

    CpuArchitecture arch;
    switch (LinuxUtils.sh("arch").trim().toLowerCase()) {
      case "x86_64":
      case "sun4":
        arch = CpuArchitecture.amd64;
        break;
      case "alpha":
        arch = CpuArchitecture.alpha;
        break;
      case "sparc":
        arch = CpuArchitecture.sparc;
        break;
      case "arm":
        arch = CpuArchitecture.arm;
        break;
      case "m68k":
        arch = CpuArchitecture.m68k;
        break;
      case "mips":
        arch = CpuArchitecture.mips;
        break;
      case "ppc":
        arch = CpuArchitecture.powerpc;
        break;
      case "i386":
      case "i486":
      case "i586":
        arch = CpuArchitecture.x86;
        break;
      default:
        break;
    }

    List<CpuFlag> flags = [];
    List<String> rawFlags = cpuinfo.first["flags"].trim().split(" ");

    for (String flag in rawFlags) {
      if (CpuFlag.Common.containsKey(flag)) {
        flags.add(new CpuFlag(flag, CpuFlag.Common[flag]));
      }
    }

    return [
      new Cpu(
          vendor: vendor,
          model: model,
          modelId: modelId,
          familyId: familyId,
          steppingId: steppingId,
          frequency: frequency,
          minFrequency: minFrequency,
          cores: cores,
          threads: threads,
          architecture: arch,
          endianness: endian,
          cache: cache,
          cpuFlags: flags)
    ];
  }

  static List<Cpu> _cpuInfo = null;

  /// Load the processor information of the current machine processor
  static List<Cpu> getInfo() {
    if (CpuInfo._cpuInfo == null) {
      if (Platform.isLinux)
        _cpuInfo = CpuInfo._getInfoLinux();
      else
        throw new Exception(
            "The library system_info don't implements CPU module on this platform.");
    }

    return CpuInfo._cpuInfo;
  }

  static CpuInfo _getStatusLinux(Cpu cpu) {
    throw new Exception("Not implementated yet");
  }

  /// Load the current status of the selected [cpu].
  static CpuInfo getStatus(Cpu cpu) {
    if (Platform.isLinux)
      return CpuInfo._getStatusLinux(cpu);
    else
      throw new Exception(
          "The library system_info don't implements CPU module on this platform.");
  }
}
