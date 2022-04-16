import 'dart:convert';

import 'package:cbor/cbor.dart';
import 'package:cbor/src/value/value.dart';
import 'package:dcaf/src/aif.dart';
import 'package:dcaf/src/cbor.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'endpoints/creation_hint.dart';

abstract class Scope extends CborSerializable {
  Scope();

  factory Scope.fromValue(CborValue value) {
    if (value is CborString) {
      return TextScope.fromValue(value);
    } else if (value is CborBytes) {
      return BinaryScope.fromValue(value);
    } else if (value is CborList) {
      if (value.first is CborString) {
        // Special handling for libdcaf.
        return LibdcafScope.fromValue(value);
      } else {
        return AifScope.fromValue(value);
      }
    }
    // TODO: Proper error types
    throw UnsupportedError("Given CBOR type is unsupported!");
  }
}

class BinaryScope extends Scope {
  ByteString data;

  BinaryScope(this.data) {
    if (data.isEmpty) {
      throw ArgumentError("Scope must not be empty!");
    }
  }

  BinaryScope.fromValue(CborBytes value) : this(value.bytes);

  List<ByteString> elements(int? separator) {
    if (separator == null) {
      return [data];
    } else if (data.firstOrNull == separator) {
      throw ArgumentError("Scope must not start with separator!");
    } else if (data.lastOrNull == separator) {
      throw ArgumentError("Scope must not end with separator!");
    } else if (IterableZip([data, data.skip(1)]).any((element) =>
        element.firstOrNull == separator && separator == element.lastOrNull)) {
      throw ArgumentError("Scope must not contain two consecutive separators!");
    }
    final result = data.splitBefore((element) => element == separator);
    // For every element except the first, we need to remove the separator,
    // which is the first respective element of a slice.
    return result
        .take(1)
        .followedBy(result.skip(1).map((e) => e.skip(1).toList()))
        .toList();
  }

  @override
  CborValue toCborValue() {
    return CborBytes(data);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BinaryScope &&
          runtimeType == other.runtimeType &&
          data.equals(other.data);

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() {
    return 'BinaryScope{data: $data}';
  }
}

class TextScope extends Scope {
  String data;

  TextScope(this.data) {
    if (data.isEmpty) {
      throw ArgumentError("Scope must not be empty!");
    } else if (data.endsWith(" ")) {
      throw ArgumentError("Scope must not end with separator (space)!");
    } else if (data.startsWith(" ")) {
      throw ArgumentError("Scope must not start with separator (space)!");
    } else if (data.contains(RegExp(r'(?:"|\\)'))) {
      throw ArgumentError("Scope must not contain illegal characters!");
    } else if (data.contains("  ")) {
      throw ArgumentError("Scope must not contain two consecutive separators!");
    }
  }

  TextScope.fromValue(CborString value) : this(value.toString());

  List<String> get elements => data.split(' ');

  @override
  CborValue toCborValue() {
    return CborString(data);
  }

  @override
  String toString() {
    return 'TextScope{data: $data}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextScope &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;
}
