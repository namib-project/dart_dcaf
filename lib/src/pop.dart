import 'package:cbor/cbor.dart';
import 'package:dcaf/src/cose/cose_key.dart';

import 'cbor.dart';

abstract class ProofOfPossessionKey extends CborMapSerializable {
  ByteString? get keyId;

  ProofOfPossessionKey();

  factory ProofOfPossessionKey.fromCborMap(Map<int, CborValue> value) {
    final MapEntry<int, CborValue> entry = value.entries.single;
    switch (entry.key) {
      case 1:
        return PlainCoseKey.fromCborMap(
            CborMapSerializable.valueToCborMap(entry.value));
      case 2:
        return EncryptedCoseKey.fromValue(entry.value);
      case 3:
        final value = entry.value;
        if (value is CborBytes) {
          return KeyID.fromValue(value);
        } else {
          throw UnsupportedError("Key ID must consist of CBOR bytestring.");
        }
      default:
        throw UnsupportedError(
            "Unknown ProofOfPossessionKey type '${entry.key}'.");
    }
  }

  factory ProofOfPossessionKey.fromCborValue(CborValue value) {
    return ProofOfPossessionKey.fromCborMap(CborMapSerializable.valueToCborMap(value));
  }
}

class KeyID extends ProofOfPossessionKey {
  @override
  ByteString keyId;

  KeyID(this.keyId);

  @override
  Map<int, CborValue> toCborMap() {
    return {3: CborBytes(keyId)};
  }

  KeyID.fromValue(CborBytes value) : this(value.bytes);

  @override
  String toString() {
    return 'KeyID{keyID: $keyId}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KeyID &&
          runtimeType == other.runtimeType &&
          keyId.nullableEquals(other.keyId);

  @override
  int get hashCode => keyId.hashCode;
}

class PlainCoseKey extends ProofOfPossessionKey {
  CoseKey key;

  PlainCoseKey(this.key);

  @override
  ByteString? get keyId => key.keyId;

  @override
  Map<int, CborValue> toCborMap() {
    return {1: key.toCborValue()};
  }

  PlainCoseKey.fromCborMap(Map<int, CborValue> value)
      : key = CoseKey.fromMap(value);

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
