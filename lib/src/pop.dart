import 'package:cbor/cbor.dart';
import 'package:dcaf/src/cose/cose_key.dart';

import 'cbor.dart';
import 'endpoints/token_request.dart';
import 'endpoints/token_response.dart';

/// A proof-of-possession key as specified by
/// [RFC 8747, section 3.1](https://datatracker.ietf.org/doc/html/rfc8747#section-3.1).
///
/// Can either be a [PlainCoseKey], an [EncryptedCoseKey] (note that
/// this is not yet fully supported), or simply a [KeyId].
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
  factory ProofOfPossessionKey.fromCborMap(Map<int, CborValue> map) {
    final MapEntry<int, CborValue> entry = map.entries.single;
    switch (entry.key) {
      case 1:
        return PlainCoseKey.fromCborMap(
            CborMapSerializable.valueToCborMap(entry.value));
      case 2:
        return EncryptedCoseKey.fromValue(entry.value);
      case 3:
        final value = entry.value;
        if (value is CborBytes) {
          return KeyId.fromValue(value);
        } else {
          throw UnsupportedError("Key ID must consist of CBOR bytestring.");
        }
      default:
        throw UnsupportedError(
            "Unknown ProofOfPossessionKey type '${entry.key}'.");
    }
  }

  /// Creates a new [ProofOfPossessionKey] from the given CBOR [value].
  factory ProofOfPossessionKey.fromCborValue(CborValue value) {
    return ProofOfPossessionKey.fromCborMap(
        CborMapSerializable.valueToCborMap(value));
  }
}

/// Key ID of the actual proof-of-possession key.
///
/// Note that as described in [section 6 of RFC 8747](https://datatracker.ietf.org/doc/html/rfc8747#section-6),
/// certain caveats apply when choosing to represent a
/// [ProofOfPossessionKey] by its Key ID.
///
/// For details, see [section 3.4 of RFC 8747](https://datatracker.ietf.org/doc/html/rfc8747#section-3.4).
class KeyId extends ProofOfPossessionKey {
  @override
  ByteString keyId;

  /// Creates a new [KeyId] instance.
  KeyId(this.keyId) : super._();

  @override
  Map<int, CborValue> toCborMap() {
    return {3: CborBytes(keyId)};
  }

  /// Creates a new [KeyId] instance from the given CBOR [bytes].
  KeyId.fromValue(CborBytes bytes) : this(bytes.bytes);

  @override
  String toString() {
    return 'KeyID{keyID: $keyId}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KeyId &&
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
  PlainCoseKey.fromCborMap(Map<int, CborValue> map)
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

class EncryptedCoseKey extends ProofOfPossessionKey {
  @override
  // TODO: implement keyId
  ByteString? get keyId => throw UnimplementedError();

  @override
  Map<int, CborValue> toCborMap() {
    // TODO: implement toCborMap
    throw UnimplementedError();
  }

  EncryptedCoseKey.fromValue(CborValue value) {
    throw UnimplementedError();
  }
}
