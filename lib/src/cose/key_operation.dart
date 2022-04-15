import 'package:cbor/cbor.dart';
import 'package:dcaf/src/cbor.dart';

enum KeyOperation with CborIntSerializable {
  sign(1),
  verify(2),
  encrypt(3),
  decrypt(4),
  wrapKey(5),
  unwrapKey(6),
  deriveKey(7),
  deriveBits(8),
  macCreate(9),
  macVerify(10);

  @override
  final int cbor;

  const KeyOperation(this.cbor);

  static KeyOperation fromCborValue(CborValue value) {
    final valueInt = CborIntSerializable.valueToInt(value);
    return KeyOperation.values.singleWhere((e) => e.cbor == valueInt);
  }
}