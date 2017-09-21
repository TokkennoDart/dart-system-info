// Copyright (c) 2017, Minerhub. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:size_type/size_type.dart';
import 'package:report/report.dart';

import 'package:system_info/utils/linux_utils.dart';
import 'package:system_info/cpu/cpu_architecture.dart';
import 'package:system_info/cpu/cpu_cache.dart';
import 'package:system_info/cpu/cpu_endianness.dart';

// TODO: Improve for multi-architecture processor, multiple processor and SoCs
@Report(title: "CPU Information")
class CpuInfo {
  String _vendor;
  String _model;

  int _modelId;
  int _familyId;
  int _steppingId;

  int _frequency = 0; // In Hz
  int _minFrequency = 0; // In Hz

  int _cores = 1;
  int _threads = 1;

  CpuArchitecture _arch = null;
  CpuEndianness _endian = null;

  CpuCache _cache = new CpuCache();

  CpuInfo.loadLinux() {
    List<Map<String, String>> cpuinfo = LinuxUtils.getProcCpuinfo();

    this._vendor = cpuinfo.first["vendor_id"];
    this._model = cpuinfo.first["model name"];

    this._modelId = int.parse(cpuinfo.first["model"]);
    this._familyId = int.parse(cpuinfo.first["cpu family"]);
    this._steppingId = int.parse(cpuinfo.first["stepping"]);

    this._frequency = LinuxUtils.getSysValueAsInt("/bus/cpu/devices/cpu0/cpufreq/cpuinfo_max_freq", radix: 10, defaultValue: 0);
    this._minFrequency = LinuxUtils.getSysValueAsInt("/bus/cpu/devices/cpu0/cpufreq/cpuinfo_min_freq", radix: 10, defaultValue: 0);

    List<String> cores = [];
    for (Map<String, String> threadinfo in cpuinfo) {
      String coreid = threadinfo["physical id"].trim() + "_" + threadinfo["core id"].trim();
      if (!cores.contains(coreid)) cores.add(coreid); // Recheck for hyper threading. Same core id on multiple threads.
    }
    this._cores = cores.length;
    this._threads = cpuinfo.length;

    Size l1 = Size.parse(LinuxUtils.getSysValue("/bus/cpu/devices/cpu0/cache/index0/size")) +
        Size.parse(LinuxUtils.getSysValue("/bus/cpu/devices/cpu0/cache/index1/size"));
    Size l2 = Size.parse(cpuinfo.first["cache size"]);
    Size l3 = Size.parse(LinuxUtils.getSysValue("/bus/cpu/devices/cpu0/cache/index3/size"));
    this._cache = new CpuCache(L1: l1, L2: l2, L3: l3);


    this._endian = int.parse(LinuxUtils.sh("echo -n I | od -to2 | head -n1 | cut -f2 -d\" \" | cut -c6")) == 1 ? CpuEndianness.Little : CpuEndianness.Big;

    switch(LinuxUtils.sh("arch").trim().toLowerCase()) {
      case "x86_64": case "sun4":
      this._arch = CpuArchitecture.amd64; break;
      case "alpha":
      this._arch = CpuArchitecture.alpha; break;
      case "sparc":
      this._arch = CpuArchitecture.sparc; break;
      case "arm":
      this._arch = CpuArchitecture.arm; break;
      case "m68k":
      this._arch = CpuArchitecture.m68k; break;
      case "mips":
      this._arch = CpuArchitecture.mips; break;
      case "ppc":
      this._arch = CpuArchitecture.powerpc; break;
      case "i386": case "i486": case "i586":
      this._arch = CpuArchitecture.x86; break;
      default: break;
    }
  }

  @ReportProperty("Vendor")
  String get Vendor => this._vendor;

  @ReportProperty("Model")
  String get Model => this._model;

  @ReportProperty("Model ID")
  int get ModelId => this._modelId;

  @ReportProperty("Family ID")
  int get FamilyId => this._familyId;

  @ReportProperty("Stepping ID")
  int get SteppingId => this._steppingId;

  @ReportProperty("Max. Frecuency", suffix: " Hz")
  int get Frequency => this._frequency;

  @ReportProperty("Min. Frecuency", suffix: " Hz")
  int get MinFrequency => this._minFrequency;

  @ReportProperty("Cores")
  int get Cores => this._cores;

  @ReportProperty("Threads")
  int get Threads => this._threads;

  @ReportProperty("Architecture")
  CpuArchitecture get Architecture => this._arch;

  @ReportProperty("Endianness")
  CpuEndianness get Endianness => this._endian;

  @ReportProperty("Cache")
  CpuCache get Cache => this._cache;

  String toString() {
    return "${this.Model} (model: ${this._modelId}, family: ${this._familyId}, stepping: ${this._steppingId})";
  }
}