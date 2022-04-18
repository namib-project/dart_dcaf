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

import '../cbor.dart';
import '../constants/introspection.dart' as intro_const;
import '../constants/token.dart' as token_const;
import '../grant_type.dart';
import '../pop.dart';
import '../scope.dart';

/// Request for an access token, sent from the client, as defined in
/// [section 5.8.1 of `draft-ietf-ace-oauth-authz`](https://www.ietf.org/archive/id/draft-ietf-ace-oauth-authz-46.html#section-5.8.1).
///
/// # Example
/// Figure 5 of [`draft-ietf-ace-oauth-authz-46`](https://www.ietf.org/archive/id/draft-ietf-ace-oauth-authz-46.html#figure-5)
/// gives us an example of an access token request,
/// given in CBOR diagnostic notation:
/// ```text
/// {
///     "client_id" : "myclient",
///     "audience" : "tempSensor4711"
/// }
/// ```
/// (Note that abbreviations aren't used here, so keep in mind that the
/// labels are really integers instead of strings.)
///
/// This could be built and serialized as an [AccessTokenRequest] like so:
/// ```dart
/// final request = AccessTokenRequest(
///    clientId: "myclient",
///    audience: "tempSensor4711");
/// final serialized = hint.serialized();
/// assert(AccessTokenRequest.fromSerialized(serialized) == request);
/// ```
class AccessTokenRequest extends CborMapSerializable {
  /// The client identifier as described in section 2.2 of
  /// [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
  String? clientId;

  /// Grant type used for this request.
  ///
  /// See also the documentation of [GrantType] for details.
  GrantType? grantType;

  /// The logical name of the target service where the client intends to use
  /// the requested security token.
  String? audience;

  /// URI to redirect the client to after authorization is complete.
  String? redirectUri;

  /// Client nonce to ensure the token is still fresh.
  ByteString? clientNonce;

  /// Scope of the access request as described by section 3.3 of
  /// [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
  ///
  /// See also the documentation of [Scope] for details.
  Scope? scope;

  /// Included in the request if the AS shall include the `ace_profile`
  /// parameter in its response.
  bool includeAceProfile = false;

  /// Contains information about the key the client would like to bind to the
  /// access token for proof-of-possession.
  ///
  /// See also the documentation of [ProofOfPossessionKey] for details.
  ProofOfPossessionKey? reqCnf;

  /// Issuer of the token.
  /// Note that this is only used by libdcaf and not present
  /// in the ACE-OAuth specification for access token requests.
  /// Instead, it is usually encoded as a claim in the access token itself.
  ///
  /// Defined in [section 3.1.1 of RFC 8392](https://www.rfc-editor.org/rfc/rfc8392.html#section-3.1.1)
  /// and [Figure 16 of `draft-ietf-ace-oauth-authz`](https://www.ietf.org/archive/id/draft-ietf-ace-oauth-authz-46.html#figure-16).
  String? issuer;

  /// Creates a new [AccessTokenRequest] instance.
  AccessTokenRequest(
      {this.clientId,
      this.grantType,
      this.audience,
      this.redirectUri,
      this.clientNonce,
      this.scope,
      this.includeAceProfile = false,
      this.reqCnf,
      this.issuer});

  /// Creates a new [AccessTokenRequest] instance from the given CBOR [map].
  AccessTokenRequest.fromCborMap(Map<int, CborValue> map) {
    map.forEach((key, value) {
      switch (key) {
        case token_const.clientId:
          clientId = (value as CborString).toString();
          break;
        case token_const.grantType:
          grantType = GrantType.fromCborValue(value);
          break;
        case token_const.audience:
          audience = (value as CborString).toString();
          break;
        case token_const.redirectUri:
          redirectUri = (value as CborString).toString();
          break;
        case token_const.cNonce:
          clientNonce = (value as CborBytes).bytes;
          break;
        case token_const.scope:
          scope = Scope.fromValue(value);
          break;
        case token_const.aceProfile:
          includeAceProfile = true;
          break;
        case token_const.reqCnf:
          reqCnf = ProofOfPossessionKey.fromCborMap(
              CborMapSerializable.valueToCborMap(value));
          break;
        case intro_const.issuer:
          issuer = (value as CborString).toString();
          break;
        default:
          throw FormatException("CBOR map key $key not supported!", map);
      }
    });
  }

  /// Creates a new [AccessTokenRequest] instance from the given
  /// [serialized] CBOR.
  AccessTokenRequest.fromSerialized(List<int> serialized)
      : this.fromCborMap(
            CborMapSerializable.valueToCborMap(cborDecode(serialized)));

  @override
  Map<int, CborValue> toCborMap() {
    return {
      if (issuer != null) intro_const.issuer: CborString(issuer!),
      if (reqCnf != null) token_const.reqCnf: reqCnf!.toCborValue(),
      if (audience != null) token_const.audience: CborString(audience!),
      if (scope != null) token_const.scope: scope!.toCborValue(),
      if (clientId != null) token_const.clientId: CborString(clientId!),
      if (redirectUri != null)
        token_const.redirectUri: CborString(redirectUri!),
      if (grantType != null)
        token_const.grantType: CborSmallInt(grantType!.cbor),
      if (includeAceProfile) token_const.aceProfile: CborNull(),
      if (clientNonce != null) token_const.cNonce: CborBytes(clientNonce!),
    };
  }

  @override
  String toString() {
    return 'AccessTokenRequest{clientId: $clientId, grantType: $grantType, '
        'audience: $audience, redirectUri: $redirectUri, '
        'clientNonce: $clientNonce, scope: $scope, '
        'includeAceProfile: $includeAceProfile, reqCnf: $reqCnf, '
        'issuer: $issuer}';
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
