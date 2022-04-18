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
import '../constants/creation_hint.dart' as constants;
import '../scope.dart';

/// This is sent by an RS as a response to an Unauthorized Resource Request
/// Message to help the sender of the Unauthorized Resource Request Message
/// acquire a valid access token.
///
/// For more information, see [section 5.3 of `draft-ietf-ace-oauth-authz`](https://www.ietf.org/archive/id/draft-ietf-ace-oauth-authz-46.html#section-5.3).
///
/// # Example
/// Figure 3 of [`draft-ietf-ace-oauth-authz-46`](https://www.ietf.org/archive/id/draft-ietf-ace-oauth-authz-46.html#figure-3)
/// gives us an example of a Request Creation Hint payload, given in CBOR
/// diagnostic notation
/// ```text
/// {
///     "AS" : "coaps://as.example.com/token",
///     "audience" : "coaps://rs.example.com"
///     "scope" : "rTempC",
///     "cnonce" : h'e0a156bb3f'
/// }
/// ```
/// (Note that abbreviations aren't used here, so keep in mind that the
/// labels are really integers instead of strings.)
///
/// This could be built and serialized as an
/// [AuthServerRequestCreationHint] like so:
/// ```dart
/// final scope = TextScope("rTempC");
/// final hint = AuthServerRequestCreationHint(
///     authorizationServer: "coaps://as.example.com/token",
///     audience: "coaps://rs.example.com",
///     scope: scope,
///     clientNonce: [0xe0, 0xa1, 0x56, 0xbb, 0x3f]);
/// final serialized = hint.serialize();
/// assert(AuthServerRequestCreationHint.fromSerialized(serialized) == request);
/// ```
class AuthServerRequestCreationHint extends CborMapSerializable {
  /// An absolute URI that identifies the appropriate AS for the RS.
  String? authorizationServer;

  /// The key identifier of a key used in an existing security association
  /// between the client and the RS.
  ByteString? keyID;

  /// An identifier the client should request at the AS, as suggested by the RS.
  String? audience;

  /// The suggested scope that the client should request towards the AS.
  ///
  /// See the documentation of [Scope] for details.
  Scope? scope;

  /// A client nonce as described in [section 5.3.1 of `draft-ietf-ace-oauth-authz`](https://www.ietf.org/archive/id/draft-ietf-ace-oauth-authz-46.html#section-5.3.1).
  ByteString? clientNonce;

  /// Creates a new [AuthServerRequestCreationHint] instance from the given
  /// [serialized] CBOR.
  AuthServerRequestCreationHint.fromSerialized(List<int> serialized)
      : this.fromCborMap(
            CborMapSerializable.valueToCborMap(cborDecode(serialized)));

  /// Creates a new [AuthServerRequestCreationHint] instance.
  AuthServerRequestCreationHint(
      {this.authorizationServer,
      this.keyID,
      this.audience,
      this.scope,
      this.clientNonce});

  /// Creates a new [AuthServerRequestCreationHint] instance from the given
  /// CBOR [map].
  AuthServerRequestCreationHint.fromCborMap(Map<int, CborValue> map) {
    // TODO(falko17): Better error handling
    map.forEach((key, value) {
      switch (key) {
        case constants.AS:
          authorizationServer = (value as CborString).toString();
          break;
        case constants.kId:
          keyID = (value as CborBytes).bytes;
          break;
        case constants.audience:
          audience = (value as CborString).toString();
          break;
        case constants.scope:
          scope = Scope.fromValue(value);
          break;
        case constants.cNonce:
          clientNonce = (value as CborBytes).bytes;
          break;
        default:
          throw FormatException("CBOR map key $key not supported!", map);
      }
    });
  }

  @override
  Map<int, CborValue> toCborMap() {
    return {
      if (authorizationServer != null)
        constants.AS: CborString(authorizationServer!),
      if (keyID != null) constants.kId: CborBytes(keyID!),
      if (audience != null) constants.audience: CborString(audience!),
      if (scope != null) constants.scope: scope!.toCborValue(),
      if (clientNonce != null) constants.cNonce: CborBytes(clientNonce!)
    };
  }

  @override
  String toString() {
    return 'AuthServerRequestCreationHint{'
        'authorizationServer: $authorizationServer, keyID: $keyID, '
        'audience: $audience, scope: $scope, clientNonce: $clientNonce}';
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
