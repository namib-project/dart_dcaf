/// Constants for CBOR map keys in token introspections,
/// as specified in [`draft-ietf-ace-oauth-authz-46`](https://www.ietf.org/archive/id/draft-ietf-ace-oauth-authz-46.html), Figure 16
/// and [RFC 8392](https://www.rfc-editor.org/rfc/rfc8392.html).
///
/// Some of these constants are also used by libdcaf for additional fields which are required
/// according to [DCAF](https://gitlab.informatik.uni-bremen.de/DCAF/dcaf/).
///
/// **NOTE: This is currently incomplete!**
/// Only libdcaf-required parameters are in here for now.

/// See [section 3.1.1 of RFC 8392](https://www.rfc-editor.org/rfc/rfc8392.html#section-3.1.1).
const int ISSUER = 1;

/// See [section 3.1.6 of RFC 8392](https://www.rfc-editor.org/rfc/rfc8392.html#section-3.1.6).
const int ISSUED_AT = 6;
