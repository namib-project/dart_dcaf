import 'package:cbor/cbor.dart';
import 'package:collection/collection.dart';

typedef ByteString = List<int>;

extension NullableEquals on ByteString? {
  // `identical` also covers this == other == null
  bool nullableEquals(ByteString? other) => identical(this, other)
      || (other != null && this != null && this!.equals(other));
}

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

// We can't really extend another mixin/class here, so we have to implement it.
mixin CborIntSerializable implements CborSerializable {

  int get cbor;

  @override
  CborValue toCborValue() {
      return CborSmallInt(cbor);
  }

  static int valueToInt(CborValue value) {
    if (value is CborSmallInt) {
      return value.toInt();
    } else if (value is CborInt) {
      throw RangeError("Given CBOR integer is too big to be represented in this type.");
    } else {
      throw UnsupportedError("Unsupported CBOR type ${value.runtimeType} (expected CborInt).");
    }
  }

  @override
  List<int> serialize() {
    return cborEncode(toCborValue());
  }
}
