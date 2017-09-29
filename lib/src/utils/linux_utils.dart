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
    if (sysfile.existsSync())
      return sysfile.readAsStringSync();
    else
      return null;
  }

  /// Obtains the value of a /sys variable in the [keypath] and return it as
  /// integer. Can define a [defaultValue] if the return is not an integer, or
  /// can define [radix] to parse de variable if is hexadecimal (or other base).
  static int getSysValueAsInt(String keypath,
      {int defaultValue = 0, radix: 16}) {
    String value = getSysValue(keypath);
    if (value == null)
      return defaultValue;
    else
      return int.parse(value, radix: radix);
  }

  /// Obtains the value of a /sys variable in the [keypath] and return it as
  /// double. Can define a [defaultValue] if the return is not an double.
  static double getSysValueAsDouble(String keypath,
      {double defaultValue = 0.0}) {
    String value = getSysValue(keypath);
    if (value == null)
      return defaultValue;
    else
      return double.parse(value);
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
      } else if (line.contains(":")) {
        String key = line.split(":")[0].trim();
        currcpu[key] = line.split(":")[1].trim();
      }
    }

    if (currcpu.length > 0) cpuinfo.add(currcpu);

    return cpuinfo;
  }

  /// Run the [command] in the linux shell and returns the stdout output.
  static String sh(String command, {String asUser = null}) {
    List<String> commandParts = ["sh", "-c", command];

    if (asUser != null) {
      if (LinuxUtils.userExists(asUser)) {
        if (LinuxUtils.programExists("pkexec")) commandParts.insertAll(0, ["pkexec", "--user", asUser]);
        else throw new Exception("System-info don't have the capability of execute the command as the user ${asUser} in this system.");
      }
      else throw new Exception("User ${asUser} doesn't exist in the system");
    }

    return Process.runSync(commandParts.first, commandParts.skip(1).toList()).stdout.toString();
  }

  /// Check if the [program] exists and is
  static bool programExists(String program) {
    return int.parse(sh("if hash ${program} 2>/dev/null; then"
                " echo \"1\";"
                " else echo \"0\";"
                " fi")) == 1
        ? true
        : false;
  }
  
  static bool userExists(String user) {
    return int.parse(sh("if id -u ${user} >/dev/null 2>/dev/null; then"
        " echo \"1\";"
        " else echo \"0\";"
        " fi")) == 1
        ? true
        : false;
  }
}
