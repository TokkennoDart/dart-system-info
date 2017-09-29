import 'package:pci_utils/src/pci/database/pci_database.dart';
import 'dart:io' show File;
import 'package:test/test.dart';

void main() {
  group('PciDatabase tests', () {
    setUp(() {
    });

    test('Download Test', () async {
      var fileDownloaded = new File("./pci.ids");
      if (await fileDownloaded.exists()) await fileDownloaded.delete();
      await PciDatabase.update();
      expect(await fileDownloaded.exists(), isTrue);
    });
  });
}
