import 'package:cbor/cbor.dart';
import 'package:dcaf/src/constants/token.dart';
import 'package:dcaf/src/pop.dart';

import '../cbor.dart';
import '../constants/introspection.dart';
import '../grant_type.dart';
import '../scope.dart';

class AccessTokenRequest extends CborMapSerializable {
  String? clientId;
  GrantType? grantType;
  String? audience;
  String? redirectUri;
  ByteString? clientNonce;
  Scope? scope;
  bool includeAceProfile = false;
  ProofOfPossessionKey? reqCnf;
  String? issuer;


  AccessTokenRequest({
      this.clientId,
      this.grantType,
      this.audience,
      this.redirectUri,
      this.clientNonce,
      this.scope,
      this.includeAceProfile = false,
      this.reqCnf,
      this.issuer});

  AccessTokenRequest.fromCborMap(Map<int, CborValue> map) {
    // TODO: Better error handling
    map.forEach((key, value) {
      switch (key) {
        case CLIENT_ID:
          clientId = (value as CborString).toString();
          break;
        case GRANT_TYPE:
          grantType = GrantType.fromCborValue(value);
          break;
        case AUDIENCE:
          audience = (value as CborString).toString();
          break;
        case REDIRECT_URI:
          redirectUri = (value as CborString).toString();
          break;
        case CNONCE:
          clientNonce = (value as CborBytes).bytes;
          break;
        case SCOPE:
          scope = Scope.fromValue(value);
          break;
        case ACE_PROFILE:
          includeAceProfile = true;
          break;
        case REQ_CNF:
          reqCnf = ProofOfPossessionKey.fromCborMap(CborMapSerializable.valueToCborMap(value));
          break;
        case ISSUER:
          issuer = (value as CborString).toString();
          break;
        default:
          throw UnsupportedError("CBOR map key $key not supported!");
      }
    });
  }

  @override
  Map<int, CborValue> toCborMap() {
    return {
      if (issuer != null) ISSUER: CborString(issuer!),
      if (reqCnf != null) REQ_CNF: reqCnf!.toCborValue(),
      if (audience != null) AUDIENCE: CborString(audience!),
      if (scope != null) SCOPE: scope!.toCborValue(),
      if (clientId != null) CLIENT_ID: CborString(clientId!),
      if (redirectUri != null) REDIRECT_URI: CborString(redirectUri!),
      if (grantType != null) GRANT_TYPE: CborSmallInt(grantType!.cbor),
      if (includeAceProfile) ACE_PROFILE: CborNull(),
      if (clientNonce != null) CNONCE: CborBytes(clientNonce!),
    };
  }

  AccessTokenRequest.fromSerialized(List<int> serialized)
      : this.fromCborMap(
      CborMapSerializable.valueToCborMap(cborDecode(serialized)));

  @override
  String toString() {
    return 'AccessTokenRequest{clientId: $clientId, grantType: $grantType, audience: $audience, redirectUri: $redirectUri, clientNonce: $clientNonce, scope: $scope, includeAceProfile: $includeAceProfile, reqCnf: $reqCnf, issuer: $issuer}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccessTokenRequest &&
          runtimeType == other.runtimeType &&
          clientId == other.clientId &&
          grantType == other.grantType &&
          audience == other.audience &&
          redirectUri == other.redirectUri &&
          clientNonce.nullableEquals(other.clientNonce) &&
          scope == other.scope &&
          includeAceProfile == other.includeAceProfile &&
          reqCnf == other.reqCnf &&
          issuer == other.issuer;

  @override
  int get hashCode =>
      clientId.hashCode ^
      grantType.hashCode ^
      audience.hashCode ^
      redirectUri.hashCode ^
      clientNonce.hashCode ^
      scope.hashCode ^
      includeAceProfile.hashCode ^
      reqCnf.hashCode ^
      issuer.hashCode;
}
