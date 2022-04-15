import 'dart:collection';

import 'package:cbor/cbor.dart';
import 'package:collection/collection.dart';

import 'cbor.dart';
import 'scope.dart';

/// **Important: This type won't be (de)serialized correctly if
/// the "dynamic" REST methods are used when you're on the Web platform!**
enum AifRestMethod with CborIntSerializable {
  get(1 << 0),
  post(1 << 1),
  put(1 << 2),
  delete(1 << 3),
  fetch(1 << 4),
  patch(1 << 5),
  ipatch(1 << 6),
  dynamicGet(1 << 32),
  dynamicPost(1 << 33),
  dynamicPut(1 << 34),
  dynamicDelete(1 << 35),
  dynamicFetch(1 << 36),
  dynamicPatch(1 << 37),
  dynamicIpatch(1 << 38);

  @override
  final int cbor;

  const AifRestMethod(this.cbor);

  static Iterable<AifRestMethod> fromCborValue(CborValue value) {
    final int cborInt = CborIntSerializable.valueToInt(value);
    return AifRestMethod.values.where((e) => (e.cbor & cborInt) != 0);
  }
}

class AifScopeElement extends CborSerializable {
  String path;
  HashSet<AifRestMethod> permissions;

  AifScopeElement(this.path, Iterable<AifRestMethod> permissions)
      : permissions = HashSet.from(permissions);

  AifScopeElement.fromValue(CborList value)
      : this((value.first as CborString).toString(), AifRestMethod.fromCborValue(value.last));

  @override
  CborValue toCborValue() {
    return CborList([
      CborString(path),
      CborSmallInt(permissions.isEmpty
          ? 0
          : permissions
              .map((e) => e.cbor)
              .reduce((value, element) => value | element))
    ]);
  }

  @override
  String toString() {
    return 'AifScopeElement{path: $path, permissions: $permissions}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AifScopeElement &&
          runtimeType == other.runtimeType &&
          path == other.path &&
          SetEquality<AifRestMethod>().equals(permissions, other.permissions);

  @override
  int get hashCode => path.hashCode ^ permissions.hashCode;
}

class AifScope extends Scope {
  List<AifScopeElement> elements;

  AifScope(this.elements);

  AifScope.fromValue(CborList value)
      : this(value
            .map((e) => AifScopeElement.fromValue(e as CborList))
            .toList());

  @override
  CborValue toCborValue() {
    return CborList.of(elements.map((e) => e.toCborValue()));
  }

  @override
  String toString() {
    return 'AifScope{elements: $elements}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AifScope &&
          runtimeType == other.runtimeType &&
          elements.equals(other.elements);

  @override
  int get hashCode => elements.hashCode;
}

class LibdcafScope extends Scope {
  AifScopeElement element;

  LibdcafScope(this.element);

  LibdcafScope.fromValue(CborList value)
      : this(AifScopeElement.fromValue(value));

  @override
  CborValue toCborValue() {
    return element.toCborValue();
  }

  @override
  String toString() {
    return 'LibdcafScope{element: $element}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibdcafScope &&
          runtimeType == other.runtimeType &&
          element == other.element;

  @override
  int get hashCode => element.hashCode;
}
