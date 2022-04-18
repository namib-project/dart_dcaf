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
import '../cbor.dart';
import '../constants/token.dart' as token_const;
import '../error_code.dart';

/// Details about an error which occurred for an access token request.
///
/// For more information, see [section 5.8.3 of `draft-ietf-ace-oauth-authz`](https://www.ietf.org/archive/id/draft-ietf-ace-oauth-authz-46.html#section-5.8.3).
///
/// # Example
/// For example, let us use the example from [section 5.2 of RFC 6749](https://www.rfc-editor.org/rfc/rfc6749.html#section-5.2):
/// ```text
/// {
///       "error": "invalid_request"
/// }
/// ```
/// (Note that abbreviations aren't used here, so keep in mind that the
/// labels are really integers instead of strings.)
///
/// Creating and serializing a simple error response telling the client
/// their request was invalid
/// would look like the following:
/// ```dart
/// final error = ErrorResponse(error: ErrorCode.invalidRequest);
/// final serialized = error.serialize();
/// assert(ErrorResponse.fromSerialized(serialized) == error);
/// ```
class ErrorResponse extends CborMapSerializable {
  /// Error code for this error.
  ///
  /// Must be included.
  ///
  /// See the documentation of [ErrorCode] for details.
  ErrorCode error;

  /// Human-readable ASCII text providing additional information,
  /// used to assist the client developer in understanding the error that
  /// occurred.
  String? description;

  /// A URI identifying a human-readable web page with information about the
  /// error, used to provide the client developer with additional information
  //about the error.
  String? uri;

  /// Creates a new [ErrorResponse] instance.
  ErrorResponse({required this.error, this.description, this.uri});

  /// Creates a new [ErrorResponse] instance from the given CBOR [map].
  ErrorResponse.fromCborMap(Map<int, CborValue> map)
      : error = ErrorCode.fromCborValue(map[token_const.error]!) {
    map.forEach((key, value) {
      switch (key) {
        case token_const.error:
          // We've already handled this required field above.
          break;
        case token_const.errorDescription:
          description = (value as CborString).toString();
          break;
        case token_const.errorUri:
          uri = (value as CborString).toString();
          break;
        default:
          throw FormatException("CBOR map key $key not supported!", map);
      }
    });
  }

  /// Creates a new [ErrorResponse] instance from the given [serialized] CBOR.
  ErrorResponse.fromSerialized(List<int> serialized)
      : this.fromCborMap(
            CborMapSerializable.valueToCborMap(cborDecode(serialized)));

  @override
  Map<int, CborValue> toCborMap() {
    return {
      token_const.error: error.toCborValue(),
      if (description != null)
        token_const.errorDescription: CborString(description!),
      if (uri != null) token_const.errorUri: CborString(uri!)
    };
  }

  @override
  String toString() {
    return 'ErrorResponse{error: $error, description: $description, uri: $uri}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ErrorResponse &&
          runtimeType == other.runtimeType &&
          error == other.error &&
          description == other.description &&
          uri == other.uri;

  @override
  int get hashCode => error.hashCode ^ description.hashCode ^ uri.hashCode;
}
