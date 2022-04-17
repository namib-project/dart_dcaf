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
import './token_request.dart';
import '../ace_profile.dart';
import '../cbor.dart';
import '../constants/introspection.dart' as intro_const;
import '../constants/token.dart' as token_const;
import '../pop.dart';
import '../scope.dart';
import '../token_type.dart';

/// Response to an [AccessTokenRequest] containing the Access Token
/// among additional information, as defined in
/// [section 5.8.2 of `draft-ietf-ace-oauth-authz`](https://www.ietf.org/archive/id/draft-ietf-ace-oauth-authz-46.html#section-5.8.2).
///
/// # Example
/// Figure 9 of [`draft-ietf-ace-oauth-authz-46`](https://www.ietf.org/archive/id/draft-ietf-ace-oauth-authz-46.html#figure-9)
/// gives us an example of an access token response,
/// given in CBOR diagnostic notation:
/// ```text
/// {
///   "access_token" : b64'SlAV32hkKG ...
///    (remainder of CWT omitted for brevity;
///    CWT contains COSE_Key in the "cnf" claim)',
///   "ace_profile" : "coap_dtls",
///   "expires_in" : "3600",
///   "cnf" : {
///     "COSE_Key" : {
///       "kty" : "Symmetric",
///       "kid" : b64'39Gqlw',
///       "k" : b64'hJtXhkV8FJG+Onbc6mxCcQh'
///     }
///   }
/// }
/// ```
/// (Note that abbreviations aren't used here, so keep in mind that the
/// labels are really integers instead of strings.)
///
/// This could be built and serialized as an [AccessTokenResponse] like so:
/// ```dart
/// final key = CoseKey(
///    keyType: KeyType.symmetric,
///    keyId: [0xDF, 0xD1, 0xAA, 0x97],
///    parameters: {
//       // field "k" (the key itself)
//       -1: CborBytes([ 0x84, 0x9b, 0x57, 0x86, 0x45, 0x7c, 0x14, 0x91, 0xbe,
//       0x3a, 0x76, 0xdc, 0xea, 0x6c, 0x42, 0x71, 0x08])
///    });
/// final response = AccessTokenResponse(
///    // Access Token omitted, should be a CWT whose `cnf` claim contains
///    // the COSE_Key used in the `cnf` field from this AccessTokenResponse.
///    aceProfile: AceProfile.coapDtls,
///    expiresIn: 3600,
///    cnf: PlainCoseKey(key));
/// final serialized = response.serialize();
/// assert(AccessTokenResponse.deserializeFrom(serialized) == response);
/// ```
class AccessTokenResponse extends CborMapSerializable {
  /// The access token issued by the authorization server.
  ///
  /// Must be included.
  ByteString accessToken;

  /// The lifetime in seconds of the access token.
  int? expiresIn;

  /// The scope of the access token as described by
  /// section 3.3 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html#section-3.3).
  ///
  /// See the documentation of [Scope] for details.
  Scope? scope;

  /// The type of the token issued as described in
  /// [section 7.1 of RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html#section-7.1)
  /// and [section 5.8.4.2 of `draft-ietf-ace-oauth-authz-46`](https://www.ietf.org/archive/id/draft-ietf-ace-oauth-authz-46.html#figure-5.8.4.2).
  ///
  /// See the documentation of [TokenType] for details.
  TokenType? tokenType;

  /// The refresh token, which can be used to obtain new access tokens using
  /// the same authorization grant as described in
  /// [section 6 of RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html#section-6).
  ByteString? refreshToken;

  /// This indicates the profile that the client must use towards the RS.
  ///
  /// See the documentation of [AceProfile] for details.
  AceProfile? aceProfile;

  /// The proof-of-possession key that the AS selected for the token.
  ///
  /// See the documentation of [ProofOfPossessionKey] for details.
  ProofOfPossessionKey? cnf;

  /// Information about the public key used by the RS to authenticate.
  ///
  /// See the documentation of [ProofOfPossessionKey] for details.
  ProofOfPossessionKey? rsCnf;

  /// Timestamp when the token was issued.
  /// Note that this is only used by libdcaf and not present in the ACE-OAuth
  /// specification for access token responses.
  /// It is instead usually encoded as a claim in the access token itself.
  ///
  /// Defined in [section 3.1.6 of RFC 8392](https://www.rfc-editor.org/rfc/rfc8392.html#section-3.1.6)
  /// and [Figure 16 of `draft-ietf-ace-oauth-authz`](https://www.ietf.org/archive/id/draft-ietf-ace-oauth-authz-46.html#figure-16).
  DateTime? issuedAt;

  /// Creates a new [AccessTokenResponse] instance.
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

  static ByteString _initializeAccessToken(CborValue? token) {
    if (token == null || token is! CborBytes) {
      throw ArgumentError("Given CBOR map must have access token field!");
    }
    return token.bytes;
  }

  /// Creates a new [AccessTokenResponse] instance from the given
  /// CBOR [map].
  AccessTokenResponse.fromCborMap(Map<int, CborValue> map)
      : accessToken = _initializeAccessToken(map[token_const.accessToken]) {
    // TODO(falko17): Better error handling
    map.forEach((key, value) {
      switch (key) {
        case token_const.accessToken:
          // We've already handled this required field above.
          break;
        case token_const.expiresIn:
          expiresIn = (value as CborInt).toInt();
          break;
        case intro_const.issuedAt:
          issuedAt = DateTime.fromMillisecondsSinceEpoch(
              // CBOR will be given in whole seconds
              (value as CborSmallInt).value * 1000,
              isUtc: true);
          break;
        case token_const.cnf:
          cnf = ProofOfPossessionKey.fromCborValue(value as CborMap);
          break;
        case token_const.scope:
          scope = Scope.fromValue(value);
          break;
        case token_const.tokenType:
          tokenType = TokenType.fromCborValue(value);
          break;
        case token_const.refreshToken:
          refreshToken = (value as CborBytes).bytes;
          break;
        case token_const.aceProfile:
          aceProfile = AceProfile.fromCborValue(value);
          break;
        case token_const.rsCnf:
          rsCnf = ProofOfPossessionKey.fromCborValue(value);
          break;
        default:
          throw UnsupportedError("CBOR map key $key not supported!");
      }
    });
  }

  /// Creates a new [AccessTokenResponse] instance from the given
  /// [serialized] CBOR.
  AccessTokenResponse.fromSerialized(List<int> serialized)
      : this.fromCborMap(
            CborMapSerializable.valueToCborMap(cborDecode(serialized)));

  @override
  Map<int, CborValue> toCborMap() {
    return {
      token_const.accessToken: CborBytes(accessToken),
      if (expiresIn != null) token_const.expiresIn: CborSmallInt(expiresIn!),
      if (issuedAt != null)
        intro_const.issuedAt: CborDateTimeInt(issuedAt!, tags: []),
      if (cnf != null) token_const.cnf: cnf!.toCborValue(),
      if (scope != null) token_const.scope: scope!.toCborValue(),
      if (tokenType != null) token_const.tokenType: tokenType!.toCborValue(),
      if (refreshToken != null)
        token_const.refreshToken: CborBytes(refreshToken!),
      if (aceProfile != null) token_const.aceProfile: aceProfile!.toCborValue(),
      if (rsCnf != null) token_const.rsCnf: rsCnf!.toCborValue(),
    };
  }

  @override
  String toString() {
    return 'AccessTokenResponse{accessToken: $accessToken, '
        'expiresIn: $expiresIn, scope: $scope, tokenType: $tokenType, '
        'refreshToken: $refreshToken, aceProfile: $aceProfile, cnf: $cnf, '
        'rsCnf: $rsCnf, issuedAt: $issuedAt}';
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
