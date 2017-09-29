// Copyright (c) 2017, Minerhub. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

class PciDatabaseSubsystem {
  int _subdeviceId = 0;
  int _subvendorId = 0;
  String _subsystemName;

  PciDatabaseSubsystem(int dId, int vId, String ssName) {
    this._subdeviceId = dId;
    this._subvendorId = vId;
    this._subsystemName = ssName;
  }

  int get SubdeviceId => this._subdeviceId;
  int get SubvendorId => this._subvendorId;
  String get Name => this._subsystemName;
}