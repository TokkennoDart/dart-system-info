// Copyright (c) 2017, Minerhub. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:system_info/cpu/cpu_iset_type.dart';

class CpuArchitecture {
  final String Name;
  final String CodeName;

  final CpuIsetType InstructionSetType;

  const CpuArchitecture(this.Name, this.CodeName, [ this.InstructionSetType = CpuIsetType.CISC ]);

  String toString() => this.Name;

  static const CpuArchitecture alpha = const CpuArchitecture("Alpha", "alpha", CpuIsetType.RISC);
  static const CpuArchitecture amd64 = const CpuArchitecture("x86-64", "amd64", CpuIsetType.CISC);
  static const CpuArchitecture arm = const CpuArchitecture("ARM", "arm", CpuIsetType.RISC);
  static const CpuArchitecture armel = const CpuArchitecture("Armel", "armel", CpuIsetType.RISC);
  static const CpuArchitecture armhf = const CpuArchitecture("ARM Hard Float", "armhf", CpuIsetType.RISC);
  static const CpuArchitecture arm64 = const CpuArchitecture("ARM Arch64", "aarch64", CpuIsetType.RISC);
  static const CpuArchitecture ia64 = const CpuArchitecture("Intel Itanium", "ia64", CpuIsetType.CISC);
  static const CpuArchitecture m68k = const CpuArchitecture("Motorola 68000 series", "m68k", CpuIsetType.CISC);
  static const CpuArchitecture mips = const CpuArchitecture("MIPS", "mips", CpuIsetType.RISC);
  static const CpuArchitecture mipsel = const CpuArchitecture("MIPS Little Endian", "mipsel", CpuIsetType.RISC);
  static const CpuArchitecture openrisc = const CpuArchitecture("OpenRISC", "openrisc", CpuIsetType.RISC);
  static const CpuArchitecture power = const CpuArchitecture("POWER", "power", CpuIsetType.RISC);
  static const CpuArchitecture powerpc = const CpuArchitecture("PowerPC", "ppc", CpuIsetType.RISC);
  static const CpuArchitecture ppc64 = const CpuArchitecture("PowerPC 64", "ppc64", CpuIsetType.RISC);
  static const CpuArchitecture ppc64le = const CpuArchitecture("PowerPC 64 Little Endian", "ppc64le", CpuIsetType.RISC);
  static const CpuArchitecture s390x = const CpuArchitecture("IBM Z System/390", "s390x", CpuIsetType.CISC);
  static const CpuArchitecture sparc = const CpuArchitecture("Sparc", "sparc", CpuIsetType.RISC);
  static const CpuArchitecture sparc64 = const CpuArchitecture("Sparc64", "sparc64", CpuIsetType.RISC);
  static const CpuArchitecture superh = const CpuArchitecture("Super H", "superh", CpuIsetType.RISC);
  static const CpuArchitecture x86 = const CpuArchitecture("Intel x86", "x86", CpuIsetType.CISC);
}