# dart_dcaf

[![pub.dev](https://img.shields.io/pub/v/dcaf?style=for-the-badge)](https://pub.dev/packages/dcaf)

An implementation of the [ACE-OAuth] framework in Dart.

This library implements the ACE-OAuth
(Authentication and Authorization for Constrained Environments
using the OAuth 2.0 Framework) framework as defined in
[`draft-ietf-ace-oauth-authz-46`](https://www.ietf.org/archive/id/draft-ietf-ace-oauth-authz-46.html).
Its main feature is CBOR-(de-)serializable data models such as `AccessTokenRequest`.

## Features
- CBOR de-/serializable model of the ACE-OAuth framework:
  - Binary-, text-encoded and [AIF](https://datatracker.ietf.org/doc/html/draft-ietf-ace-aif)-scopes
    - A variant of the AIF format specific to [libdcaf](https://gitlab.informatik.uni-bremen.de/DCAF/dcaf) is also supported
    - *Note that dynamic REST methods in AIF currently don't (de)serialize correctly on the Web platform!*
  - Access token requests and responses
  - Authorization server request creation hints
  - Error responses
  - Various smaller types (`CoseKey`, `GrantType`, `ProofOfPossessionKey`, `TokenType`...)
  - Use `serialize()` or `fromSerialized()` to serialize and deserialize these types.

> Note that actually transmitting the serialized values (e.g. via CoAP)
is *out of scope* for this library.

## Getting started

**Note that this package is currently in pre-release, mainly because we depend
on Dart 2.17.0, which is still in Beta at the time of writing.**

All you need to do to get started is to add this package to your `pubspec.yaml`.
You can then import it using `import 'package:dcaf/dcaf.dart`.

## Usage

As mentioned, the main feature of this library is ACE-OAuth data models.

[For example](https://www.ietf.org/archive/id/draft-ietf-ace-oauth-authz-46.html#figure-7),
say you (the client) want to request an access token from an
Authorization Server. For this, you'd need to create an `AccessTokenRequest`, 
which has to include at least a `clientId`. We'll also specify an audience,
a scope (using `TextScope`---note that `BinaryScope`s or `AifScope`s would also work), 
as well as a `ProofOfPossessionKey`
(the key the access token should be bound to) in the `reqCnf` field.

Creating, serializing and then de-serializing such
a structure would look like this:
```dart
final request = AccessTokenRequest(
    clientId: "myclient",
    audience: "valve242",
    scope: TextScope("read"),
    reqCnf: KeyId([0xDC, 0xAF]));
final List<int> serialized = request.serialize();
assert(AccessTokenRequest.fromSerialized(serialized) == request);
```

Its CBOR representation (using CBOR diagnostic notation) would look like this:
```text
{
  "client_id" : "myclient",
  "audience" : "valve424",
  "scope" : "read",
  "req_cnf" : {
    "kid" : h'dcaf'
  }
}
```
(Note that abbreviations aren't used here,
so keep in mind that the labels are really integers instead of strings.)

## Additional information

This library is heavily based on [`dcaf-rs`](https://crates.io/crates/dcaf),
a similar implementation of the ACE-OAuth framework in Rust, which is
intended for all actors in the ACE-OAuth protocol flow
(e.g. Authorization Servers too). In contrast, this library is mainly
intended for the "Client", hence missing some features present in `dcaf-rs`.
Whenever I update `dcaf-rs`, I will try to add the new functionality to 
this library as well (if applicable).

The name DCAF was chosen because eventually, it's planned for this
library to support functionality from the [Delegated CoAP Authentication and
Authorization Framework (DCAF)](https://dcaf.science/)
specified in [`draft-gerdes-ace-dcaf-authorize`](https://datatracker.ietf.org/doc/html/draft-gerdes-ace-dcaf-authorize-04)
(which was specified prior to ACE-OAuth and inspired many design
choices in it)---specifically, it's planned to support using a CAM
(Client Authorization Manager)
instead of just a SAM (Server Authorization Manager),
as is done in ACE-OAuth.
Compatibility with the existing [DCAF implementation in C](https://gitlab.informatik.uni-bremen.de/DCAF/dcaf)
(which we'll call `libdcaf` to disambiguate from `dcaf` referring
to this library) is also an additional design goal, though the primary
objective is still to support ACE-OAuth.

## License

Licensed under either of

* Apache License, Version 2.0
  ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
* MIT license
  ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)

at your option.

## Contribution

Unless you explicitly state otherwise, any contribution intentionally submitted
for inclusion in the work by you, as defined in the Apache-2.0 license, shall be
dual licensed as above, without any additional terms or conditions.

## Maintainers

This project is currently maintained by the following developers:

|      Name      |    Email Address     |            GitHub Username            |
|:--------------:|:--------------------:|:-------------------------------------:|
| Falko Galperin | falko1@uni-bremen.de | [falko17](https://github.com/falko17) |


[ACE-OAuth]: https://www.ietf.org/archive/id/draft-ietf-ace-oauth-authz-46.html
