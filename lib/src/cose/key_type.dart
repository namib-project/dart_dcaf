/*
 * Copyright (c) 2022 The NAMIB Project Developers.
 * Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
 * https://www.apache.org/licenses/LICENSE-2.0> or the MIT license
 * <LICENSE-MIT or https://opensource.org/licenses/MIT>, at your
 * option. This file may not be copied, modified, or distributed
 * except according to those terms.
 *
 * SPDX-License-Identifier: MIT OR Apache-2.0
 */

import 'package:cbor/cbor.dart';
import '../cbor.dart';

/// Denotes a family of keys.
enum KeyType with CborSerializableEnum {
  /// Octet Key Pair.
  okp(1),

  /// Elliptic Curve Keys with x- and y-coordinate pair.
  ec2(2),

  /// RSA Key.
  rsa(3),

  /// Symmetric Key.
  symmetric(4),

  /// Public key for HSS/LMS hash-based digital signature.
  hssLms(5),

  /// WalnutDSA public key.
  walnutDsa(6);

  /// Creates a new [KeyType] instance using the given CBOR value.
  const KeyType(this.cbor);

  @override
  final int cbor;

  /// Creates a new [KeyType] instance using the given CBOR [value].
  static KeyType fromCborValue(CborValue value) {
    final valueInt = CborSerializableEnum.valueToInt(value);
    return KeyType.values.singleWhere((e) => e.cbor == valueInt);
  }
}
