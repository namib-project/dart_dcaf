import 'dart:mirrors';

import 'package:cbor/cbor.dart';
import 'package:dcaf/src/cbor.dart';
import 'package:dcaf/src/constants/cose_key.dart';

enum KeyType with CborIntSerializable {
  /// This value is reserved.
  reserved(0),

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

  const KeyType(this.cbor);

  @override
  final int cbor;

  static KeyType fromCborValue(CborValue value) {
    final valueInt = CborIntSerializable.valueToInt(value);
    return KeyType.values.singleWhere((e) => e.cbor == valueInt);
  }
}