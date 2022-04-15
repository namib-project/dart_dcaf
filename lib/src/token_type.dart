import 'package:cbor/cbor.dart';
import 'package:dcaf/src/cbor.dart';

enum TokenType with CborIntSerializable {

  Bearer(1),

  ProofOfPossession(2);

  @override
  final int cbor;

  const TokenType(this.cbor);

  static TokenType fromCborValue(CborValue value) {
    final valueInt = CborIntSerializable.valueToInt(value);
    return TokenType.values.singleWhere((e) => e.cbor == valueInt);
  }
}
