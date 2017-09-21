// Copyright (c) 2017, Minerhub. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:report/report.dart';

import 'package:system_info/cpu/cpu_architecture.dart';
import 'package:system_info/cpu/cpu_cache.dart';
import 'package:system_info/cpu/cpu_endianness.dart';
import 'package:system_info/cpu/cpu_status.dart';

/// Contains information about a processor
@Report(title: "CPU Information")
class Cpu {
  String _vendor;
  String _model;

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

  Cpu(
      {String vendor,
      String model,
      int modelId,
      int familyId,
      int steppingId,
      int frequency = 0,
      int minFrequency = 0,
      int cores = 1,
      threads = 1,
      architecture = null,
      endianness = null,
      cache})
      : this._vendor = vendor,
        this._model = model,
        this._modelId = modelId,
        this._familyId = familyId,
        this._steppingId = steppingId,
        this._frequency = frequency,
        this._minFrequency = minFrequency,
        this._cores = cores,
        this._threads = threads,
        this._arch = architecture,
        this._endian = endianness,
        this._cache = cache;

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

  CpuStatus status() { }

  String toString() {
    return "${this.Model} (model: ${this._modelId}, family: ${this._familyId}, stepping: ${this._steppingId})";
  }
}
