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
      return AifScope.fromValue(value);
    }
    // TODO: Proper error types
    throw UnsupportedError("Given CBOR type is unsupported!");
  }
}

class BinaryScope extends Scope {
  ByteString data;

  BinaryScope(ByteString this.data);

  BinaryScope.fromValue(CborBytes value) : this(value.bytes);

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

  TextScope(String this.data);

  TextScope.fromValue(CborString value) : this(value.toString());

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
