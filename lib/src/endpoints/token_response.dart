import 'dart:math';

import 'package:cbor/cbor.dart';
import 'package:cbor/src/value/value.dart';
import 'package:dcaf/src/ace_profile.dart';
import 'package:dcaf/src/constants/introspection.dart';
import 'package:dcaf/src/constants/token.dart';
import 'package:dcaf/src/pop.dart';
import 'package:dcaf/src/token_type.dart';

import '../cbor.dart';
import '../scope.dart';

class AccessTokenResponse extends CborMapSerializable {
  ByteString accessToken;
  int? expiresIn;
  Scope? scope;
  TokenType? tokenType;
  ByteString? refreshToken;
  AceProfile? aceProfile;
  ProofOfPossessionKey? cnf;
  ProofOfPossessionKey? rsCnf;
  DateTime? issuedAt;

  AccessTokenResponse(
      {required this.accessToken,
      this.expiresIn,
      this.scope,
      this.tokenType,
      this.refreshToken,
      this.aceProfile,
      this.cnf,
      this.rsCnf,
      this.issuedAt});

  static ByteString initializeAccessToken(CborValue? token) {
    if (token == null || token is! CborBytes) {
      throw ArgumentError("Given CBOR map must have access token field!");
    }
    return token.bytes;
  }

  AccessTokenResponse.fromCborMap(Map<int, CborValue> map)
      : accessToken = initializeAccessToken(map[ACCESS_TOKEN]) {
    // TODO: Better error handling
    map.forEach((key, value) {
      switch (key) {
        case ACCESS_TOKEN:
          // We've already handled this required field above.
          break;
        case EXPIRES_IN:
          expiresIn = (value as CborInt).toInt();
          break;
        case ISSUED_AT:
          issuedAt = DateTime.fromMillisecondsSinceEpoch(
              // CBOR will be given in whole seconds
              (value as CborSmallInt).value * 1000,
              isUtc: true);
          break;
        case CNF:
          cnf = ProofOfPossessionKey.fromCborValue(value as CborMap);
          break;
        case SCOPE:
          scope = Scope.fromValue(value);
          break;
        case TOKEN_TYPE:
          tokenType = TokenType.fromCborValue(value);
          break;
        case REFRESH_TOKEN:
          refreshToken = (value as CborBytes).bytes;
          break;
        case ACE_PROFILE:
          aceProfile = AceProfile.fromCborValue(value);
          break;
        case RS_CNF:
          rsCnf = ProofOfPossessionKey.fromCborValue(value);
          break;
        default:
          throw UnsupportedError("CBOR map key $key not supported!");
      }
    });
  }

  @override
  Map<int, CborValue> toCborMap() {
    return {
      ACCESS_TOKEN: CborBytes(accessToken),
      if (expiresIn != null) EXPIRES_IN: CborSmallInt(expiresIn!),
      if (issuedAt != null) ISSUED_AT: CborDateTimeInt(issuedAt!, tags: []),
      if (cnf != null) CNF: cnf!.toCborValue(),
      if (scope != null) SCOPE: scope!.toCborValue(),
      if (tokenType != null) TOKEN_TYPE: tokenType!.toCborValue(),
      if (refreshToken != null) REFRESH_TOKEN: CborBytes(refreshToken!),
      if (aceProfile != null) ACE_PROFILE: aceProfile!.toCborValue(),
      if (rsCnf != null) RS_CNF: rsCnf!.toCborValue(),
    };
  }

  AccessTokenResponse.fromSerialized(List<int> serialized)
      : this.fromCborMap(
            CborMapSerializable.valueToCborMap(cborDecode(serialized)));

  @override
  String toString() {
    return 'AccessTokenResponse{accessToken: $accessToken, expiresIn: $expiresIn, scope: $scope, tokenType: $tokenType, refreshToken: $refreshToken, aceProfile: $aceProfile, cnf: $cnf, rsCnf: $rsCnf, issuedAt: $issuedAt}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccessTokenResponse &&
          runtimeType == other.runtimeType &&
          accessToken.nullableEquals(other.accessToken) &&
          expiresIn == other.expiresIn &&
          scope == other.scope &&
          tokenType == other.tokenType &&
          refreshToken.nullableEquals(other.refreshToken) &&
          aceProfile == other.aceProfile &&
          cnf == other.cnf &&
          rsCnf == other.rsCnf &&
          issuedAt == other.issuedAt;

  @override
  int get hashCode =>
      accessToken.hashCode ^
      expiresIn.hashCode ^
      scope.hashCode ^
      tokenType.hashCode ^
      refreshToken.hashCode ^
      aceProfile.hashCode ^
      cnf.hashCode ^
      rsCnf.hashCode ^
      issuedAt.hashCode;
}
