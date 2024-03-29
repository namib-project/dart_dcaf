# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 0.1.1 --- 2023-07-08
- Updated Dart SDK version constraints to include Dart 3.0.
- Includes changes from #1 (thanks, @JKRhb!)
    - Updated `cbor` dependency to 6.0.0.
    - Replaced deprecated linting rules.
    - Added GitHub Actions workflow.

## 0.1.0 --- 2022-05-12

### Changed
- Updated Dart SDK to stable version of 2.17.
- Moved package out of pre-release status.

## 0.1.0-pre2 --- 2022-05-09

### Fixed
- Formatting was wrong in a few files.
- Package description was expanded to follow pub.dev guidelines.

## 0.1.0-pre --- 2022-04-27

### Added
- CBOR de-/serializable model of the ACE-OAuth framework has been added:
    - Binary-, text-encoded and [AIF](https://datatracker.ietf.org/doc/html/draft-ietf-ace-aif)-scopes
      - A variant of the AIF format specific to [libdcaf](https://gitlab.informatik.uni-bremen.de/DCAF/dcaf) is also supported
    - Access token requests and responses
    - Authorization server request creation hints
    - Error responses
    - Various smaller types (`CoseKey`, `GrantType`, `ProofOfPossessionKey`, `TokenType`...)
    - Use `serialize()` or `fromSerialized()` to serialize and deserialize these types.
- Pre-release because we depend on the Dart Beta SDK (2.17.0).
