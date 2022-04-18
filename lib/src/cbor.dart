/*
 * Copyright (c) 2022 The NAMIB Project Developers.
 * Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
 * https://www.apache.org/licenses/LICENSE-2.0> or the MIT license
 * <LICENSE-MIT or https://opensource.org/licenses/MIT>, at your
 * option. This file may not be copied, modified, or distributed
 * except according to those terms.
 *
 * SPDX-License-Identifier: MIT OR Apache-2.0
 */

import 'package:cbor/cbor.dart';
import 'package:collection/collection.dart';

/// A string of bytes, as used in CBOR ([RFC 7049](https://datatracker.ietf.org/doc/html/rfc7049)).
typedef ByteString = List<int>;

/// Allows nullable instances of [ByteString]s to be compared for equality.
extension NullableEquals on ByteString? {
  // `identical` also covers this == other == null
  /// Returns true iff this [ByteString] is equal to the given
  /// [other] [ByteString].
  ///
  /// Specifically, this will return true if either:
  /// - This and the [other] `ByteString?` are identical.
  ///   Note that `identical(null, null)` is true, while no non-`null`
  ///   value is equal to `null`.
  /// - This and the [other] [ByteString] contain exactly the same bytes.
  bool nullableEquals(ByteString? other) =>
      identical(this, other) ||
      (other != null && this != null && this!.equals(other));
}

/// Abstract class intended for data structures which are serializable to CBOR.
abstract class CborSerializable {
  /// Serializes this instance to a [CborValue].
  CborValue toCborValue();

  /// Serializes this instance into CBOR, returning the resulting bytes.
  List<int> serialize() {
    final CborValue value = toCborValue();
    return cborEncode(value);
  }
}

/// Abstract class intended for data structures which are serializable
/// to CBOR maps.
abstract class CborMapSerializable extends CborSerializable {
  /// Serializes this instance to a [Map] from CBOR labels to [CborValue]s.
  Map<int, CborValue> toCborMap();

  @override
  CborValue toCborValue() {
    return CborMap({
      for (var element in toCborMap().entries)
        CborSmallInt(element.key): element.value
    });
  }

  /// Converts from a given CBOR [value] which is assumed to be a [CborMap]
  /// from [CborInt]s (labels) to [CborValue] into a [Map] from [int]s to
  /// [CborValue]s.
  static Map<int, CborValue> valueToCborMap(CborValue value) {
    // TODO(falko17): Better error handling
    return {
      for (var element in (value as CborMap).entries)
        (element.key as CborSmallInt).value: element.value
    };
  }
}

// We can't really extend another mixin/class here, so we have to implement it.

/// A mixin intended for enums whose members are assignable to CBOR labels
/// (integers).
mixin CborSerializableEnum on Enum implements CborSerializable {
  /// The CBOR label this enum value represents.
  int get cbor;

  @override
  CborValue toCborValue() {
    return CborSmallInt(cbor);
  }

  /// Tries to convert the given CBOR [value] into an [int], which requires
  /// that the given [value] is a [CborSmallInt], i.e., can be losslessly
  /// converted into an [int], otherwise a [FormatException] will be thrown.
  /// A [FormatException] will also be thrown if the given [value] is not a
  /// [CborInt] at all.
  static int valueToInt(CborValue value) {
    if (value is CborSmallInt) {
      return value.toInt();
    } else if (value is CborInt) {
      throw FormatException(
          "Given CBOR integer is too big to be represented in this type.");
    } else {
      throw FormatException(
          "Unsupported CBOR type ${value.runtimeType} (expected CborInt).",
          value);
    }
  }

  @override
  List<int> serialize() {
    return cborEncode(toCborValue());
  }
}
