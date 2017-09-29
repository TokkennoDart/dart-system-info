// Copyright (c) 2017, Minerhub. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:system_info/pci_utils.dart';
import 'package:system_info/src/common/status/fan_status.dart';
import 'package:system_info/src/common/status/temp_status.dart';
import 'dart:async';
import 'dart:developer';
import 'package:tuple/tuple.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:system_info/src/gpu/gpu_device.dart';
import 'package:system_info/src/pci/pci_device_linux.dart';

class GpuDeviceLinux extends GpuDevice {
  /// Tuple with monitor path / max temperature / panic temperature
  List<Tuple3<String, double, double>> _temperatures = null;

  /// List with fan monitor path / pwr fan path / pwr min / pwr max
  List<Tuple4<String, String, int, int>> _fans = null;

  GpuDeviceLinux.fromPci(PciDevice pci) : super.fromPci(pci);

  Future _initTemperatures() async {
    _temperatures = [];
    Directory sysdir = new Directory("${PciDeviceLinux.getLinuxSysPath(this)}hwmon");

    List contents = sysdir.listSync();
    for (var fileOrDir in contents) {
      if (fileOrDir is Directory) {
        for (int itemp = 1; itemp < 10; itemp++) {
          Future<String> critTemp = null;
          Future<String> crithysTemp = null;

          File mon = new File(
              path.join(fileOrDir.absolute.path, "temp${itemp}_input"));

          if (mon.existsSync()) {
            File monCrit = new File(
                path.join(fileOrDir.absolute.path, "/temp${itemp}_crit"));
            if (monCrit.existsSync()) {
              critTemp = monCrit.readAsString();
            }

            File monCritHys = new File(
                path.join(fileOrDir.absolute.path, "/temp${itemp}_crit_hyst"));
            if (monCritHys.existsSync()) {
              crithysTemp = monCritHys.readAsString();
            }

            double critTempParse =
                critTemp != null ? double.parse(await critTemp) / 1000.0 : -1.0;
            double crithysTempParse = crithysTemp != null
                ? double.parse(await crithysTemp) / 1000.0
                : -1.0;

            _temperatures.add(new Tuple3<String, double, double>(
                mon.absolute.path,
                critTempParse == 0 ? -1 : (critTempParse),
                crithysTempParse == 0 ? -1 : (crithysTempParse)));
          } else
            break;
        }
      }
    }
  }

  Future<List<TempStatus>> getTemperatures() async {
    if (_temperatures == null) await _initTemperatures();

    List<TempStatus> temps = [];
    for (Tuple3<String, double, double> mon in _temperatures) {
      File monFile = new File(mon.item1);
      double current = double.parse(monFile.readAsStringSync()) / 1000.0;
      temps.add(new TempStatus(current, max: mon.item2, danger: mon.item3));
    }

    return temps;
  }

  Future<List<int>> getPowers() async {
    log("Power monitor is not supported in this system",
        level: 50, zone: Zone.current);
    return [];
  }

  Future _initFans() async {
    _fans = [];
    Directory sysdir = new Directory("${PciDeviceLinux.getLinuxSysPath(this as PciDevice)}hwmon");

    List contents = sysdir.listSync();
    for (var fileOrDir in contents) {
      if (fileOrDir is Directory) {
        for (int itemp = 1; itemp < 10; itemp++) {
          File mon =
              new File(path.join(fileOrDir.absolute.path, "fan${itemp}_input"));

          if (mon.existsSync()) {
            File pwr =
                new File(path.join(fileOrDir.absolute.path, "pwm${itemp}"));

            if (pwr.existsSync()) {
              File pwr_min = new File(
                  path.join(fileOrDir.absolute.path, "pwm${itemp}_min"));
              File pwr_max = new File(
                  path.join(fileOrDir.absolute.path, "pwm${itemp}_max"));
              _fans.add(new Tuple4(
                  mon.absolute.path,
                  pwr.absolute.path,
                  int.parse(pwr_min.readAsStringSync()),
                  int.parse(pwr_max.readAsStringSync())));
            }
            else {
              print(pwr.absolute);
              _fans.add(new Tuple4(mon.absolute.path, null, 0, 0));
            }
          } else
            break;
        }
      }
    }
  }

  Future<List<FanStatus>> getFans() async {
    if (_fans == null) await _initFans();

    List<FanStatus> fans = [];

    for (Tuple4<String, String, int, int> fanMon in _fans) {
      File mon = new File(fanMon.item1);
      Future<String> rpm = mon.readAsString();

      File mon2 = new File(fanMon.item2);
      double pwr = (double.parse(mon2.readAsStringSync()) - fanMon.item3) * 100 / (fanMon.item4 - fanMon.item3);

      fans.add(new FanStatus(pwr, int.parse(await rpm), pwr != 0.0));
    }

    return fans;
  }

  Future _setFanRpm(String fanPath, double pwr) {
    File mon = new File(fanPath);
    mon.writeAsStringSync(pwr.toInt().toString());
  }

  Future setFan(double pwr, [int index = -1]) {
    if (index == -1) {
      for (Tuple4<String, String, int, int> fan in _fans) {
        _setFanRpm(
            fan.item2, (pwr * (fan.item4 - fan.item3) / 100) + fan.item3);
      }
    } else {
      if (_fans.length <= index - 1) {
        Tuple4<String, String, int, int> fan = _fans[index];
        _setFanRpm(
            fan.item2, (pwr * (fan.item4 - fan.item3) / 100) + fan.item3);
      } else
        throw new Exception("Fan index don't exists");
    }
  }

  Future setFanAuto([int index = -1]) async {
    if (index == -1) {
      for (Tuple4<String, String, int, int> fan in _fans) {
        File mon = new File("${fan.item2}_enable");
        mon.writeAsStringSync(2.toString());
      }
    } else {
      if (_fans.length <= index - 1) {
        File mon = new File("${_fans[index].item2}_enable");
        mon.writeAsStringSync(2.toString());
      } else
        throw new Exception("Fan index don't exists");
    }
  }
}
