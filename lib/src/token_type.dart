import 'package:cbor/cbor.dart';
import 'package:dcaf/src/cbor.dart';
import 'endpoints/token_response.dart';

/// The type of the token issued as described in section 7.1 of
/// [RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html#section-7.1).
///
/// Note that we don't support custom grant types yet.
///
/// Token types are used in the [AccessTokenResponse].
///
/// # Example
/// For example, if you wish to indicate in your response that the token is of
/// the proof-of-possession type:
/// ```dart
/// final request = AccessTokenResponse(
///     accessToken: [1,2,3,4],
///     tokenType: TokenType.proofOfPossession,
///     cnf: KeyId([0xDC, 0xAF]));
/// ```
enum TokenType with CborSerializableEnum {

  /// Bearer token type as defined in [RFC 6750](https://www.rfc-editor.org/rfc/rfc6750).
  bearer(1),

  /// Proof-of-possession token type, as specified in
  /// [`draft-ietf-ace-oauth-params-16`](https://www.ietf.org/archive/id/draft-ietf-ace-oauth-params-16.html).
  proofOfPossession(2);

  @override
  final int cbor;

  /// Creates a new [TokenType] instance using the given CBOR value.
  const TokenType(this.cbor);

  /// Creates a new [TokenType] instance using the given CBOR [value].
  static TokenType fromCborValue(CborValue value) {
    final valueInt = CborSerializableEnum.valueToInt(value);
    return TokenType.values.singleWhere((e) => e.cbor == valueInt);
  }
}
