// Copyright (c) 2017, Minerhub. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart';

/// Represents any device in the system
abstract class Device {
  @protected
  String vendorName;

  @protected
  String deviceName;

  /// Device name.
  String get name => this.deviceName == null ? "" : this.deviceName;

  /// Vendor name.
  String get vendor => this.vendorName == null ? "" : this.vendorName;

  String toString() {
    return "Device: ${name} (${vendor})";
  }
}