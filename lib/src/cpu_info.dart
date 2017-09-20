import 'package:size_type/size_type.dart';
import 'utils/linux_utils.dart';

class CpuCache {
  Size _l1 = new Size();
  Size _l2 = new Size();
  Size _l3 = new Size();

  Map<String, Size> get Caches {
    return {
      "L1": this._l1,
      "L2": this._l2,
      "L3": this._l3
    };
  }
}

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

  CpuCache _cache = new CpuCache();

  CpuInfo.loadLinux() {
    var cpuinfo = LinuxUtils.getProcCpuinfo();

    this._vendor = cpuinfo.first["vendor_id"];
    this._model = cpuinfo.first["model name"];

    this._modelId = int.parse(cpuinfo.first["model"]);
    this._familyId = int.parse(cpuinfo.first["cpu family"]);
    this._steppingId = int.parse(cpuinfo.first["stepping"]);

    this._cache._l2 = Size.parse(cpuinfo.first["cache size"]);
  }

  String get Vendor => this._vendor;
  String get Model => this._model;
}