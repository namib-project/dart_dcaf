/// Constants for CBOR map keys in token requests and responses,
/// as specified in [`draft-ietf-ace-oauth-authz-46`](https://www.ietf.org/archive/id/draft-ietf-ace-oauth-authz-46.html), Figure 12
/// and `draft-ietf-ace-oauth-params`, Figure 5.

/// See section 5.1 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
const int ACCESS_TOKEN = 1;

/// See section 5.1 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
const int EXPIRES_IN = 2;

/// See section 3.1 of [`draft-ietf-ace-oauth-params-16`](https://www.ietf.org/archive/id/draft-ietf-ace-oauth-params-16.html).
const int REQ_CNF = 4;

/// See section 2.1 of [RFC 8693](https://www.rfc-editor.org/rfc/rfc8693.html).
const int AUDIENCE = 5;

/// See section 3.2 of [`draft-ietf-ace-oauth-params-16`](https://www.ietf.org/archive/id/draft-ietf-ace-oauth-params-16.html).
const int CNF = 8;

/// See section 4.4.2 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html)
/// and section 5.1 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
const int SCOPE = 9;

/// See section 2.2 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
const int CLIENT_ID = 24;

/// See section 2.3.1 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
const int CLIENT_SECRET = 25;

/// See section 3.1.1 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
const int RESPONSE_TYPE = 26;

/// See section 3.1.2 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
const int REDIRECT_URI = 27;

/// See section 4.1.1 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
const int STATE = 28;

/// See section 4.1.3 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
const int CODE = 29;

/// See section 5.2 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
const int ERROR = 30;

/// See section 5.2 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
const int ERROR_DESCRIPTION = 31;

/// See section 5.2 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
const int ERROR_URI = 32;

/// See section 4.4.2 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
const int GRANT_TYPE = 33;

/// See section 5.1 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
const int TOKEN_TYPE = 34;

/// See section 4.3.2 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
const int USERNAME = 35;

/// See section 4.3.2 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
const int PASSWORD = 36;

/// See section 5.1 of [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html).
const int REFRESH_TOKEN = 37;

/// See section 5.8.4.3 of [`draft-ietf-ace-oauth-authz-46`](https://www.ietf.org/archive/id/draft-ietf-ace-oauth-authz-46.html).
const int ACE_PROFILE = 38;

/// See section 5.8.4.4 of [`draft-ietf-ace-oauth-authz-46`](https://www.ietf.org/archive/id/draft-ietf-ace-oauth-authz-46.html).
const int CNONCE = 39;

/// See section 3.2 of [`draft-ietf-ace-oauth-params-16`](https://www.ietf.org/archive/id/draft-ietf-ace-oauth-params-16.html).
const int RS_CNF = 41;
