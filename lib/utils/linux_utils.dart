// Copyright (c) 2017, Minerhub. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:io' show File, Process, ProcessResult;
import 'package:path/path.dart' as path;

/// Define util methods to work in Linux systems.
class LinuxUtils {
  /// Obtains the value of a /sys variable in the [keypath] and return it as String
  static String getSysValue(String keypath) {
    if (keypath.startsWith("/")) keypath = keypath.substring(1);
    File sysfile = new File(path.join("/sys/", keypath));
    if (sysfile.existsSync()) return sysfile.readAsStringSync();
    else return null;
  }

  /// Obtains the value of a /sys variable in the [keypath] and return it as
  /// integer. Can define a [defaultValue] if the return is not an integer, or
  /// can define [radix] to parse de variable if is hexadecimal (or other base).
  static int getSysValueAsInt(String keypath, {int defaultValue = 0, radix: 16}) {
    String value = getSysValue(keypath);
    if (value == null) return defaultValue;
    else return int.parse(value, radix: radix);
  }

  /// Obtains the value of a /sys variable in the [keypath] and return it as
  /// double. Can define a [defaultValue] if the return is not an double.
  static double getSysValueAsDouble(String keypath, {double defaultValue = 0.0}) {
    String value = getSysValue(keypath);
    if (value == null) return defaultValue;
    else return double.parse(value);
  }

  /// Obtains the key: value result of /proc/cpuinfo and format it as a list
  /// of maps.
  static List<Map<String, String>> getProcCpuinfo() {
    List<Map<String, String>> cpuinfo = new List<Map<String, String>>();
    File sysfile = new File("/proc/cpuinfo");

    Map<String, String> currcpu = new Map<String, String>();
    for (var line in sysfile.readAsLinesSync()) {
      if (line.length == 0) {
        if (currcpu.length > 0) cpuinfo.add(currcpu);
        currcpu = new Map<String, String>();
      }
      else if (line.contains(":")) {
        String key = line.split(":")[0].trim();
        currcpu[key] = line.split(":")[1].trim();
      }
    }

    if (currcpu.length > 0) cpuinfo.add(currcpu);

    return cpuinfo;
  }

  /// Run the [command] in the linux shell and returns the stdout output.
  static String sh(String command) {
    return Process.runSync("sh", ["-c", command]).stdout.toString();
  }
}