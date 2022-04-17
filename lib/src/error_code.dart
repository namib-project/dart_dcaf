import 'package:cbor/cbor.dart';
import 'package:dcaf/src/cbor.dart';
import 'endpoints/error_response.dart';

/// Error code specifying what went wrong for a token request, as specified in
/// [section 5.2 of RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html#section-5.2) and
/// [section 5.8.3 of `draft-ietf-ace-oauth-authz`](https://www.ietf.org/archive/id/draft-ietf-ace-oauth-authz-46.html#section-5.8.3).
///
/// Note that we don't yet support custom error codes.
///
/// An error code is used in the [ErrorResponse].
///
/// # Example
/// For example, if you wish to indicate in your error response that the client
/// is not authorized:
/// ```dart
/// let request = ErrorResponse(error: ErrorCode.unauthorizedClient);
/// ```
enum ErrorCode with CborIntSerializable {
  /// The request is missing a required parameter, includes an unsupported
  /// parameter value (other than grant type), repeats a parameter, includes
  /// multiple credentials, utilizes more than one mechanism for authenticating
  /// the client, or is otherwise malformed.
  invalidRequest(1),

  /// Client authentication failed (e.g., unknown client,
  /// no client authentication included, or
  /// unsupported authentication method)
  invalidClient(2),

  /// The provided authorization grant (e.g., authorization code,
  /// resource owner credentials) or refresh token is invalid, expired,
  /// revoked, does not match the redirection URI used in the
  /// authorization request, or was issued to another client.
  invalidGrant(3),

  /// The authenticated client is not authorized to use
  /// this authorization grant type.
  unauthorizedClient(4),

  /// The authorization grant type is not supported by the authorization server.
  unsupportedGrantType(5),

  /// The authorization grant type is not supported by the authorization server.
  invalidScope(6),

  /// The client submitted an asymmetric key in the token request that the
  /// RS cannot process.
  unsupportedPopKey(7),

  /// The client and the RS it has requested an access token for do not share
  /// a common profile.
  incompatibleAceProfiles(8);

  @override
  final int cbor;

  /// Creates a new [ErrorCode] instance using the given CBOR value.
  const ErrorCode(this.cbor);

  /// Creates a new [ErrorCode] instance using the given CBOR [value].
  static ErrorCode fromCborValue(CborValue value) {
    final valueInt = CborIntSerializable.valueToInt(value);
    return ErrorCode.values.singleWhere((e) => e.cbor == valueInt);
  }
}
