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
import 'cbor.dart';
import 'endpoints/token_request.dart';
import 'endpoints/token_response.dart';

/// Profiles for ACE-OAuth as specified in [section 5.8.4.3 of `draft-ietf-ace-oauth-authz`](https://www.ietf.org/archive/id/draft-ietf-ace-oauth-authz-46.html#section-5.8.4.3).
///
/// ACE-OAuth profiles are used in the [AccessTokenResponse]
/// if the client previously sent an [AccessTokenRequest] with the
/// `ace_profile` field set.
///
/// There are (to my awareness) at the moment two profiles for ACE-OAuth:
/// - The DTLS profile, specified in [`draft-ietf-ace-dtls-authorize`](https://www.ietf.org/archive/id/draft-ietf-ace-dtls-authorize-18.html).
/// - The OSCORE profile, defined in [`draft-ietf-ace-oscore-profile`](https://www.ietf.org/archive/id/draft-ietf-ace-oscore-profile-19.html).
///    - Note that this is an expired Internet-Draft which does not have a
///      specified CBOR representation yet. Hence, this is not offered as
///      an option in this enum.
///
/// # Example
/// For example, if you wish to indicate in your response
/// that the DTLS profile is used:
/// ```dart
/// final request = AccessTokenResponse(
///     accessToken: [1,2,3,4],
///     aceProfile: AceProfile.coapDtls);
/// ```
enum AceProfile with CborSerializableEnum {
  /// DTLS profile specified in
  /// [`draft-ietf-ace-oscore-profile`](https://www.ietf.org/archive/id/draft-ietf-ace-oscore-profile-19.txt).
  ///
  /// **Note: The actual CBOR value is still TBD,
  /// the value used here is just what's suggested in the draft above.**
  coapDtls(1);

  @override
  final int cbor;

  /// Creates a new [AceProfile] instance using the given CBOR value.
  const AceProfile(this.cbor);

  /// Creates a new [AceProfile] instance using the given CBOR [value].
  static AceProfile fromCborValue(CborValue value) {
    final valueInt = CborSerializableEnum.valueToInt(value);
    return AceProfile.values.singleWhere((e) => e.cbor == valueInt);
  }
}
