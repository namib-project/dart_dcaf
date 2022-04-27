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

import 'cbor.dart';
import 'cose/cose_key.dart';
import 'endpoints/token_request.dart';
import 'endpoints/token_response.dart';

/// A proof-of-possession key as specified by
/// [RFC 8747, section 3.1](https://datatracker.ietf.org/doc/html/rfc8747#section-3.1).
///
/// Can either be a [PlainCoseKey], an [EncryptedCoseKey] (note that
/// this is not yet fully supported), or simply a [PlainKeyId].
/// As described in [`draft-ietf-ace-oauth-params-16`](https://datatracker.ietf.org/doc/html/draft-ietf-ace-oauth-params-16),
/// PoP keys are used for the `reqCnf` parameter in [AccessTokenRequest]
/// as well as for the `cnf` and `rsCnf` parameters in [AccessTokenResponse].
///
/// # Example
/// We showcase creation of an [AccessTokenRequest] in which we set
/// `reqCnf` to a PoP key with an ID of `0xDCAF` which the access token shall be
/// bound to:
/// ```dart
/// final key = KeyId([0xDC, 0xAF]);
/// final request = AccessTokenRequest(
///    clientId: "test_client",
///    reqCnf: key);
/// ```
abstract class ProofOfPossessionKey extends CborMapSerializable {
  /// The key ID of this PoP key.
  /// Note that the returned key ID may be empty if no
  /// key ID was present in the key.
  ByteString? get keyId;

  ProofOfPossessionKey._();

  /// Creates a new [ProofOfPossessionKey] from the given [map],
  /// which maps from CBOR labels to [CborValue]s.
  factory ProofOfPossessionKey._fromCborMap(Map<int, CborValue> map) {
    final MapEntry<int, CborValue> entry = map.entries.single;
    switch (entry.key) {
      case 1:
        return PlainCoseKey._fromCborMap(
            CborMapSerializable.valueToCborMap(entry.value));
      case 2:
        return EncryptedCoseKey.fromValue(entry.value);
      case 3:
        final value = entry.value;
        if (value is! CborBytes) {
          throw FormatException(
              "Key ID must consist of CBOR bytestring.", value);
        }
        return PlainKeyId.fromValue(value);
      default:
        throw FormatException(
            "Unknown ProofOfPossessionKey type '${entry.key}'.", entry);
    }
  }

  /// Creates a new [ProofOfPossessionKey] from the given CBOR [value].
  factory ProofOfPossessionKey.fromCborValue(CborValue value) {
    return ProofOfPossessionKey._fromCborMap(
        CborMapSerializable.valueToCborMap(value));
  }
}

/// Proof-of-possession key represented by only its Key ID.
///
/// Note that as described in [section 6 of RFC 8747](https://datatracker.ietf.org/doc/html/rfc8747#section-6),
/// certain caveats apply when choosing to represent a
/// [ProofOfPossessionKey] by its Key ID.
///
/// For details, see [section 3.4 of RFC 8747](https://datatracker.ietf.org/doc/html/rfc8747#section-3.4).
class PlainKeyId extends ProofOfPossessionKey {
  @override
  ByteString keyId;

  /// Creates a new [PlainKeyId] instance.
  PlainKeyId(this.keyId) : super._();

  @override
  Map<int, CborValue> toCborMap() {
    return {3: CborBytes(keyId)};
  }

  /// Creates a new [PlainKeyId] instance from the given CBOR [bytes].
  PlainKeyId.fromValue(CborBytes bytes) : this(bytes.bytes);

  @override
  String toString() {
    return 'KeyID{keyID: $keyId}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlainKeyId &&
          runtimeType == other.runtimeType &&
          keyId.nullableEquals(other.keyId);

  @override
  int get hashCode => keyId.hashCode;
}

/// An unencrypted [CoseKey] used to represent an asymmetric public key or
/// (if the CWT it's contained in is encrypted) a symmetric key.
///
/// For details, see [section 3.2 of RFC 8747](https://datatracker.ietf.org/doc/html/rfc8747#section-3.2).
class PlainCoseKey extends ProofOfPossessionKey {
  /// The actual [CoseKey] represented by this class.
  CoseKey key;

  /// Creates a new [PlainCoseKey] instance.
  PlainCoseKey(this.key) : super._();

  @override
  ByteString? get keyId => key.keyId;

  @override
  Map<int, CborValue> toCborMap() {
    return {1: key.toCborValue()};
  }

  /// Creates a new [PlainCoseKey] instance from the given [map] from
  /// CBOR labels to [CborValue]s.
  PlainCoseKey._fromCborMap(Map<int, CborValue> map)
      : this(CoseKey.fromMap(map));

  @override
  String toString() {
    return 'PlainCoseKey{key: $key}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlainCoseKey &&
          runtimeType == other.runtimeType &&
          key == other.key;

  @override
  int get hashCode => key.hashCode;
}

/// An encrypted [CoseKey] used to represent a symmetric key.
///
/// **Note that this class is incomplete and not usable without considerable
/// effort!**
/// All it contains is a [CborValue] it hasn't bothered to decode itself
/// which will contain a `COSE_Encrypt0` or `COSE_Encrypt` structure.
/// If you intend to use this, you will need to decode the [value] contained
/// here yourself.
///
/// For details, see [section 3.3 of RFC 8747](https://datatracker.ietf.org/doc/html/rfc8747#section-3.3).
class EncryptedCoseKey extends ProofOfPossessionKey {
  /// `COSE_Encrypt0` or `COSE_Encrypt` structure containing the [CoseKey].
  CborValue value;

  /// Creates a new [EncryptedCoseKey] instance.
  EncryptedCoseKey(this.value) : super._();

  /// Creates a new [EncryptedCoseKey] instance from the given CBOR [value].
  EncryptedCoseKey.fromValue(CborValue value) : this(value);

  @override
  ByteString? get keyId => throw UnimplementedError();

  @override
  Map<int, CborValue> toCborMap() {
    return {2: value};
  }

  @override
  String toString() {
    return 'EncryptedCoseKey{value: $value}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EncryptedCoseKey &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}
