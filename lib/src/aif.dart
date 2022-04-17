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

import 'dart:collection';

import 'package:cbor/cbor.dart';
import 'package:collection/collection.dart';

import 'cbor.dart';
import 'scope.dart';

/// Possible REST (CoAP or HTTP) methods, intended for use in an
/// [AifScopeElement].
///
/// **Important: This type won't be (de)serialized correctly if
/// the "dynamic" REST methods are used when you're on the Web platform!**
///
/// Note that in addition to the usual CoAP and HTTP REST methods
/// (see "Relevant Documents" below),
/// methods for [Dynamic Resource Creation](https://datatracker.ietf.org/doc/html/draft-ietf-ace-aif#section-2.3)
/// are also provided.
///
/// # Relevant Documents
/// - Definition of `REST-method-set` data model for use in AIF:
///   Figure 4 of [`draft-ietf-ace-aif`, section 3](https://datatracker.ietf.org/doc/html/draft-ietf-ace-aif#section-3)
/// - Specification of HTTP methods GET, POST, PUT, DELETE: [RFC 7231, section 4.3](https://datatracker.ietf.org/doc/html/rfc7231#section-4.3)
/// - Specification of HTTP PATCH method: [RFC 5789](https://datatracker.ietf.org/doc/html/rfc5789)
/// - Specification of CoAP methods GET, POST, PUT, DELETE: [RFC 7252, section 5.8](https://datatracker.ietf.org/doc/html/rfc7252#section-5.8),
/// - Specification of CoAP methods FETCH, PATCH, AND iPATCH: [RFC 8132](https://datatracker.ietf.org/doc/html/rfc8132)
/// - Specification of Dynamic CoAP methods:
///   Figure 4 of [`draft-ietf-ace-aif`, section 2.3](https://datatracker.ietf.org/doc/html/draft-ietf-ace-aif#section-2.3)
enum AifRestMethod with CborSerializableEnum {
  /// GET method as specified in [RFC 7252, section 5.8.1 (CoAP)](https://datatracker.ietf.org/doc/html/rfc7252#section-5.8.1)
  /// and [RFC 7231, section 4.3.1 (HTTP)](https://datatracker.ietf.org/doc/html/rfc7231#section-4.3.1).
  get(1 << 0),

  /// POST method as specified in [RFC 7252, section 5.8.2 (CoAP)](https://datatracker.ietf.org/doc/html/rfc7252#section-5.8.2)
  /// and [RFC 7231, section 4.3.3 (HTTP)](https://datatracker.ietf.org/doc/html/rfc7231#section-4.3.3).
  post(1 << 1),

  /// PUT method as specified in [RFC 7252, section 5.8.3 (CoAP)](https://datatracker.ietf.org/doc/html/rfc7252#section-5.8.3)
  /// and [RFC 7231, section 4.3.4 (HTTP)](https://datatracker.ietf.org/doc/html/rfc7231#section-4.3.4).
  put(1 << 2),

  /// DELETE method as specified in [RFC 7252, section 5.8.4 (CoAP)](https://datatracker.ietf.org/doc/html/rfc7252#section-5.8.4)
  /// and [RFC 7231, section 4.3.5 (HTTP)](https://datatracker.ietf.org/doc/html/rfc7231#section-4.3.5).
  delete(1 << 3),

  /// FETCH method as specified in [RFC 8132, section 2 (CoAP)](https://datatracker.ietf.org/doc/html/rfc8132#section-2).
  ///
  /// Not available for HTTP.
  fetch(1 << 4),

  /// PATCH method as specified in [RFC 8132, section 3 (CoAP)](https://datatracker.ietf.org/doc/html/rfc8132#section-3).
  ///
  /// Not available for HTTP.
  patch(1 << 5),

  /// iPATCH method as specified in [RFC 8132, section 3 (CoAP)](https://datatracker.ietf.org/doc/html/rfc8132#section-3).
  ///
  /// Not available for HTTP.
  ipatch(1 << 6),

  /// GET method as specified in [RFC 7252, section 5.8.1 (CoAP)](https://datatracker.ietf.org/doc/html/rfc7252#section-5.8.1)
  /// and [RFC 7231, section 4.3.1 (HTTP)](https://datatracker.ietf.org/doc/html/rfc7231#section-4.3.1),
  /// intended for use in [Dynamic Resource Creation](https://datatracker.ietf.org/doc/html/draft-ietf-ace-aif#section-2.3).
  dynamicGet(1 << 32),

  /// POST method as specified in [RFC 7252, section 5.8.2 (CoAP)](https://datatracker.ietf.org/doc/html/rfc7252#section-5.8.2)
  /// and [RFC 7231, section 4.3.3 (HTTP)](https://datatracker.ietf.org/doc/html/rfc7231#section-4.3.3),
  /// intended for use in [Dynamic Resource Creation](https://datatracker.ietf.org/doc/html/draft-ietf-ace-aif#section-2.3).
  dynamicPost(1 << 33),

  /// PUT method as specified in [RFC 7252, section 5.8.3 (CoAP)](https://datatracker.ietf.org/doc/html/rfc7252#section-5.8.3)
  /// and [RFC 7231, section 4.3.4 (HTTP)](https://datatracker.ietf.org/doc/html/rfc7231#section-4.3.4),
  /// intended for use in [Dynamic Resource Creation](https://datatracker.ietf.org/doc/html/draft-ietf-ace-aif#section-2.3).
  dynamicPut(1 << 34),

  /// DELETE method as specified in [RFC 7252, section 5.8.4 (CoAP)](https://datatracker.ietf.org/doc/html/rfc7252#section-5.8.4)
  /// and [RFC 7231, section 4.3.5 (HTTP)](https://datatracker.ietf.org/doc/html/rfc7231#section-4.3.5),
  /// intended for use in [Dynamic Resource Creation](https://datatracker.ietf.org/doc/html/draft-ietf-ace-aif#section-2.3).
  dynamicDelete(1 << 35),

  /// FETCH method as specified in [RFC 8132, section 2 (CoAP)](https://datatracker.ietf.org/doc/html/rfc8132#section-2),
  /// intended for use in [Dynamic Resource Creation](https://datatracker.ietf.org/doc/html/draft-ietf-ace-aif#section-2.3).
  ///
  /// Not available for HTTP.
  dynamicFetch(1 << 36),

  /// PATCH method as specified in [RFC 8132, section 3 (CoAP)](https://datatracker.ietf.org/doc/html/rfc8132#section-3),
  /// intended for use in [Dynamic Resource Creation](https://datatracker.ietf.org/doc/html/draft-ietf-ace-aif#section-2.3).
  ///
  /// Not available for HTTP.
  dynamicPatch(1 << 37),

  /// iPATCH method as specified in [RFC 8132, section 3 (CoAP)](https://datatracker.ietf.org/doc/html/rfc8132#section-3),
  /// intended for use in [Dynamic Resource Creation](https://datatracker.ietf.org/doc/html/draft-ietf-ace-aif#section-2.3).
  ///
  /// Not available for HTTP.
  dynamicIpatch(1 << 38);

  @override
  final int cbor;

  /// Creates a new [AifRestMethod] instance from the given CBOR label.
  const AifRestMethod(this.cbor);

  /// Creates a new [AifRestMethod] instance using the given CBOR [value].
  static Iterable<AifRestMethod> fromCborValue(CborValue value) {
    final int cborInt = CborSerializableEnum.valueToInt(value);
    return AifRestMethod.values.where((e) => (e.cbor & cborInt) != 0);
  }
}

/// An element as part of an [AifScope], consisting of a path and a set
/// of permissions which are specified as a set of REST methods.
///
/// See [AifScope] for more information and a usage example.
///
/// Can also be used as the single member of a [LibdcafScope].
class AifScopeElement extends CborSerializable {
  /// Identifier for the object of this scope element,
  /// given as a URI of a resource on a CoAP server.
  ///
  /// Refer to [section 2 of `draft-ietf-ace-aif`](https://datatracker.ietf.org/doc/html/draft-ietf-ace-aif#section-2)
  /// for specification details.
  String path;

  /// Permissions for the object (identified by [path])
  /// of this scope element, given as a set of REST (CoAP or HTTP) methods.
  ///
  /// Refer to [section 2 of `draft-ietf-ace-aif`](https://datatracker.ietf.org/doc/html/draft-ietf-ace-aif#section-2)
  /// for specification details.
  HashSet<AifRestMethod> permissions;

  /// Creates a new instance of [AifScopeElement].
  AifScopeElement(this.path, Iterable<AifRestMethod> permissions)
      : permissions = HashSet.from(permissions);

  /// Creates a new instance of [AifScopeElement] from the given CBOR [list].
  AifScopeElement.fromValue(CborList list)
      : this((list.first as CborString).toString(),
            AifRestMethod.fromCborValue(list.last));

  @override
  CborValue toCborValue() {
    return CborList([
      CborString(path),
      CborSmallInt(permissions.isEmpty
          ? 0
          : permissions
              .map((e) => e.cbor)
              .reduce((value, element) => value | element))
    ]);
  }

  @override
  String toString() {
    return 'AifScopeElement{path: $path, permissions: $permissions}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AifScopeElement &&
          runtimeType == other.runtimeType &&
          path == other.path &&
          SetEquality<AifRestMethod>().equals(permissions, other.permissions);

  @override
  int get hashCode => path.hashCode ^ permissions.hashCode;
}

/// A scope encoded using the
/// [Authorization Information Format (AIF) for ACE](https://datatracker.ietf.org/doc/html/draft-ietf-ace-aif).
///
/// More specifically, this uses the specific instantiation of AIF intended
/// for REST resources which are identified by URI paths, as described in
/// [`draft-ietf-ace-aif`, section 2.1](https://datatracker.ietf.org/doc/html/draft-ietf-ace-aif#section-2.1).
/// An AIF-encoded scope consists of [AifScopeElement]s, each describing
/// a URI path (the object of the scope) and a set of REST methods (the
/// permissions of the scope).
///
/// Note that the [`libdcaf` implementation](https://gitlab.informatik.uni-bremen.de/DCAF/dcaf)
/// uses a format in which only a single [AifScopeElement] is used in the scope.
/// To use this format, please use the [LibdcafScope] instead.
///
/// # Example
/// For example, say you want to create a scope consisting of two elements:
/// - A scope for the local path `/restricted`,
///   consisting only of "read-only" methods GET and FETCH.
/// - A scope for the local path `/unrestricted`, allowing every method.
///
/// This would look like the following:
/// ```dart
/// final restricted = AifScopeElement("restricted",
///                                   [AifRestMethod.get, AifRestMethod.fetch);
/// final unrestricted = AifScopeElement("unrestricted", AifRestMethod.values);
/// final scope = AifScope([restricted, unrestricted]);
/// ```
///
/// ## Encoding
/// The scope from the example above would be encoded like this (given in JSON):
/// ```json
/// [["restricted", 17], ["unrestricted", 545460846719]]
/// ```
/// As specified in [`draft-ietf-ace-aif`, section 3](https://datatracker.ietf.org/doc/html/draft-ietf-ace-aif#section-3),
/// `GET` to `iPATCH` are encoded from 2<sup>0</sup> to 2<sup>6</sup>,
/// while the dynamic variants go from 2<sup>32</sup> to 2<sup>38</sup>. This
/// is why in `restricted`, the number equals 17 (2<sup>0</sup> +
/// 2<sup>4</sup>), and in `unrestricted` equals the sum of all these numbers.
/// [AifRestMethod] does the work on this (including encoding and
/// decoding bitmasks given as numbers), clients do not need to handle this
/// themselves and can simply use its methods.
class AifScope extends Scope {
  /// The elements of this scope, specified by a path and a set of permissions.
  ///
  /// See the documentation of [AifScopeElement] for details.
  List<AifScopeElement> elements;

  /// Creates a new [AifScope] instance.
  AifScope(this.elements);

  /// Creates a new [AifScope] instance from the given CBOR [list].
  AifScope.fromValue(CborList list)
      : this(
            list.map((e) => AifScopeElement.fromValue(e as CborList)).toList());

  @override
  CborValue toCborValue() {
    return CborList.of(elements.map((e) => e.toCborValue()));
  }

  @override
  String toString() {
    return 'AifScope{elements: $elements}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AifScope &&
          runtimeType == other.runtimeType &&
          elements.equals(other.elements);

  @override
  int get hashCode => elements.hashCode;
}

/// A scope encoded using the [Authorization Information Format (AIF) for ACE](https://datatracker.ietf.org/doc/html/draft-ietf-ace-aif)
/// as in [AifScope], but only consisting of a single [AifScopeElement]
/// instead of an array of them.
///
/// This is done to provide interoperability support for the
/// [`libdcaf` implementation](https://gitlab.informatik.uni-bremen.de/DCAF/dcaf),
/// which currently uses this format to describe its scopes.
///
/// *This struct is only provided to allow compatability with the
/// [`libdcaf` implementation](https://gitlab.informatik.uni-bremen.de/DCAF/dcaf)---
/// if you don't require this, simply use the spec-compliant
/// [AifScope] instead, as it provides a
/// superset of the functionality of this type.*
///
/// Refer to [AifScope] for details on the format,
/// and "Difference to [AifScope]" for details on the difference to it.
///
/// # Example
/// To create a scope allowing only the GET and FETCH methods
/// to be called the local URI `readonly`:
/// ```dart
/// final scope = LibdcafScope("readonly",
///                            [AifRestMethod.get, AifRestMethod.fetch]);
/// ```
///
/// # Difference to [AifScope]
/// The only difference here is that while [AifScope] would
/// encode the above example like so (given as JSON):
/// ```json
/// [["readonly", 17]]
/// ```
/// [LibdcafScope] would encode it like so:
/// ```json
/// ["readonly", 17]
/// ```
/// Note that this implies that the latter only allows
/// a single scope element (i.e. a single row in the access matrix) to be
/// specified, while the former allows multiple elements.
/// As mentioned in the beginning, only use this struct if you
/// need to communicate with libdcaf, use [AifScope] in all other
/// cases.
class LibdcafScope extends Scope {
  /// The [AifScopeElement] of this scope.
  ///
  /// Refer to [AifScopeElement] for details.
  AifScopeElement element;

  /// Creates a new [LibdcafScope] instance.
  LibdcafScope(this.element);

  /// Creates a new [LibdcafScope] instance from the given CBOR [list].
  LibdcafScope.fromValue(CborList list) : this(AifScopeElement.fromValue(list));

  @override
  CborValue toCborValue() {
    return element.toCborValue();
  }

  @override
  String toString() {
    return 'LibdcafScope{element: $element}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibdcafScope &&
          runtimeType == other.runtimeType &&
          element == other.element;

  @override
  int get hashCode => element.hashCode;
}
