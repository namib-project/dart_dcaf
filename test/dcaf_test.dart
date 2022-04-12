import 'package:dcaf/dcaf.dart';
import 'package:dcaf/src/aif.dart';
import 'package:dcaf/src/cbor.dart';
import 'package:dcaf/src/scope.dart';
import 'package:test/test.dart';
import 'package:hex/hex.dart';
import 'package:collection/collection.dart';

void expectSerDe<T extends CborSerializable>(T value, String expectedHex,
    T Function(List<int> serialized) fromSerialized) {
  final serialized = value.serialize();
  print("Result: ${HEX.encode(serialized)}\nOriginal: $value");
  assert(serialized.equals(HEX.decode(expectedHex)));

  final T decoded = fromSerialized(serialized);
  print("Decoded: $decoded");
  assert(value == decoded);
}

void expectSerDeHint(AuthServerRequestCreationHint hint, String expectedHex) =>
    expectSerDe(
        hint, expectedHex, AuthServerRequestCreationHint.fromSerialized);

void main() {
  group('Creation Hint', () {
    setUp(() {
      // Additional setup goes here.
    });

    test('Text Scope', () {
      final hint = AuthServerRequestCreationHint(
          "coaps://as.example.com/token",
          null,
          "coaps://rs.example.com",
          TextScope("rTempC"),
          HEX.decode("e0a156bb3f"));
      expectSerDeHint(hint,
          "a401781c636f6170733a2f2f61732e6578616d706c652e636f6d2f746f6b656e0576636f6170733a2f2f72732e6578616d706c652e636f6d09667254656d7043182745e0a156bb3f");
    });

    test('Binary Scope', () {
      final hint = AuthServerRequestCreationHint(
          "coaps://as.example.com/token",
          null,
          "coaps://rs.example.com",
          BinaryScope([0xDC, 0xAF]),
          HEX.decode("e0a156bb3f"));
      expectSerDeHint(hint,
          "A401781C636F6170733A2F2F61732E6578616D706C652E636F6D2F746F6B656E0576636F6170733A2F2F72732E6578616D706C652E636F6D0942DCAF182745E0A156BB3F");
    });

    test('AIF Scope', () {
      final hint = AuthServerRequestCreationHint(
          "coaps://as.example.com/token",
          null,
          "coaps://rs.example.com",
          AifScope(List.of([
            AifScopeElement("/s/temp", List.of([AifRestMethod.GET])),
            AifScopeElement("/a/led", List.of([AifRestMethod.GET, AifRestMethod.PUT]))
          ])),
          HEX.decode("e0a156bb3f"));
      expectSerDeHint(hint, "A401781C636F6170733A2F2F61732E6578616D706C652E636F6D2F746F6B656E0576636F6170733A2F2F72732E6578616D706C652E636F6D098282672F732F74656D700182662F612F6C656405182745E0A156BB3F");
    });

    test('libdcaf Scope', () {
      final hint = AuthServerRequestCreationHint(
          "coaps://as.example.com/token",
          null,
          "coaps://rs.example.com",
          LibdcafScope(AifScopeElement("/x/none", List.empty())),
          HEX.decode("e0a156bb3f"));
      expectSerDeHint(hint, "A401781C636F6170733A2F2F61732E6578616D706C652E636F6D2F746F6B656E0576636F6170733A2F2F72732E6578616D706C652E636F6D0982672F782F6E6F6E6500182745E0A156BB3F");
    });
  });
}
