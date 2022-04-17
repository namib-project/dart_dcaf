import 'package:cbor/cbor.dart';
import 'package:dcaf/src/cbor.dart';

/// COSE algorithms as described in
/// [`draft-ietf-cose-rfc8152bis-algs`](https://datatracker.ietf.org/doc/draft-ietf-cose-rfc8152bis-algs/)
/// and [`draft-ietf-cose-hash-algs`](https://datatracker.ietf.org/doc/draft-ietf-cose-hash-algs/09/).
///
/// The values itself are taken from https://www.iana.org/assignments/cose/cose.xhtml.
enum Algorithm with CborSerializableEnum {
  /// RSASSA-PKCS1-v1_5 using SHA-1.
  rs1(-65535),

  /// WalnutDSA signature.
  walnutDsa(-260),

  /// RSASSA-PKCS1-v1_5 using SHA-512.
  rs512(-259),

  /// RSASSA-PKCS1-v1_5 using SHA-384.
  rs384(-258),

  /// RSASSA-PKCS1-v1_5 using SHA-256.
  rs256(-257),

  /// ECDSA using secp256k1 curve and SHA-256.
  es256k(-47),

  /// HSS/LMS hash-based digital signature.
  hssLms(-46),

  /// SHAKE-256 512-bit Hash Value.
  shake256(-45),

  /// SHA-2 512-bit Hash.
  sha512(-44),

  /// SHA-2 384-bit Hash.
  sha384(-43),

  /// RSAES-OAEP w/ SHA-512.
  rsaesOaepSha512(-42),

  /// RSAES-OAEP w/ SHA-256.
  rsaesOaepSha256(-41),

  /// RSAES-OAEP w/ SHA-1.
  rsaesOaepRfc8017(-40),

  /// RSASSA-PSS w/ SHA-512.
  ps512(-39),

  /// RSASSA-PSS w/ SHA-384.
  ps384(-38),

  /// RSASSA-PSS w/ SHA-256.
  ps256(-37),

  /// ECDSA w/ SHA-512.
  es512(-36),

  /// ECDSA w/ SHA-384.
  es384(-35),

  /// ECDH SS w/ Concat KDF and AES Key Wrap w/ 256-bit key.
  ecdhSsA256kw(-34),

  /// ECDH SS w/ Concat KDF and AES Key Wrap w/ 192-bit key.
  ecdhSsA192kw(-33),

  /// ECDH SS w/ Concat KDF and AES Key Wrap w/ 128-bit key.
  ecdhSsA128kw(-32),

  /// ECDH ES w/ Concat KDF and AES Key Wrap w/ 256-bit key.
  ecdhEsA256kw(-31),

  /// ECDH ES w/ Concat KDF and AES Key Wrap w/ 192-bit key.
  ecdhEsA192kw(-30),

  /// ECDH ES w/ Concat KDF and AES Key Wrap w/ 128-bit key.
  ecdhEsA128kw(-29),

  /// ECDH SS w/ HKDF - generate key directly.
  ecdhSsHkdf512(-28),

  /// ECDH SS w/ HKDF - generate key directly.
  ecdhSsHkdf256(-27),

  /// ECDH ES w/ HKDF - generate key directly.
  ecdhEsHkdf512(-26),

  /// ECDH ES w/ HKDF - generate key directly.
  ecdhEsHkdf256(-25),

  /// SHAKE-128 256-bit Hash Value.
  shake128(-18),

  /// SHA-2 512-bit Hash truncated to 256-bits.
  sha512_256(-17),

  /// SHA-2 256-bit Hash.
  sha256(-16),

  /// SHA-2 256-bit Hash truncated to 64-bits.
  sha256_64(-15),

  /// SHA-1 Hash.
  sha1(-14),

  /// Shared secret w/ AES-MAC 256-bit key.
  directHkdfAes256(-13),

  /// Shared secret w/ AES-MAC 128-bit key.
  directHkdfAes128(-12),

  /// Shared secret w/ HKDF and SHA-512.
  directHkdfSha512(-11),

  /// Shared secret w/ HKDF and SHA-256.
  directHkdfSha256(-10),

  /// EdDSA.
  edDsa(-8),

  /// ECDSA w/ SHA-256.
  es256(-7),

  /// Direct use of CEK.
  direct(-6),

  /// AES Key Wrap w/ 256-bit key.
  a256kw(-5),

  /// AES Key Wrap w/ 192-bit key.
  a192kw(-4),

  /// AES Key Wrap w/ 128-bit key.
  a128kw(-3),

  /// "AES-GCM mode w/ 128-bit key.
  a128gcm(1),

  /// "AES-GCM mode w/ 192-bit key.
  a192gcm(2),

  /// "AES-GCM mode w/ 256-bit key.
  a256gcm(3),

  /// HMAC w/ SHA-256 truncated to 64 bits.
  hmac256_64(4),

  /// HMAC w/ SHA-256.
  hmac256_256(5),

  /// HMAC w/ SHA-384.
  hmac384_384(6),

  /// HMAC w/ SHA-512.
  hmac512_512(7),

  /// "AES-CCM mode 128-bit key.
  aesCcm16_64_128(10),

  /// "AES-CCM mode 256-bit key.
  aesCcm16_64_256(11),

  /// "AES-CCM mode 128-bit key.
  aesCcm64_64_128(12),

  /// "AES-CCM mode 256-bit key.
  aesCcm64_64_256(13),

  /// "AES-MAC 128-bit key.
  aesMac128_64(14),

  /// "AES-MAC 256-bit key.
  aesMac256_64(15),

  /// "ChaCha20/Poly1305 w/ 256-bit key.
  chaCha20Poly1305(24),

  /// "AES-MAC 128-bit key.
  aesMac128_128(25),

  /// "AES-MAC 256-bit key.
  aesMac256_128(26),

  /// "AES-CCM mode 128-bit key.
  aesCcm16_128_128(30),

  /// "AES-CCM mode 256-bit key.
  aesCcm16_128_256(31),

  /// "AES-CCM mode 128-bit key.
  aesCcm64_128_128(32),

  /// "AES-CCM mode 256-bit key.
  aesCcm64_128_256(33),

  /// For doing IV generation for symmetric algorithms.
  ivGeneration(34);

  @override
  final int cbor;

  /// Creates a new [Algorithm] instance using the given CBOR value.
  const Algorithm(this.cbor);

  /// Creates a new [Algorithm] instance using the given CBOR [value].
  static Algorithm fromCborValue(CborValue value) {
    final valueInt = CborSerializableEnum.valueToInt(value);
    return Algorithm.values.singleWhere((e) => e.cbor == valueInt);
  }
}
