import 'package:cbor/cbor.dart';

import 'cbor.dart';

abstract class ProofOfPossessionKey extends CborMapSerializable {
  ByteString get keyId;

  ProofOfPossessionKey();

  factory ProofOfPossessionKey.fromCborMap(Map<int, CborValue> value) {
    MapEntry<int, CborValue> entry = value.entries.single;
    switch (entry.key) {
      case 1:
        return PlainCoseKey.fromValue(entry.value);
      case 2:
        return EncryptedCoseKey.fromValue(entry.value);
      case 3:
        var value = entry.value;
        if (value is CborBytes) {
          return KeyID.fromValue(value);
        } else {
          throw UnsupportedError("Key ID must consist of CBOR bytestring.");
        }
      default:
        throw UnsupportedError("Unknown ProofOfPossessionKey type '${entry.key}'.");
    }
  }
}

class KeyID extends ProofOfPossessionKey {

  ByteString keyID;

  @override
  ByteString get keyId => keyID;

  KeyID(this.keyID);

  @override
  Map<int, CborValue> toCborMap() {
    return {3: CborBytes(keyID)};
  }

  KeyID.fromValue(CborBytes value) : this(value.bytes);
}

class PlainCoseKey extends ProofOfPossessionKey {
  @override
  // TODO: implement keyId
  ByteString get keyId => throw UnimplementedError();

  @override
  Map<int, CborValue> toCborMap() {
    // TODO: implement toCborMap
    throw UnimplementedError();
  }

  PlainCoseKey.fromValue(CborValue value) {
    throw UnimplementedError();
  }
}

class EncryptedCoseKey extends ProofOfPossessionKey {
  @override
  // TODO: implement keyId
  ByteString get keyId => throw UnimplementedError();

  @override
  Map<int, CborValue> toCborMap() {
    // TODO: implement toCborMap
    throw UnimplementedError();
  }

  EncryptedCoseKey.fromValue(CborValue value) {
    throw UnimplementedError();
  }
}

