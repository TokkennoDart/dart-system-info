import 'package:size_type/size_type.dart';
import 'package:system_info/src/cpu/cpu_device.dart';
import 'package:system_info/src/cpu/cpu_flag.dart';
import 'package:system_info/src/cpu/cpu_cache.dart';
import 'package:system_info/src/cpu/cpu_endianness.dart';
import 'package:system_info/src/cpu/cpu_architecture.dart';
import 'package:system_info/src/utils/linux_utils.dart';
import 'dart:io' show Platform, Process;
import 'dart:convert';

class CpuManager {
  /// Load the processor information of the current machine processor if the
  /// operative system is Linux.
  ///
  /// Dependencies:
  /// - arch
  ///
  /// TODO: Improve for multi-architecture processor, multiple processor and SoCs
  static List<CpuDevice> _listCpusLinux() {
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
      new CpuDevice.fromInfo(
          vendor: vendor,
          model: model,
          modelId: modelId,
          familyId: familyId,
          steppingId: steppingId,
          maxFrequency: frequency,
          minFrequency: minFrequency,
          cores: cores,
          threads: threads,
          architecture: arch,
          endianness: endian,
          cache: cache,
          cpuFlags: flags)
    ];
  }

  static List<CpuDevice> _listCpusWindows() {
    String wmiout = Process.runSync("wmic", "cpu get name, description, revision, l2cachesize, l3cachesize, manufacturer, currentclockspeed, maxclockspeed /value".split(" ")).stdout;

    String vendor = "Unknown";
    String model = "Generic CPU";
    int l2cache = 0;
    int l3cache = 0;
    int minFreq = 0;
    int maxFreq = 0;

    for (String line in wmiout.split("\r\n")) {
      if (line.contains("CurrentClockSpeed")) minFreq = int.parse(line.split("=")[1].trim());
      if (line.contains("MaxClockSpeed")) maxFreq = int.parse(line.split("=")[1].trim());
      if (line.contains("L2CacheSize")) l2cache = int.parse(line.split("=")[1].trim()) * 1000;
      if (line.contains("L3CacheSize")) l3cache = int.parse(line.split("=")[1].trim()) * 1000;
      if (line.contains("Name")) model = line.split("=")[1].trim();
      if (line.contains("Manufacturer")) vendor = line.split("=")[1].trim();
    }



    return [
      new CpuDevice.fromInfo(
          vendor: vendor,
          model: model,
          maxFrequency: maxFreq,
          minFrequency: minFreq,
          cache: new CpuCache(L2: new Size(l2cache), L3: new Size(l3cache)))
    ];
  }

  static List<CpuDevice> _cpuInfo = null;

  /// Load the processor information of the current machine processor
  static List<CpuDevice> listCpus() {
    if (CpuManager._cpuInfo == null) {
      if (Platform.isLinux)
        _cpuInfo = CpuManager._listCpusLinux();
      else if (Platform.isWindows)
        _cpuInfo = CpuManager._listCpusWindows();
      else
        throw new Exception(
            "The library system_info don't implements CPU module on this platform.");
    }

    return CpuManager._cpuInfo;
  }
}