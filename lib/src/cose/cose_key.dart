import 'package:cbor/cbor.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../cbor.dart';
import '../constants/cose_key.dart';
import 'algorithm.dart';
import 'key_operation.dart';
import 'key_type.dart';

class CoseKey extends CborMapSerializable {
  KeyType keyType;
  ByteString? keyId;
  Algorithm? algorithm;
  Set<KeyOperation>? keyOperations;
  ByteString? baseIV;
  Map<int, CborValue> parameters = {};

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
      KTY: keyType.toCborValue(),
      if (keyId != null) KID: CborBytes(keyId!),
      if (algorithm != null) ALG: algorithm!.toCborValue(),
      if (keyOperations != null)
        KEY_OPS: CborList(keyOperations!.map((e) => e.toCborValue()).toList()),
      if (baseIV != null) BASE_IV: CborBytes(baseIV!),
      for (final parameter in parameters.entries) parameter.key: parameter.value
    };
  }

  static KeyType initializeKeyType(CborValue? kty) {
    if (kty == null) {
      throw ArgumentError("Given CBOR map must have kty field!");
    }
    return KeyType.fromCborValue(kty);
  }

  CoseKey.fromMap(Map<int, CborValue> map)
      : keyType = initializeKeyType(map[KTY]) {
    map.forEach((key, value) {
      switch (key) {
        case KTY:
          // We've already set this required field above.
          break;
        case KID:
          keyId = (value as CborBytes).bytes;
          break;
        case ALG:
          algorithm = Algorithm.fromCborValue(value);
          break;
        case KEY_OPS:
          keyOperations = (value as CborList)
              .map((e) => KeyOperation.fromCborValue(value))
              .toSet();
          break;
        case BASE_IV:
          baseIV = (value as CborBytes).bytes;
          break;
        default:
          parameters[key] = value;
      }
    });
  }

  @override
  String toString() {
    return 'CoseKey{keyType: $keyType, keyId: $keyId, algorithm: $algorithm, keyOperations: $keyOperations, baseIV: $baseIV, parameters: $parameters}';
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
