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
import 'package:dcaf/src/cbor.dart';
import 'endpoints/token_request.dart';
import 'endpoints/token_response.dart';

/// Type of the resource owner's authorization used by the client to obtain
/// an access token.
/// For more information, see [section 1.3 of RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
///
/// Note that we don't support custom grant types yet.
///
/// Grant types are used in the [AccessTokenRequest].
///
/// # Example
/// For example, if you wish to indicate in your request that the
/// resource owner's authorization works via client credentials:
/// ```dart
/// final request = AccessTokenRequest(
///     clientId: "test_client",
///     grantType: GrantType.clientCredentials);
/// ```

enum GrantType with CborSerializableEnum {
  /// Grant type intended for clients capable of obtaining the
  /// resource owner's credentials.
  ///
  /// Note that the authorization server should take special care when
  /// enabling this grant type and only allow it when
  /// other flows are not viable.
  ///
  /// See [section 4.3 of RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html#section-4.3)
  /// for details.
  password(0),

  /// Redirection-based flow optimized for confidential clients.
  ///
  /// See [section 4.1 of RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html#section-4.1)
  /// for details.
  authorizationCode(1),

  /// Used when the client authenticates with the authorization server
  /// in an unspecified way.
  ///
  /// Must only be used for confidential clients.
  ///
  /// See [section 4.4 of RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html#section-4.4)
  /// for details.
  clientCredentials(2),

  /// Used for refreshing an existing access token.
  ///
  /// When using this, it's necessary that `refresh_token`
  /// is specified in the [AccessTokenResponse].
  ///
  /// See [section 6 of RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html#section-6)
  /// for details.
  refreshToken(3);

  // Note: "Other" is not supported.

  @override
  final int cbor;

  /// Creates a new [GrantType] instance using the given CBOR value.
  const GrantType(this.cbor);

  /// Creates a new [GrantType] instance using the given CBOR [value].
  static GrantType fromCborValue(CborValue value) {
    final valueInt = CborSerializableEnum.valueToInt(value);
    return GrantType.values.singleWhere((e) => e.cbor == valueInt);
  }
}
