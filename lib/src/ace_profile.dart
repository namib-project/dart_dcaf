import 'package:cbor/cbor.dart';
import 'package:dcaf/src/cbor.dart';

enum AceProfile with CborIntSerializable {

  CoapDtls(1);

  @override
  final int cbor;

  const AceProfile(this.cbor);

  static AceProfile fromCborValue(CborValue value) {
    final valueInt = CborIntSerializable.valueToInt(value);
    return AceProfile.values.singleWhere((e) => e.cbor == valueInt);
  }
}