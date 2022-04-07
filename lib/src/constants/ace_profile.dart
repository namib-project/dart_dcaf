/// Constants for CBOR abbreviations in token types, as specified in:
/// - `draft-ietf-ace-oauth-authz`, section 8.8.
/// - [`draft-ietf-ace-oscore-profile`](https://www.ietf.org/archive/id/draft-ietf-ace-oscore-profile-19.txt),
///   section 9.1.
/// - [`draft-ietf-ace-dtls-authorize`](https://www.ietf.org/archive/id/draft-ietf-ace-dtls-authorize-18.html),
///   section 9.

/// DTLS profile specified in
/// [`draft-ietf-ace-oscore-profile`](https://www.ietf.org/archive/id/draft-ietf-ace-oscore-profile-19.txt).
///
/// **Note: The actual value is still TBD, this is just what's suggested in the draft above.**
const int COAP_DTLS = 1;

// The below is commented out because no CBOR value has been set in the specification yet.
// /// OSCORE profile specified in
// /// [`draft-ietf-ace-oscore-profile`](https://www.ietf.org/archive/id/draft-ietf-ace-oscore-profile-19.txt).
// const int COAP_OSCORE = ?;
