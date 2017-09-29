// Copyright (c) 2017, Minerhub. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'device_type.dart';

/// Represents any device in the system
abstract class Device {
  final String _vendorName;
  final String _deviceName;
  final DeviceType _deviceType;

  Device.fromInfo(String name, String vendor, [DeviceType type = DeviceType.Unknown])
      : this._deviceName = name,
        this._vendorName = vendor,
        this._deviceType = type;

  /// Device name.
  String get name => this._deviceName == null ? "" : this._deviceName;

  /// Vendor name.
  String get vendor => this._vendorName == null ? "" : this._vendorName;

  /// Type of device
  DeviceType get type => this._deviceType;

  String toString() {
    return "Device: ${name} (${vendor})";
  }
}
