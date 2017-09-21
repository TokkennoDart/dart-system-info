// Copyright (c) 2017, Minerhub. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:size_type/size_type.dart';

class CpuCache {
  final Size L1;
  final Size L2;
  final Size L3;

  const CpuCache({this.L1 = const Size(), this.L2 = const Size(), this.L3 = const Size()});

  String toString() {
    return "L1(d+i): ${this.L1}, L2: ${this.L2}, L3: ${this.L3}";
  }
}