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
import 'package:collection/collection.dart';

import '../cbor.dart';
import '../constants/cose_key.dart';
import 'algorithm.dart';
import 'key_operation.dart';
import 'key_type.dart';

/// A COSE Key structure as specified in [RFC 8152, section 7](https://datatracker.ietf.org/doc/html/rfc8152#section-7).
///
/// Note that descriptions of the fields are taken (with slight adjustments)
/// from Table 3 of the linked RFC.
///
/// # Example
/// For example, creating the following key (given in CBOR diagnostic
/// notation)...
/// ```text
/// "COSE_Key" : {
///   "kty" : "Symmetric",
///   "kid" : b64'39Gqlw',
///   "k" : b64'hJtXhkV8FJG+Onbc6mxCcQh'
/// }
/// ```
/// ...would look like this:
/// ```dart
/// final key = CoseKey(
///    keyType: KeyType.symmetric,
///    keyId: [0xDF, 0xD1, 0xAA, 0x97],
///    parameters: {
//       // field "k" (the key itself)
//       -1: CborBytes([ 0x84, 0x9b, 0x57, 0x86, 0x45, 0x7c, 0x14, 0x91, 0xbe,
//       0x3a, 0x76, 0xdc, 0xea, 0x6c, 0x42, 0x71, 0x08])
///    });
/// ```
class CoseKey extends CborMapSerializable {
  /// Identification of the key type.
  ///
  /// This parameter is used to identify the family of keys for this
  /// structure and, thus, the set of key-type-specific parameters to be
  /// found. This parameter MUST be present in a key object.
  /// Implementations MUST verify that the key type is appropriate for
  /// the algorithm being processed.  The key type MUST be included as
  /// part of the trust decision process.
  KeyType keyType;

  /// Key identification value.
  ///
  /// This parameter is used to give an identifier for a key.  The
  /// identifier is not structured and can be anything from a user-
  /// provided string to a value computed on the public portion of the
  /// key.  This field is intended for matching against a 'kid'
  /// parameter in a message in order to filter down the set of keys
  /// that need to be checked.
  ByteString? keyId;

  /// Key usage restriction to this algorithm.
  ///
  /// This parameter is used to restrict the algorithm that is used
  /// with the key.  If this parameter is present in the key structure,
  /// the application MUST verify that this algorithm matches the
  /// algorithm for which the key is being used.  If the algorithms do
  /// not match, then this key object MUST NOT be used to perform the
  /// cryptographic operation.  Note that the same key can be in a
  /// different key structure with a different or no algorithm
  /// specified; however, this is considered to be a poor security
  /// practice.
  Algorithm? algorithm;

  /// Restrict set of permissible operations.
  /// This parameter is defined to restrict the set of operations
  /// that a key is to be used for.  Algorithms define the values of
  /// key ops that are permitted to appear and are required for
  /// specific operations.
  Set<KeyOperation>? keyOperations;

  /// Base IV to be XORed with Partial IVs.
  ///
  /// This parameter is defined to carry the base portion of an
  // IV.  It is designed to be used with the Partial IV header
  // parameter defined in [Section 3.1](https://datatracker.ietf.org/doc/html/rfc8152#section-3.1).
  /// This field provides the ability
  /// to associate a Partial IV with a key that is then modified on a
  /// per message basis with the Partial IV.
  ///
  /// Extreme care needs to be taken when using a Base IV in an
  /// application.  Many encryption algorithms lose security if the same
  /// IV is used twice.
  ByteString? baseIV;

  /// Additional parameters, specified as a map from CBOR labels to CBOR values.
  Map<int, CborValue> parameters = {};

  /// Creates a new [CoseKey] from the given parameters.
  CoseKey(
      {required this.keyType,
      this.keyId,
      this.algorithm,
      this.keyOperations,
      this.baseIV,
      this.parameters = const {}});

  @override
  Map<int, CborValue> toCborMap() {
    return {
      kty: keyType.toCborValue(),
      if (keyId != null) kid: CborBytes(keyId!),
      if (algorithm != null) alg: algorithm!.toCborValue(),
      if (keyOperations != null)
        keyOps: CborList(keyOperations!.map((e) => e.toCborValue()).toList()),
      if (baseIV != null) baseIv: CborBytes(baseIV!),
      for (final parameter in parameters.entries) parameter.key: parameter.value
    };
  }

  static KeyType _initializeKeyType(CborValue? kty) {
    if (kty == null) {
      throw FormatException("Given CBOR map must have kty field!");
    }
    return KeyType.fromCborValue(kty);
  }

  /// Creates a new [CoseKey] from the given [map], which is assumed to be
  /// an object of this type given as a CBOR map from labels to values.
  CoseKey.fromMap(Map<int, CborValue> map)
      : keyType = _initializeKeyType(map[kty]) {
    map.forEach((key, value) {
      switch (key) {
        case kty:
          // We've already set this required field above.
          break;
        case kid:
          keyId = (value as CborBytes).bytes;
          break;
        case alg:
          algorithm = Algorithm.fromCborValue(value);
          break;
        case keyOps:
          keyOperations = (value as CborList)
              .map((e) => KeyOperation.fromCborValue(value))
              .toSet();
          break;
        case baseIv:
          baseIV = (value as CborBytes).bytes;
          break;
        default:
          parameters[key] = value;
      }
    });
  }

  @override
  String toString() {
    return 'CoseKey{keyType: $keyType, keyId: $keyId, algorithm: $algorithm, '
        'keyOperations: $keyOperations, baseIV: $baseIV, '
        'parameters: $parameters}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoseKey &&
          runtimeType == other.runtimeType &&
          keyType == other.keyType &&
          keyId.nullableEquals(other.keyId) &&
          algorithm == other.algorithm &&
          SetEquality<KeyOperation>()
              .equals(keyOperations, other.keyOperations) &&
          baseIV.nullableEquals(other.baseIV) &&
          MapEquality<int, CborValue>().equals(parameters, other.parameters);

  @override
  int get hashCode =>
      keyType.hashCode ^
      keyId.hashCode ^
      algorithm.hashCode ^
      keyOperations.hashCode ^
      baseIV.hashCode ^
      parameters.hashCode;
}
