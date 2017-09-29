/// Specific PCI device for Linux OS, with some specific methods and properties.
/// Note: Usually you will only have to work with PciDevice abstraction.

import 'dart:async';
import 'dart:io' show File;
import 'package:system_info/src/pci/pci_device.dart';
import 'package:system_info/src/common/device_type.dart';

class PciDeviceLinux extends PciDevice {
  PciDeviceLinux.fromInfo(String name, String vendor, int bus, int dev, int fn,
      int vendorId, int deviceId,
      {DeviceType pciType = DeviceType.PCI_Unknown, String pciTypeName = ""})
      : super.fromInfo(name, vendor, pciType: pciType, pciTypeName: pciTypeName) {
    this.pciOS["bus"] = bus.toString();
    this.pciOS["dev"] = dev.toString();
    this.pciOS["fn"] = fn.toString();
    this.pciOS["vendorId"] = vendorId.toString();
    this.pciOS["deviceId"] = deviceId.toString();
  }

  Future reset() async {
    File classFile = new File(getLinuxSysPath(this) + "reset");
    if (classFile.existsSync())
      classFile.writeAsBytesSync([1]);
    else
      throw new Exception("This device don't support reset");
  }

  /// The id of the device inside pci bus as Linux representation.
  static String getLinuxBus(PciDevice lpci) {
    int dev = int.parse(lpci.pciOS["dev"]);
    int fn = int.parse(lpci.pciOS["fn"]);
    return "${lpci.pciOS["bus"].toString().padLeft(2, '0')}:${dev.toRadixString(16)
        .padLeft(2, '0')}.${fn.toRadixString(16)}";
  }

  static String getLinuxSysPath(PciDevice lpci) {
    return "/sys/bus/pci/devices/0000:${getLinuxBus(lpci)}/";
  }
}
