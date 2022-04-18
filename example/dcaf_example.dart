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
import 'package:dcaf/dcaf.dart';

void main() {
  // Creating and (de)serializing a Creation Hint:
  final scope = TextScope("rTempC");
  final hint = AuthServerRequestCreationHint(
      authorizationServer: "coaps://as.example.com/token",
      audience: "coaps://rs.example.com",
      scope: scope,
      clientNonce: [0xe0, 0xa1, 0x56, 0xbb, 0x3f]);
  final List<int> serializedHint = hint.serialize();

  assert(AuthServerRequestCreationHint.fromSerialized(serializedHint) == hint);
  // Creating and (de)serializing an Access Token Request:
  final request = AccessTokenRequest(
      clientId: "myclient",
      audience: "valve242",
      scope: TextScope("read"),
      reqCnf: KeyId([0xDC, 0xAF]));
  final List<int> serializedRequest = request.serialize();
  assert(AccessTokenRequest.fromSerialized(serializedRequest) == request);

  // Creating and (de)serializing an Access Token Response
  // which is represented in CBOR diagnostic notation like this...
  // {
  //   "access_token" : b64'SlAV32hkKG ...
  //    (remainder of CWT omitted for brevity;
  //    CWT contains COSE_Key in the "cnf" claim)',
  //   "ace_profile" : "coap_dtls",
  //   "expires_in" : "3600",
  //   "cnf" : {
  //     "COSE_Key" : {
  //       "kty" : "Symmetric",
  //       "kid" : b64'39Gqlw',
  //       "k" : b64'hJtXhkV8FJG+Onbc6mxCcQh'
  //     }
  //   }
  // }
  //
  // ...would look like this:

  final key = CoseKey(keyType: KeyType.symmetric, keyId: [
    0xDF,
    0xD1,
    0xAA,
    0x97
  ], parameters: {
    // field "k" (the key itself)
    -1: CborBytes([
      0x84,
      0x9b,
      0x57,
      0x86,
      0x45,
      0x7c,
      0x14,
      0x91,
      0xbe,
      0x3a,
      0x76,
      0xdc,
      0xea,
      0x6c,
      0x42,
      0x71,
      0x08
    ])
  });
  final response = AccessTokenResponse(
      // NOTE: This is not what the access token is really supposed to be!
      // In an actual implementation, it should contain a properly
      // signed/encrypted CWT with the `key` defined above in its `cnf` claim!
      accessToken: [0xDC, 0xAF],
      aceProfile: AceProfile.coapDtls,
      expiresIn: 3600,
      cnf: PlainCoseKey(key));
  final serialized = response.serialize();
  assert(AccessTokenResponse.fromSerialized(serialized) == response);
}
