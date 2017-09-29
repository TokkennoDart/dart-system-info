// Copyright (c) 2017, Minerhub. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

/// Represent the fan status in a instant of time
class FanStatus {
  /// Timestamp of the data
  final DateTime timestamp;

  /// The temperature in this instant
  final double current;

  /// The current revolutions per minute
  final int rpm;

  /// True if the fan is power on
  final bool enable;

  FanStatus(this.current, this.rpm, [this.enable = true])
      : timestamp = new DateTime.now();

  String toString() {
    return enable
        ? "Fan: ${current.toStringAsFixed(2)}% (${rpm} rpm)"
        : "Fan: off";
  }
}
