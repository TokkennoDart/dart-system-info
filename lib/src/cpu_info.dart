import 'package:size_type/size_type.dart';
import 'utils/linux_utils.dart';

import 'package:report/report.dart';

class CpuCache {
  Size _l1 = new Size();
  Size _l2 = new Size();
  Size _l3 = new Size();

  Size get L1 => this._l1;
  Size get L2 => this._l2;
  Size get L3 => this._l3;

  Map<String, Size> get Caches {
    return {
      "L1": this._l1,
      "L2": this._l2,
      "L3": this._l3
    };
  }

  String toString() {
    return "L1(d+i): ${this.L1}, L2: ${this.L2}, L3: ${this.L3}";
  }
}

enum InstSetType {
  CISC,
  RISC
}

enum EndiannessType {
  Big,
  Little
}

class CpuArchitecture {
  final String Name;
  final String CodeName;

  final InstSetType InstructionSetType;

  const CpuArchitecture(this.Name, this.CodeName, [ this.InstructionSetType = InstSetType.CISC ]);

  String toString() => this.CodeName;

  static const CpuArchitecture alpha = const CpuArchitecture("Alpha", "alpha", InstSetType.RISC);
  static const CpuArchitecture amd64 = const CpuArchitecture("AMD64", "amd64", InstSetType.CISC);
  static const CpuArchitecture arm = const CpuArchitecture("ARM", "arm", InstSetType.RISC);
  static const CpuArchitecture armel = const CpuArchitecture("Armel", "armel", InstSetType.RISC);
  static const CpuArchitecture armhf = const CpuArchitecture("ARM Hard Float", "armhf", InstSetType.RISC);
  static const CpuArchitecture arm64 = const CpuArchitecture("ARM Arch64", "aarch64", InstSetType.RISC);
  static const CpuArchitecture ia64 = const CpuArchitecture("Intel Itanium", "ia64", InstSetType.CISC);
  static const CpuArchitecture m68k = const CpuArchitecture("Motorola 68000 series", "m68k", InstSetType.CISC);
  static const CpuArchitecture mips = const CpuArchitecture("MIPS", "mips", InstSetType.RISC);
  static const CpuArchitecture mipsel = const CpuArchitecture("MIPS Little Endian", "mipsel", InstSetType.RISC);
  static const CpuArchitecture openrisc = const CpuArchitecture("OpenRISC", "openrisc", InstSetType.RISC);
  static const CpuArchitecture power = const CpuArchitecture("POWER", "power", InstSetType.RISC);
  static const CpuArchitecture powerpc = const CpuArchitecture("PowerPC", "ppc", InstSetType.RISC);
  static const CpuArchitecture ppc64 = const CpuArchitecture("PowerPC 64", "ppc64", InstSetType.RISC);
  static const CpuArchitecture ppc64le = const CpuArchitecture("PowerPC 64 Little Endian", "ppc64le", InstSetType.RISC);
  static const CpuArchitecture s390x = const CpuArchitecture("IBM Z System/390", "s390x", InstSetType.CISC);
  static const CpuArchitecture sparc = const CpuArchitecture("Sparc", "sparc", InstSetType.RISC);
  static const CpuArchitecture sparc64 = const CpuArchitecture("Sparc64", "sparc64", InstSetType.RISC);
  static const CpuArchitecture superh = const CpuArchitecture("Super H", "superh", InstSetType.RISC);
  static const CpuArchitecture x86 = const CpuArchitecture("Intel x86", "x86", InstSetType.CISC);
}

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

  CpuCache _cache = new CpuCache();

  CpuInfo.loadLinux() {
    var cpuinfo = LinuxUtils.getProcCpuinfo();

    this._vendor = cpuinfo.first["vendor_id"];
    this._model = cpuinfo.first["model name"];

    this._modelId = int.parse(cpuinfo.first["model"]);
    this._familyId = int.parse(cpuinfo.first["cpu family"]);
    this._steppingId = int.parse(cpuinfo.first["stepping"]);

    this._frequency = LinuxUtils.getSysValueAsInt("/bus/cpu/devices/cpu0/cpufreq/cpuinfo_max_freq", radix: 10, defaultValue: 0);
    this._minFrequency = LinuxUtils.getSysValueAsInt("/bus/cpu/devices/cpu0/cpufreq/cpuinfo_min_freq", radix: 10, defaultValue: 0);

    this._cores = int.parse(cpuinfo.first["cpu cores"]);
    this._threads = cpuinfo.length;

    this._cache._l1 = Size.parse(LinuxUtils.getSysValue("/bus/cpu/devices/cpu0/cache/index0/size")) +
        Size.parse(LinuxUtils.getSysValue("/bus/cpu/devices/cpu0/cache/index1/size"));
    this._cache._l2 = Size.parse(cpuinfo.first["cache size"]);
    this._cache._l3 = Size.parse(LinuxUtils.getSysValue("/bus/cpu/devices/cpu0/cache/index3/size"));

    // TODO: parsear el endianes y la arch
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

  @ReportProperty("Cache")
  CpuCache get Cache => this._cache;

  String toString() {
    return "${this.Model} (model: ${this._modelId}, family: ${this._familyId}, stepping: ${this._steppingId})";
  }
}