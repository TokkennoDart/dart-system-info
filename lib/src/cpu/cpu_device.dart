// Copyright (c) 2017, Minerhub. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:system_info/src/common/device.dart';
import 'cpu_architecture.dart';
import 'cpu_cache.dart';
import 'cpu_endianness.dart';
import 'cpu_flag.dart';

/// Contains information about a processor
class CpuDevice extends Device {
  int _modelId;
  int _familyId;
  int _steppingId;

  int _frequency = 0; // In Hz
  int _minFrequency = 0; // In Hz

  int _cores = 1;
  int _threads = 1;

  CpuArchitecture _arch;
  CpuEndianness _endian;

  CpuCache _cache = new CpuCache();

  List<CpuFlag> _flags;

  CpuDevice(
      {String vendor,
      String model,
      int modelId,
      int familyId,
      int steppingId,
      int frequency = 0,
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
        this._frequency = frequency,
        this._minFrequency = minFrequency,
        this._cores = cores,
        this._threads = threads,
        this._arch = architecture,
        this._endian = endianness,
        this._cache = cache,
        this._flags = cpuFlags,
        super() {
    this.vendorName = vendor;
    this.deviceName = model;
  }

  int get ModelId => this._modelId;

  int get FamilyId => this._familyId;

  int get SteppingId => this._steppingId;

  int get Frequency => this._frequency;

  int get MinFrequency => this._minFrequency;

  int get Cores => this._cores;

  int get Threads => this._threads;

  CpuArchitecture get Architecture => this._arch;

  CpuEndianness get Endianness => this._endian;

  CpuCache get Cache => this._cache;

  List<CpuFlag> get Flags => new List.from(this._flags);

  String toString() {
    return "${this.deviceName} (model: ${this._modelId}, family: ${this._familyId}, stepping: ${this._steppingId})";
  }
}
