// Copyright (c) 2017, Minerhub. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:system_info/src/common/device.dart';
import 'package:system_info/src/common/device_type.dart';
import 'cpu_architecture.dart';
import 'cpu_cache.dart';
import 'cpu_endianness.dart';
import 'cpu_flag.dart';

/// Contains information about a processor
class CpuDevice extends Device {
  int _modelId;
  int _familyId;
  int _steppingId;

  int _maxFrequency = 0; // In Hz
  int _minFrequency = 0; // In Hz

  int _cores = 1;
  int _threads = 1;

  CpuArchitecture _arch;
  CpuEndianness _endian;

  CpuCache _cache = new CpuCache();

  List<CpuFlag> _flags;

  CpuDevice.fromInfo(
      {String vendor,
      String model,
      int modelId,
      int familyId,
      int steppingId,
      int maxFrequency = 0,
      int minFrequency = 0,
      int cores = 1,
      int threads = 1,
      CpuArchitecture architecture = null,
      CpuEndianness endianness = null,
      CpuCache cache,
      List<CpuFlag> cpuFlags = const []})
      : this._modelId = modelId,
        this._familyId = familyId,
        this._steppingId = steppingId,
        this._maxFrequency = maxFrequency,
        this._minFrequency = minFrequency,
        this._cores = cores,
        this._threads = threads,
        this._arch = architecture,
        this._endian = endianness,
        this._cache = cache,
        this._flags = cpuFlags,
        super.fromInfo(model, vendor, DeviceType.CPU);

  int get modelId => this._modelId;

  int get familyId => this._familyId;

  int get steppingId => this._steppingId;

  int get maxFrequency => this._maxFrequency;

  int get minFrequency => this._minFrequency;

  int get cores => this._cores;

  int get threads => this._threads;

  CpuArchitecture get architecture => this._arch;

  CpuEndianness get endianness => this._endian;

  CpuCache get cache => this._cache;

  List<CpuFlag> get flags => new List.from(this._flags);

  String toString() {
    return "CpuDevice: ${this.name} (model: ${this.modelId}, family: ${this.familyId}, stepping: ${this.steppingId})";
  }
}
