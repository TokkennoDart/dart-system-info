// Copyright (c) 2017, Minerhub. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

/// Represents a temperature in a instant of time
class TempStatus {
  /// Timestamp of the data
  final DateTime timestamp;

  /// Current temperature in Celsius degrees
  final double current;

  /// Max temperature supported by the device
  final double max;

  /// The temperature from which the device can be damaged
  final double danger;

  TempStatus(this.current, {double max = -1.0, double danger = -1.0})
      : this.max = max,
        this.danger = danger,
        timestamp = new DateTime.now();

  String toString() {
    List<String> margins = [];
    if (this.max != -1) margins.add("max: ${this.max}");
    if (this.danger != -1) margins.add("danger: ${this.danger}");
    return "Temperatute: ${current} Cº" +
        (margins.length > 0 ? " (${margins.join(", ")})" : "");
  }
}
