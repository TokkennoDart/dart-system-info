// Copyright (c) 2017, Minerhub. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

/// The type of the PCI device
enum PciDeviceType {
  GPU,
  Audio,
  StorageController,
  Network,
  USB,
  Unknown
}