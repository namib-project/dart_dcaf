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

/// An operation that a key can be used for, as defined in
/// Table 4 of [section 7.1 of RFC 8152](https://datatracker.ietf.org/doc/html/rfc8152#section-7.1).
///
/// Note that descriptions of the field have been taken from the linked RFC.
enum KeyOperation with CborSerializableEnum {
  /// The key is used to create signatures. Requires private key fields.
  sign(1),

  /// The key is used for verification of signatures.
  verify(2),

  /// The key is used for key transport encryption.
  encrypt(3),

  /// The key is used for key transport decryption.
  /// Requires private key fields.
  decrypt(4),

  /// The key is used for key wrap encryption.
  wrapKey(5),

  /// The key is used for key wrap decryption.
  unwrapKey(6),

  /// The key is used for deriving keys. Requires private key fields.
  deriveKey(7),

  /// The key is used for deriving bits not to be used as a key.
  /// Requires private key fields.
  deriveBits(8),

  /// The key is used for creating MACs.
  macCreate(9),

  /// The key is used for validating MACs.
  macVerify(10);

  @override
  final int cbor;

  /// Creates a new [KeyOperation] instance using the given CBOR value.
  const KeyOperation(this.cbor);

  /// Creates a new [KeyOperation] instance using the given CBOR [value].
  static KeyOperation fromCborValue(CborValue value) {
    final valueInt = CborSerializableEnum.valueToInt(value);
    return KeyOperation.values.singleWhere((e) => e.cbor == valueInt);
  }
}
