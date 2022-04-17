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

// ignore_for_file: directives_ordering

/// An implementation of the [ACE-OAuth framework](https://www.ietf.org/archive/id/draft-ietf-ace-oauth-authz-46.html).
///
/// This library implements the ACE-OAuth
/// (Authentication and Authorization for Constrained Environments
/// using the OAuth 2.0 Framework) framework as defined in
/// [`draft-ietf-ace-oauth-authz-46`](https://www.ietf.org/archive/id/draft-ietf-ace-oauth-authz-46.html).
/// Its main feature is CBOR-(de-)serializable data models such as
/// [AccessTokenRequest].
///
/// This library is heavily based on [`dcaf-rs`](https://crates.io/crates/dcaf),
/// a similar implementation of the ACE-OAuth framework in Rust, which is
/// intended for all actors in the ACE-OAuth protocol flow
/// (e.g. Authorization Servers too). In contrast, this library is mainly
/// intended for the "Client", hence missing some features present in `dcaf-rs`.
///
/// Note that actually transmitting the serialized values (e.g. via CoAP)
/// is *out of scope* for this library.
///
/// The name DCAF was chosen because eventually, it's planned for this
/// library to support functionality from the
/// [Delegated CoAP Authentication and Authorization Framework (DCAF)](https://dcaf.science/)
/// specified in [`draft-gerdes-ace-dcaf-authorize`](https://datatracker.ietf.org/doc/html/draft-gerdes-ace-dcaf-authorize-04)
/// (which was specified prior to ACE-OAuth and inspired many design
/// choices in it)---specifically, it's planned to support using a CAM
/// (Client Authorization Manager)
/// instead of just a SAM (Server Authorization Manager),
/// as is done in ACE-OAuth.
/// Compatibility with the existing [DCAF implementation in C](https://gitlab.informatik.uni-bremen.de/DCAF/dcaf)
/// (which we'll call `libdcaf` to disambiguate from `dcaf` referring
/// to this library) is also an additional design goal, though the primary
/// objective is still to support ACE-OAuth.
///
/// # Example
/// As mentioned, the main feature of this library is ACE-OAuth data models.
///
/// [For example](https://www.ietf.org/archive/id/draft-ietf-ace-oauth-authz-46.html#figure-7),
/// say you (the client) want to request an access token from an
/// Authorization Server. For this, you'd need to create an
/// [AccessTokenRequest], which has to include at least a
/// `clientId`. We'll also specify an audience,
/// a scope (using [TextScope]---note that
/// [BinaryScope]s or [AifScope]s would also work), as well as a
/// [ProofOfPossessionKey]
/// (the key the access token should be bound to) in the `reqCnf` field.
///
/// Creating, serializing and then de-serializing such
/// a structure would look like this:
/// ```dart
/// final request = AccessTokenRequest(
///     clientId: "myclient",
///     audience: "valve242",
///     scope: TextScope("read"),
///     reqCnf: KeyId([0xDC, 0xAF]));
/// final List<int> serialized = request.serialize();
/// assert(AccessTokenRequest.fromSerialized(serialized) == request);
/// ```
///
/// # Provided Data Models
///
/// ## Token Endpoint
/// The most commonly used models will probably be the token endpoint's
/// [AccessTokenRequest] and [AccessTokenResponse] described in
/// [section 5.8 of the ACE-OAuth draft](https://www.ietf.org/archive/id/draft-ietf-ace-oauth-authz-46.html#section-5.8).
/// In case of an error, an [ErrorResponse] should be used.
///
/// After an initial Unauthorized Resource Request Message,
/// an [AuthServerRequestCreationHint] can
/// be used to provide additional information to the client, as described in
/// [section 5.3 of the ACE-OAuth draft](https://www.ietf.org/archive/id/draft-ietf-ace-oauth-authz-46.html#section-5.3).
///
/// ## Common Data Types
/// Some types used across multiple scenarios include:
/// - [Scope] (as described in [section 5.8.1 of the ACE-OAuth draft](https://www.ietf.org/archive/id/draft-ietf-ace-oauth-authz-46.html#section-5.8.1)),
///   either as a [TextScope], [BinaryScope], or an [AifScope].
/// - [ProofOfPossessionKey] as specified in [section 3.1 of RFC 8747](https://datatracker.ietf.org/doc/html/rfc8747#section-3.1).
///   For example, this will be used in the access token's `cnf` claim.
library dcaf;

import 'dcaf.dart';

export 'src/endpoints/creation_hint.dart';
export 'src/endpoints/error_response.dart';
export 'src/endpoints/token_request.dart';
export 'src/endpoints/token_response.dart';

export 'src/cose/algorithm.dart';
export 'src/cose/cose_key.dart';
export 'src/cose/key_operation.dart';
export 'src/cose/key_type.dart';

export 'src/ace_profile.dart';
export 'src/aif.dart';
export 'src/error_code.dart';
export 'src/grant_type.dart';
export 'src/pop.dart';
export 'src/scope.dart';
export 'src/token_type.dart';
