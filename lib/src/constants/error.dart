/// Constants for CBOR abbreviations in error codes,
/// as specified in [`draft-ietf-ace-oauth-authz-46`](https://www.ietf.org/archive/id/draft-ietf-ace-oauth-authz-46.html), Figure 10.

/// See section 5.2 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
const int INVALID_REQUEST = 1;

/// See section 5.2 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
const int INVALID_CLIENT = 2;

/// See section 5.2 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
const int INVALID_GRANT = 3;

/// See section 5.2 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
const int UNAUTHORIZED_CLIENT = 4;

/// See section 5.2 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
const int UNSUPPORTED_GRANT_TYPE = 5;

/// See section 5.2 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
const int INVALID_SCOPE = 6;

/// See section 5.8.3 of [`draft-ietf-ace-oauth-authz-46`](https://www.ietf.org/archive/id/draft-ietf-ace-oauth-authz-46.html).
const int UNSUPPORTED_POP_KEY = 7;

/// See section 5.8.3 of [`draft-ietf-ace-oauth-authz-46`](https://www.ietf.org/archive/id/draft-ietf-ace-oauth-authz-46.html).
const int INCOMPATIBLE_ACE_PROFILES = 8;