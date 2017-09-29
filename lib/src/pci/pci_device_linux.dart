/// Specific PCI device for Linux OS, with some specific methods and properties.
/// Note: Usually you will only have to work with PciDevice abstraction.

import 'dart:async';
import 'dart:io' show File;
import 'package:system_info/src/pci/pci_device.dart';
import 'package:system_info/src/pci/pci_device_type.dart';
import 'package:system_info/src/pci/database/pci_database.dart' show PciDatabase;

class PciDeviceLinux extends PciDevice {
  PciDeviceLinux(int bus, int dev, int fn, int vendor, int device,
      String vendorName, String deviceName) : super() {

    this.pciOS["bus"] = bus.toString();
    this.pciOS["dev"] = dev.toString();
    this.pciOS["fn"] = fn.toString();
    this.pciOS["vendorId"] = vendor.toString();
    this.pciOS["deviceId"] = device.toString();

    this.vendorName = vendorName;
    this.deviceName = deviceName;

    File classFile = new File(getLinuxSysPath(this) + "class");
    if (classFile.existsSync()) {
      this.pciTypeName = PciDatabase.getClass(
          int.parse(classFile.readAsStringSync().substring(2), radix: 16));

      if (this.pciTypeName.toLowerCase().contains("vga compatible") ||
          this.pciTypeName.toLowerCase().contains("xga compatible") ||
          this.pciTypeName.toLowerCase().contains("3d controller") ||
          this.pciTypeName.toLowerCase().contains("display controller"))
        this.pciType = PciDeviceType.GPU;
      else if (this.pciTypeName.toLowerCase().contains("audio"))
        this.pciType = PciDeviceType.Audio;
      else if (this.pciTypeName.toLowerCase().contains("network controller"))
        this.pciType = PciDeviceType.Network;
      else if (this.pciTypeName.toLowerCase().contains("usb controller"))
        this.pciType = PciDeviceType.USB;
      else if (this.pciTypeName.toLowerCase().contains("mass storage") ||
          this.pciTypeName.toLowerCase().contains("ata controller") ||
          this.pciTypeName.toLowerCase().contains("sata controller") ||
          this.pciTypeName.toLowerCase().contains("scsi controller") ||
          this.pciTypeName.toLowerCase().contains("non-volatile memory"))
        this.pciType = PciDeviceType.StorageController;
      // Parse to type
    }
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
