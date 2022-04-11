import 'package:cbor/cbor.dart';
import 'package:collection/collection.dart';

import 'cbor.dart';
import 'scope.dart';

enum AifRestMethod {
  GET,
  POST,
  PUT,
  DELETE,
  FETCH,
  PATCH,
  IPATCH,
  DYNAMIC_GET,
  DYNAMIC_POST,
  DYNAMIC_PUT,
  DYNAMIC_DELETE,
  DYNAMIC_FETCH,
  DYNAMIC_PATCH,
  DYNAMIC_IPATCH
}

extension AifMethodBitRepresentation on AifRestMethod {
  static List<AifRestMethod> fromBitRepresentation(BigInt representation) {
    return AifRestMethod.values
        .where((v) => (v.bitRepresentation & representation) != BigInt.zero)
        .toList();
  }

  BigInt get bitRepresentation {
    switch (this) {
      case AifRestMethod.GET:
        return BigInt.one << 0;
      case AifRestMethod.POST:
        return BigInt.one << 1;
      case AifRestMethod.PUT:
        return BigInt.one << 2;
      case AifRestMethod.DELETE:
        return BigInt.one << 3;
      case AifRestMethod.FETCH:
        return BigInt.one << 4;
      case AifRestMethod.PATCH:
        return BigInt.one << 5;
      case AifRestMethod.IPATCH:
        return BigInt.one << 6;
      case AifRestMethod.DYNAMIC_GET:
        return BigInt.one << 32;
      case AifRestMethod.DYNAMIC_POST:
        return BigInt.one << 33;
      case AifRestMethod.DYNAMIC_PUT:
        return BigInt.one << 34;
      case AifRestMethod.DYNAMIC_DELETE:
        return BigInt.one << 35;
      case AifRestMethod.DYNAMIC_FETCH:
        return BigInt.one << 36;
      case AifRestMethod.DYNAMIC_PATCH:
        return BigInt.one << 37;
      case AifRestMethod.DYNAMIC_IPATCH:
        return BigInt.one << 38;
    }
  }
}

class AifScopeElement extends CborSerializable {
  String path;
  List<AifRestMethod> permissions;

  AifScopeElement(this.path, this.permissions);

  AifScopeElement.fromValue(CborList value)
      : this(
      (value.first as CborString).toString(),
      AifMethodBitRepresentation.fromBitRepresentation(
          (value.last as CborInt).toBigInt()));

  @override
  CborValue toCborValue() {
    return CborList([
      CborString(path),
      CborInt(permissions
          .map((e) => e.bitRepresentation)
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
          permissions.equals(other.permissions);

  @override
  int get hashCode => path.hashCode ^ permissions.hashCode;
}

class AifScope extends Scope {

  List<AifScopeElement> elements;

  AifScope(this.elements);

  AifScope.fromValue(CborList value) : this(value.map((e) => AifScopeElement.fromValue(e as CborList)).toList());

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
