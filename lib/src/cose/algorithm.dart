import 'package:cbor/cbor.dart';
import 'package:dcaf/src/cbor.dart';

enum Algorithm with CborIntSerializable {
  rs1(-65535),
  walnutDsa(-260),
  rs512(-259),
  rs384(-258),
  rs256(-257),
  es256k(-47),
  hssLms(-46),
  shake256(-45),
  sha512(-44),
  sha384(-43),
  rsaesOaepSha512(-42),
  rsaesOaepSha256(-41),
  rsaesOaepRfc8017(-40),
  ps512(-39),
  ps384(-38),
  ps256(-37),
  es512(-36),
  es384(-35),
  ecdhSsA256kw(-34),
  ecdhSsA192kw(-33),
  ecdhSsA128kw(-32),
  ecdhEsA256kw(-31),
  ecdhEsA192kw(-30),
  ecdhEsA128kw(-29),
  ecdhSsHkdf512(-28),
  ecdhSsHkdf256(-27),
  ecdhEsHkdf512(-26),
  ecdhEsHkdf256(-25),
  shake128(-18),
  sha512_256(-17),
  sha256(-16),
  sha256_64(-15),
  sha1(-14),
  directHkdfAes256(-13),
  directHkdfAes128(-12),
  directHkdfSha512(-11),
  directHkdfSha256(-10),
  edDsa(-8),
  es256(-7),
  direct(-6),
  a256kw(-5),
  a192kw(-4),
  a128kw(-3),
  a128gcm(1),
  a192gcm(2),
  a256gcm(3),
  hmac256_64(4),
  hmac256_256(5),
  hmac384_384(6),
  hmac512_512(7),
  aesCcm16_64_128(10),
  aesCcm16_64_256(11),
  aesCcm64_64_128(12),
  aesCcm64_64_256(13),
  aesMac128_64(14),
  aesMac256_64(15),
  chaCha20Poly1305(24),
  aesMac128_128(25),
  aesMac256_128(26),
  aesCcm16_128_128(30),
  aesCcm16_128_256(31),
  aesCcm64_128_128(32),
  aesCcm64_128_256(33),
  ivGeneration(34);

  @override
  final int cbor;

  const Algorithm(this.cbor);

  static Algorithm fromCborValue(CborValue value) {
    final valueInt = CborIntSerializable.valueToInt(value);
    return Algorithm.values.singleWhere((e) => e.cbor == valueInt);
  }
}
