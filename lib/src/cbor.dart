import 'package:cbor/cbor.dart';

abstract class CborSerializable {
  CborValue toCborValue();

  List<int> serialize() {
    final CborValue value = toCborValue();
    return cborEncode(value);
  }
}

abstract class CborMapSerializable extends CborSerializable {

  Map<int, CborValue> toCborMap();

  @override
  CborValue toCborValue() {
    return CborMap({
      for (var element in toCborMap().entries)
        CborSmallInt(element.key): element.value
    });
  }

  static Map<int, CborValue> valueToCborMap(CborValue value) {
    // TODO: Better error handling
    return {
      for (var element in (value as CborMap).entries)
        (element.key as CborSmallInt).value: element.value
    };
  }
}
