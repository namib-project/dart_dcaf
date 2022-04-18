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
import 'package:freezed_annotation/freezed_annotation.dart';

import 'aif.dart';
import 'cbor.dart';
import 'endpoints/token_request.dart';
import 'endpoints/token_response.dart';

/// Scope of an access token as specified in
/// [`draft-ietf-ace-oauth-authz`, section 5.8.1](https://www.ietf.org/archive/id/draft-ietf-ace-oauth-authz-46.html#section-5.8.1-2.4).
///
/// May be used both for [AccessTokenRequest]s and [AccessTokenResponse]s.
///
/// If the given CBOR type is unsupported, a [FormatException] will be thrown.
///
/// # Example
///
/// You can create binary, text encoded, or AIF-encoded scopes:
/// ```dart
/// final textScope = TextScope("dcaf rs");
/// final binaryScope = BinaryScope([0xDC, 0xAF]);
/// final aifScope = AifScope([AifScopeElement("test", [AifRestMethod.get])]);
/// ```
///
/// For information on how to initialize a concrete scope type
/// or retrieve the individual elements inside them,
/// see their respective documentation pages.
abstract class Scope extends CborSerializable {
  /// Don't use this. This class was not designed to be extended by clients.
  Scope();

  /// Creates a [Scope] instance from the given CBOR [value].
  factory Scope.fromValue(CborValue value) {
    if (value is CborString) {
      return TextScope.fromValue(value);
    } else if (value is CborBytes) {
      return BinaryScope.fromValue(value);
    } else if (value is CborList) {
      if (value.first is CborString) {
        // Special handling for libdcaf.
        return LibdcafScope.fromValue(value);
      } else {
        return AifScope.fromValue(value);
      }
    }
    throw FormatException("Given CBOR type is unsupported!", value);
  }
}

/// A scope encoded using a custom binary encoding.
/// See [Scope] for more information.
///
/// # Example
///
/// Simply create a [BinaryScope] from a byte array
/// (we're using the byte `0x21` as a separator in this example):
/// ```dart
/// final scope = BinaryScope([0x00, 0x21, 0xDC, 0xAF]);
/// assert(scope.elements(0x21) == [[0x00], [0xDC, 0xAF]]));
/// ```
class BinaryScope extends Scope {
  /// The content of the scope, using a custom binary encoding
  /// (though a single separator byte is required).
  ByteString data;

  /// Creates a new [BinaryScope] instance from a byte-string of [data].
  BinaryScope(this.data) {
    if (data.isEmpty) {
      throw FormatException("Scope must not be empty!");
    }
  }

  /// Creates a new [BinaryScope] instance from the given CBOR [bytes].
  BinaryScope.fromValue(CborBytes bytes) : this(bytes.bytes);

  /// Returns the elements of this scope, assuming they are separated by the
  /// given [separator]. If no separator is given, a single element consisting
  /// of the whole [data] is returned.
  ///
  /// Note that a [FormatException] will be thrown in any of these cases:
  /// - The [data] begins with the [separator].
  /// - The [data] ends with the [separator].
  /// - The [data] contains at least two [separator]s in a row.
  List<ByteString> elements(int? separator) {
    if (separator == null) {
      return [data];
    } else if (data.firstOrNull == separator) {
      throw FormatException("Scope must not start with separator!", data, 0);
    } else if (data.lastOrNull == separator) {
      throw FormatException(
          "Scope must not end with separator!", data, data.length - 1);
    } else if (IterableZip([data, data.skip(1)]).any((element) =>
        element.firstOrNull == separator && separator == element.lastOrNull)) {
      throw FormatException(
          "Scope must not contain two consecutive "
          "separators!",
          data);
    }
    final result = data.splitBefore((element) => element == separator);
    // For every element except the first, we need to remove the separator,
    // which is the first respective element of a slice.
    return result
        .take(1)
        .followedBy(result.skip(1).map((e) => e.skip(1).toList()))
        .toList();
  }

  @override
  CborValue toCborValue() {
    return CborBytes(data);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BinaryScope &&
          runtimeType == other.runtimeType &&
          data.equals(other.data);

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() {
    return 'BinaryScope{data: $data}';
  }
}

/// A scope encoded as a space-delimited list of strings, as defined in
/// [RFC 6749, section 1.3](https://www.rfc-editor.org/rfc/rfc6749.html#section-1.3).
///
/// Note that the syntax specified in the RFC has to be followed:
/// ```text
/// scope       = scope-token *( SP scope-token )
/// scope-token = 1*( %x21 / %x23-5B / %x5D-7E )
/// ```
///
/// # Example
///
/// You can create a [TextScope] from a space-separated string:
/// ```dart
/// let scope = TextScope("first second third");
/// assert(scope.elements() == ["first", "second", "third"]);
/// ```
///
/// But note that you have to follow the syntax from the RFC,
/// which implicitly specifies the following:
/// - Scopes can't be empty.
/// - Scopes can't begin or end with a space.
/// - Scopes can't contain two consecutive spaces.
/// - Scopes can't contain the characters `"` (double quote) or `\` (backslash).
class TextScope extends Scope {
  /// Content of the text-encoded scope.
  String data;

  /// Creates a new [TextScope] instance from a string.
  ///
  /// Note that a [FormatException] will be thrown in any of these cases:
  /// - The [data] is empty.
  /// - The [data] begins with a space.
  /// - The [data] ends with a space.
  /// - The [data] contains at least two spaces in a row.
  /// - The [data] contains illegal characters (`"` or `\`).
  TextScope(this.data) {
    if (data.isEmpty) {
      throw FormatException("Scope must not be empty!");
    } else if (data.endsWith(" ")) {
      throw FormatException(
          "Scope must not end with separator (space)!", data, data.length - 1);
    } else if (data.startsWith(" ")) {
      throw FormatException(
          "Scope must not start with separator (space)!", data, 0);
    } else if (data.contains(RegExp(r'(?:"|\\)'))) {
      throw FormatException("Scope must not contain illegal characters!", data);
    } else if (data.contains("  ")) {
      throw FormatException(
          "Scope must not contain two consecutive separators!",
          data,
          data.indexOf("  "));
    }
  }

  /// Creates a new [TextScope] instance from the given CBOR [text].
  TextScope.fromValue(CborString text) : this(text.toString());

  /// Returns the elements of this scope, assuming that it is a list
  /// of elements separated by spaces.
  List<String> get elements => data.split(' ');

  @override
  CborValue toCborValue() {
    return CborString(data);
  }

  @override
  String toString() {
    return 'TextScope{data: $data}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextScope &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;
}
