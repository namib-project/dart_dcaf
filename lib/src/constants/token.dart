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

/// Constants for CBOR map keys in token requests and responses,
/// as specified in [`draft-ietf-ace-oauth-authz-46`](https://www.ietf.org/archive/id/draft-ietf-ace-oauth-authz-46.html), Figure 12
/// and `draft-ietf-ace-oauth-params`, Figure 5.

/// See section 5.1 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
const int accessToken = 1;

/// See section 5.1 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
const int expiresIn = 2;

/// See section 3.1 of [`draft-ietf-ace-oauth-params-16`](https://www.ietf.org/archive/id/draft-ietf-ace-oauth-params-16.html).
const int reqCnf = 4;

/// See section 2.1 of [RFC 8693](https://www.rfc-editor.org/rfc/rfc8693.html).
const int audience = 5;

/// See section 3.2 of [`draft-ietf-ace-oauth-params-16`](https://www.ietf.org/archive/id/draft-ietf-ace-oauth-params-16.html).
const int cnf = 8;

/// See section 4.4.2 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html)
/// and section 5.1 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
const int scope = 9;

/// See section 2.2 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
const int clientId = 24;

/// See section 2.3.1 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
const int clientSecret = 25;

/// See section 3.1.1 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
const int responseType = 26;

/// See section 3.1.2 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
const int redirectUri = 27;

/// See section 4.1.1 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
const int state = 28;

/// See section 4.1.3 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
const int code = 29;

/// See section 5.2 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
const int error = 30;

/// See section 5.2 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
const int errorDescription = 31;

/// See section 5.2 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
const int errorUri = 32;

/// See section 4.4.2 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
const int grantType = 33;

/// See section 5.1 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
const int tokenType = 34;

/// See section 4.3.2 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
const int username = 35;

/// See section 4.3.2 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
const int password = 36;

/// See section 5.1 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
const int refreshToken = 37;

/// See section 5.8.4.3 of [`draft-ietf-ace-oauth-authz-46`](https://www.ietf.org/archive/id/draft-ietf-ace-oauth-authz-46.html).
const int aceProfile = 38;

/// See section 5.8.4.4 of [`draft-ietf-ace-oauth-authz-46`](https://www.ietf.org/archive/id/draft-ietf-ace-oauth-authz-46.html).
const int cNonce = 39;

/// See section 3.2 of [`draft-ietf-ace-oauth-params-16`](https://www.ietf.org/archive/id/draft-ietf-ace-oauth-params-16.html).
const int rsCnf = 41;
