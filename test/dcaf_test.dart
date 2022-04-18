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

// ignore_for_file: lines_longer_than_80_chars

import 'package:cbor/cbor.dart';
import 'package:dcaf/dcaf.dart';
import 'package:dcaf/src/ace_profile.dart';
import 'package:dcaf/src/aif.dart';
import 'package:dcaf/src/cbor.dart';
import 'package:dcaf/src/cose/cose_key.dart';
import 'package:dcaf/src/cose/key_type.dart';
import 'package:dcaf/src/endpoints/error_response.dart';
import 'package:dcaf/src/endpoints/token_request.dart';
import 'package:dcaf/src/endpoints/token_response.dart';
import 'package:dcaf/src/error_code.dart';
import 'package:dcaf/src/grant_type.dart';
import 'package:dcaf/src/pop.dart';
import 'package:dcaf/src/scope.dart';
import 'package:hex/hex.dart';
import 'package:test/test.dart';

void expectSerDe<T extends CborSerializable>(T value, String expectedHex,
    T Function(List<int> serialized) fromSerialized) {
  final serialized = value.serialize();
  print("Result: ${HEX.encode(serialized)}\nOriginal: $value");
  expect(serialized, equals(HEX.decode(expectedHex)));

  final T decoded = fromSerialized(serialized);
  print("Decoded: $decoded");
  expect(value, equals(decoded));
}

void expectSerDeHint(AuthServerRequestCreationHint hint, String expectedHex) =>
    expectSerDe(
        hint, expectedHex, AuthServerRequestCreationHint.fromSerialized);

void expectSerDeRequest(AccessTokenRequest request, String expectedHex) =>
    expectSerDe(request, expectedHex, AccessTokenRequest.fromSerialized);

void expectSerDeResponse(AccessTokenResponse response, String expectedHex) =>
    expectSerDe(response, expectedHex, AccessTokenResponse.fromSerialized);

void expectSerDeError(ErrorResponse response, String expectedHex) =>
    expectSerDe(response, expectedHex, ErrorResponse.fromSerialized);

void main() {
  group('Scope', () {
    group('Text Scope', () {
      test('Simple Text Scopes', () {
        final simple = TextScope("this is a test");
        expect(simple.elements, equals(["this", "is", "a", "test"]));

        final single = TextScope("single");
        expect(single.elements, equals(["single"]));

        final third = TextScope("another quick test");
        expect(third.elements, equals(["another", "quick", "test"]));
      });

      test('Empty Text Scopes', () {
        final emptyInputs = ["    ", " ", ""];

        for (final input in emptyInputs) {
          expect(() => TextScope(input), throwsFormatException);
        }
      });

      test('Invalid Spaces in Text Scope', () {
        final invalid = [
          "space at the end ",
          "spaces at the end   ",
          " space at the start",
          "   spaces at the start",
          " spaces at both ends ",
          "   spaces at both ends    ",
          "spaces   in the       middle",
          "   spaces   wherever  you    look   ",
        ];
        for (final input in invalid) {
          expect(() => TextScope(input), throwsFormatException);
        }
      });

      test('Invalid Characters in Text Scope', () {
        final invalid = [
          "\"",
          "\\",
          "a \" in between",
          "a \\ in between",
          " \" ",
          " \\ ",
          "within\"word",
          "within\\word",
        ];
        for (final input in invalid) {
          expect(() => TextScope(input), throwsFormatException);
        }
      });
    });

    group('Binary Scope', () {
      test('Normal Elements', () {
        final single = BinaryScope([0]);
        expect(
            single.elements(0x20),
            equals([
              [0]
            ]));

        final simple1 = BinaryScope([0, 1, 2]);
        expect(
            simple1.elements(0x20),
            equals([
              [0, 1, 2]
            ]));
        expect(
            simple1.elements(1),
            equals([
              [0],
              [2]
            ]));

        final simple2 = BinaryScope([0xDC, 0x20, 0xAF]);
        expect(
            simple2.elements(0x20),
            equals([
              [0xDC],
              [0xAF]
            ]));
        expect(
            simple2.elements(0),
            equals([
              [0xDC, 0x20, 0xAF]
            ]));

        final simple3 =
            BinaryScope([0xDE, 0xAD, 0xBE, 0xEF, 0, 0xDC, 0xAF, 0, 1]);
        expect(
            simple3.elements(0),
            equals([
              [0xDE, 0xAD, 0xBE, 0xEF],
              [0xDC, 0xAF],
              [1],
            ]));
        expect(
            simple3.elements(0xEF),
            equals([
              [0xDE, 0xAD, 0xBE],
              [0, 0xDC, 0xAF, 0, 1]
            ]));
        expect(
            simple3.elements(2),
            equals([
              [0xDE, 0xAD, 0xBE, 0xEF, 0, 0xDC, 0xAF, 0, 1]
            ]));
      });

      test('Empty Elements', () {
        expect(() => BinaryScope([]), throwsFormatException);
        // Assuming 0 is separator
        final emptyLists = [
          [0],
          [0, 0],
          [0, 0, 0]
        ];
        for (final empty in emptyLists) {
          expect(() => BinaryScope(empty).elements(0), throwsFormatException);
          // If the separator is something else,
          // the result should just contain the list as a single element.
          expect(BinaryScope(empty).elements(1), equals([empty]));
        }
      });

      test('Invalid Separators', () {
        final invalids = [
          [0xDC, 0xAF, 0],
          [0xDC, 0xAF, 0, 0],
          [0, 0xDC, 0xAF],
          [0, 0, 0xDC, 0xAF],
          [0, 0xDC, 0xAF, 0],
          [0, 0, 0xDC, 0xAF, 0, 0],
          [0, 0, 0xDC, 0xAF, 0, 0],
          [0xDC, 0, 0, 0xAF],
          [0, 0xDC, 0, 0xAF, 0],
          [0, 0, 0xDC, 0, 0xAF, 0],
          [0, 0xDC, 0, 0, 0xAF, 0],
          [0, 0xDC, 0, 0xAF, 0, 0],
          [0, 0, 0xDC, 0, 0, 0xAF, 0, 0],
        ];
        for (final invalid in invalids) {
          expect(() => BinaryScope(invalid).elements(0), throwsFormatException);
          // If the separator is something else,
          // the result should just contain the list as a single element.
          expect(BinaryScope(invalid).elements(1), equals([invalid]));
        }
      });
    });

    final restricted = AifScopeElement("restricted", [AifRestMethod.get]);
    final dynamic = AifScopeElement(
        "dynamic", [AifRestMethod.dynamicGet, AifRestMethod.dynamicFetch]);
    final all = AifScopeElement("all", AifRestMethod.values);
    final none = AifScopeElement("none", []);

    group('AIF Scope', () {
      test('Normal Elements', () {
        final single = AifScope([restricted]);
        expect(single.elements, equals([restricted]));
        final multiple = AifScope([dynamic, none, all]);
        expect(multiple.elements, equals([dynamic, none, all]));
      });

      test('AIF Encoding', () {
        // This tests the encoding of the scope using the example
        // given in Figure 5 of the AIF draft.
        final cbor = HEX
            .decode("8382672F732F74656D700182662F612F6C65640582652F64746C7302");
        final expected = AifScope([
          AifScopeElement("/s/temp", [AifRestMethod.get]),
          AifScopeElement("/a/led", [AifRestMethod.put, AifRestMethod.get]),
          AifScopeElement("/dtls", [AifRestMethod.post])
        ]);
        expect(
            AifScope.fromValue(cborDecode(cbor) as CborList), equals(expected));
      });
    });

    group('Libdcaf Scope', () {
      test('Normal Element', () {
        for (final element in [restricted, dynamic, all, none]) {
          expect(LibdcafScope(element).element, equals(element));
        }
      });

      test('Empty Element', () {
        final serialized = [0x80]; // empty CBOR array (not allowed!)
        expect(() => LibdcafScope.fromValue(cborDecode(serialized) as CborList),
            throwsStateError);
      });
    });
  });

  group('Creation Hint', () {
    test('Text Scope Hint', () {
      final hint = AuthServerRequestCreationHint(
          authorizationServer: "coaps://as.example.com/token",
          keyID: null,
          audience: "coaps://rs.example.com",
          scope: TextScope("rTempC"),
          clientNonce: HEX.decode("e0a156bb3f"));
      expectSerDeHint(hint,
          "a401781c636f6170733a2f2f61732e6578616d706c652e636f6d2f746f6b656e0576636f6170733a2f2f72732e6578616d706c652e636f6d09667254656d7043182745e0a156bb3f");
    });

    test('Binary Scope Hint', () {
      final hint = AuthServerRequestCreationHint(
          authorizationServer: "coaps://as.example.com/token",
          keyID: null,
          audience: "coaps://rs.example.com",
          scope: BinaryScope([0xDC, 0xAF]),
          clientNonce: HEX.decode("e0a156bb3f"));
      expectSerDeHint(hint,
          "A401781C636F6170733A2F2F61732E6578616D706C652E636F6D2F746F6B656E0576636F6170733A2F2F72732E6578616D706C652E636F6D0942DCAF182745E0A156BB3F");
    });

    test('AIF Scope Hint', () {
      final hint = AuthServerRequestCreationHint(
          authorizationServer: "coaps://as.example.com/token",
          keyID: null,
          audience: "coaps://rs.example.com",
          scope: AifScope(List.of([
            AifScopeElement("/s/temp", [AifRestMethod.get]),
            AifScopeElement(
                "/a/led", List.of([AifRestMethod.get, AifRestMethod.put]))
          ])),
          clientNonce: HEX.decode("e0a156bb3f"));
      expectSerDeHint(hint,
          "A401781C636F6170733A2F2F61732E6578616D706C652E636F6D2F746F6B656E0576636F6170733A2F2F72732E6578616D706C652E636F6D098282672F732F74656D700182662F612F6C656405182745E0A156BB3F");
    });

    test('libdcaf Scope Hint', () {
      final hint = AuthServerRequestCreationHint(
          authorizationServer: "coaps://as.example.com/token",
          keyID: null,
          audience: "coaps://rs.example.com",
          scope: LibdcafScope(AifScopeElement("/x/none", List.empty())),
          clientNonce: HEX.decode("e0a156bb3f"));
      expectSerDeHint(hint,
          "A401781C636F6170733A2F2F61732E6578616D706C652E636F6D2F746F6B656E0576636F6170733A2F2F72732E6578616D706C652E636F6D0982672F782F6E6F6E6500182745E0A156BB3F");
    });
  });

  group('Access Token Request', () {
    test('Symmetric Request', () {
      final request = AccessTokenRequest(
        clientId: "myclient",
        audience: "tempSensor4711"
      );
      expectSerDeRequest(
          request, "A2056E74656D7053656E736F72343731311818686D79636C69656E74");
    });

    test('Binary Request', () {
      final request = AccessTokenRequest(
          clientId: "myclient",
          audience: "tempSensor4711",
          scope: BinaryScope([0xDC, 0xAF]));
      expectSerDeRequest(request,
          "A3056E74656D7053656E736F72343731310942DCAF1818686D79636C69656E74");
    });

    test('AIF request', () {
      final request = AccessTokenRequest(
          clientId: "testclient",
          audience: "coaps://localhost",
          scope: AifScope([
            AifScopeElement("restricted", [AifRestMethod.get]),
            AifScopeElement("extended",
                [AifRestMethod.get, AifRestMethod.put, AifRestMethod.post]),
            AifScopeElement("dynamic", [
              AifRestMethod.dynamicGet,
              AifRestMethod.dynamicPut,
              AifRestMethod.dynamicPost
            ]),
            AifScopeElement("unrestricted", AifRestMethod.values),
            AifScopeElement("useless", []),
          ]));
      expectSerDeRequest(request,
          "A30571636F6170733A2F2F6C6F63616C686F73740985826A72657374726963746564018268657874656E64656407826764796E616D69631B0000000700000000826C756E726573747269637465641B0000007F0000007F82677573656C6573730018186A74657374636C69656E74");
    });

    test('libdcaf request', () {
      final request = AccessTokenRequest(
          audience: "coaps://localhost",
          scope: LibdcafScope(
            AifScopeElement("restricted", [AifRestMethod.get]),
          ),
          issuer: "coaps://127.0.0.1:7744/authorize");
      expectSerDeRequest(request,
          "A3017820636F6170733A2F2F3132372E302E302E313A373734342F617574686F72697A650571636F6170733A2F2F6C6F63616C686F737409826A7265737472696374656401");
    });

    test('Reference request', () {
      final request = AccessTokenRequest(
          clientId: "myclient",
          audience: "valve424",
          scope: TextScope("read"),
          reqCnf: KeyId([0xea, 0x48, 0x34, 0x75, 0x72, 0x4c, 0xd7, 0x75]));
      expectSerDeRequest(request,
          "A404A10348EA483475724CD775056876616C76653432340964726561641818686D79636C69656E74");
    });

    test('Asymmetric request', () {
      final request = AccessTokenRequest(
          clientId: "myclient",
          reqCnf: PlainCoseKey(CoseKey(keyType: KeyType.ec2, keyId: [
            0x11
          ], parameters: {
            -1: CborSmallInt(1), // Curve: P-256
            -2: CborBytes(HEX.decode('d7cc072de' // x parameter
                '2205bdc1537a543d53c60a6acb62eccd890c7fa27c9e354089bbe13')),
            -3: CborBytes(HEX.decode('f95e1d4b8' // y parameter
                '51a2cc80fff87d8e23f22afb725d535e515d020731e79a3b4e47120'))
          })));
      expectSerDeRequest(request,
          "A204A101A501020241112001215820D7CC072DE2205BDC1537A543D53C60A6ACB62ECCD890C7FA27C9E354089BBE13225820F95E1D4B851A2CC80FFF87D8E23F22AFB725D535E515D020731E79A3B4E471201818686D79636C69656E74");
    });

    test('Request with other fields', () {
      final request = AccessTokenRequest(
          clientId: "myclient",
          redirectUri: "coaps://server.example.com",
          grantType: GrantType.clientCredentials,
          scope: BinaryScope([0xDC, 0xAF]),
          includeAceProfile: true,
          clientNonce: [0, 1, 2, 3, 4]);
      expectSerDeRequest(request,
          "A60942DCAF1818686D79636C69656E74181B781A636F6170733A2F2F7365727665722E6578616D706C652E636F6D1821021826F61827450001020304");
    });
  });

  group("Access Token Response", () {
    test("AIF Response", () {
      final response = AccessTokenResponse(
          accessToken: [0xDC, 0xAF],
          scope: AifScope([
            AifScopeElement("restricted", [AifRestMethod.get]),
            AifScopeElement("extended",
                [AifRestMethod.get, AifRestMethod.put, AifRestMethod.post]),
            AifScopeElement("dynamic", [
              AifRestMethod.dynamicGet,
              AifRestMethod.dynamicPut,
              AifRestMethod.dynamicPost
            ]),
            AifScopeElement("unrestricted", AifRestMethod.values),
            AifScopeElement("useless", [])
          ]));
      expectSerDeResponse(response,
          "A20142DCAF0985826A72657374726963746564018268657874656E64656407826764796E616D69631B0000000700000000826C756E726573747269637465641B0000007F0000007F82677573656C65737300");
    });

    test("Libdcaf Response + Timestamp", () {
      final response = AccessTokenResponse(
          accessToken: [0xDC, 0xAF],
          scope:
              LibdcafScope(AifScopeElement("restricted", [AifRestMethod.get])),
          // Note: Since whole seconds are used, setting milliseconds will fail.
          issuedAt: DateTime.utc(2022, 2, 22, 22, 22, 22, 0, 0));
      expectSerDeResponse(
          response, "A30142DCAF061A6215621E09826A7265737472696374656401");

      final otherResponse = AccessTokenResponse(
          accessToken: [0xDC, 0xAF],
          scope: LibdcafScope(AifScopeElement("empty", [])),
          // Note: Since whole seconds are used, setting milliseconds will fail.
          issuedAt: DateTime.utc(1970));
      expectSerDeResponse(otherResponse, "A30142DCAF0600098265656D70747900");
    });

    test("Normal Response", () {
      final response = AccessTokenResponse(
          accessToken: HEX.decode("4a5015df686428"),
          aceProfile: AceProfile.coapDtls,
          expiresIn: 3600,
          cnf: PlainCoseKey(CoseKey(keyType: KeyType.symmetric, keyId: [
            0x84,
            0x9b,
            0x57,
            0x86,
            0x45,
            0x7c
          ], parameters: {
            -1: CborBytes([
              0x84,
              0x9b,
              0x57,
              0x86,
              0x45,
              0x7c,
              0x14,
              0x91,
              0xbe,
              0x3a,
              0x76,
              0xdc,
              0xea,
              0x6c,
              0x42,
              0x71,
              0x08,
            ])
          })));
      expectSerDeResponse(response,
          "A401474A5015DF68642802190E1008A101A301040246849B5786457C2051849B5786457C1491BE3A76DCEA6C427108182601");
    });
  });

  group('Error Response', () {

    test('Simple Error', () {
      final error = ErrorResponse(
          error: ErrorCode.unauthorizedClient,
          description: "You are not authorized to receive this token.",
          uri: "https://http.cat/401");
      expectSerDeError(error, "A3181E04181F782D596F7520617265206E6F7420617574686F72697A656420746F2072656365697665207468697320746F6B656E2E18207468747470733A2F2F687474702E6361742F343031");
    });
  });
}
