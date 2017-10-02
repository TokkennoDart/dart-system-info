# system_info

Get system and hardware information.

## Support

- **Linux 2.6+** (Dependencies: ifconfig, dmidecode)
- (Windows support is planned)

## Usage example

- Code:
```dart
  print("CPU Info: ${SystemInfo.CPUs.first.Model} (${SystemInfo.CPUs.first.Vendor})");
```
- Output:
```
CPU Info: AMD FX(tm)-8350 Eight-Core Processor (AuthenticAMD)
```