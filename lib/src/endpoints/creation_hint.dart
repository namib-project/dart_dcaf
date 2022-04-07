import 'package:cbor/cbor.dart';
import 'package:cbor/src/value/value.dart';
import 'package:dcaf/src/cbor.dart';
import 'package:dcaf/src/constants/creation_hint.dart';
import 'package:collection/collection.dart';

import '../scope.dart';

typedef ByteString = List<int>;

extension on ByteString? {
  // `identical` also covers this == other == null
  bool nullableEquals(ByteString? other) => identical(this, other)
      || (other != null && this != null && this!.equals(other));
}

class AuthServerRequestCreationHint extends CborMapSerializable {
  String? authorizationServer;
  ByteString? keyID;
  String? audience;
  Scope? scope;
  ByteString? clientNonce;

  AuthServerRequestCreationHint.fromSerialized(List<int> serialized)
      : this.fromCborMap(CborMapSerializable.valueToCborMap(cborDecode(serialized)));

  AuthServerRequestCreationHint(this.authorizationServer, this.keyID,
      this.audience, this.scope, this.clientNonce);

  AuthServerRequestCreationHint.fromCborMap(Map<int, CborValue> map) {
    // TODO: Better error handling
    map.forEach((key, value) {
      switch (key) {
        case AS:
          authorizationServer = (value as CborString).toString();
          break;
        case KID:
          keyID = (value as CborBytes).bytes;
          break;
        case AUDIENCE:
          audience = (value as CborString).toString();
          break;
        case SCOPE:
          scope = Scope.fromValue(value);
          break;
        case CNONCE:
          clientNonce = (value as CborBytes).bytes;
          break;
        default:
          throw UnsupportedError("CBOR map key $key not supported!");
      }
    });
  }

  @override
  Map<int, CborValue> toCborMap() {
    return {
      if (authorizationServer != null) AS: CborString(authorizationServer!),
      if (keyID != null) KID: CborBytes(keyID!),
      if (audience != null) AUDIENCE: CborString(audience!),
      if (scope != null) SCOPE: scope!.toCborValue(),
      if (clientNonce != null) CNONCE: CborBytes(clientNonce!)
    };
  }

  @override
  String toString() {
    return 'AuthServerRequestCreationHint{authorizationServer: $authorizationServer, keyID: $keyID, audience: $audience, scope: $scope, clientNonce: $clientNonce}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthServerRequestCreationHint &&
          runtimeType == other.runtimeType &&
          authorizationServer == other.authorizationServer &&
          keyID.nullableEquals(other.keyID) &&
          audience == other.audience &&
          scope == other.scope &&
          clientNonce.nullableEquals(other.clientNonce);

  @override
  int get hashCode =>
      authorizationServer.hashCode ^
      keyID.hashCode ^
      audience.hashCode ^
      scope.hashCode ^
      clientNonce.hashCode;
}
