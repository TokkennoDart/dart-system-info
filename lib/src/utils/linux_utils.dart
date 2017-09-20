import 'dart:io' show File;
import 'package:path/path.dart' as path;

class LinuxUtils {
  static String getSysValue(String keypath) {
    File sysfile = new File(path.join("/sys", keypath));
    if (sysfile.existsSync()) return sysfile.readAsStringSync();
    else return null;
  }

  static int getSysValueAsInt(String keypath, {int defaultValue = 0, radix: 16}) {
    String value = getSysValue(keypath);
    if (value == null) return defaultValue;
    else return int.parse(value, radix: radix);
  }

  static double getSysValueAsDouble(String keypath, {double defaultValue = 0.0}) {
    String value = getSysValue(keypath);
    if (value == null) return defaultValue;
    else return double.parse(value);
  }

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
}