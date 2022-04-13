import 'dart:collection';

import 'package:dcaf/dcaf.dart';
import 'package:dcaf/src/aif.dart';
import 'package:dcaf/src/cbor.dart';
import 'package:dcaf/src/endpoints/token_request.dart';
import 'package:dcaf/src/grant_type.dart';
import 'package:dcaf/src/pop.dart';
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

void expectSerDeRequest(AccessTokenRequest request, String expectedHex) =>
    expectSerDe(request, expectedHex, AccessTokenRequest.fromSerialized);

void main() {
  group('Creation Hint', () {
    test('Text Scope', () {
      final hint = AuthServerRequestCreationHint(
          authorizationServer: "coaps://as.example.com/token",
          keyID: null,
          audience: "coaps://rs.example.com",
          scope: TextScope("rTempC"),
          clientNonce: HEX.decode("e0a156bb3f"));
      expectSerDeHint(hint,
          "a401781c636f6170733a2f2f61732e6578616d706c652e636f6d2f746f6b656e0576636f6170733a2f2f72732e6578616d706c652e636f6d09667254656d7043182745e0a156bb3f");
    });

    test('Binary Scope', () {
      final hint = AuthServerRequestCreationHint(
          authorizationServer: "coaps://as.example.com/token",
          keyID: null,
          audience: "coaps://rs.example.com",
          scope: BinaryScope([0xDC, 0xAF]),
          clientNonce: HEX.decode("e0a156bb3f"));
      expectSerDeHint(hint,
          "A401781C636F6170733A2F2F61732E6578616D706C652E636F6D2F746F6B656E0576636F6170733A2F2F72732E6578616D706C652E636F6D0942DCAF182745E0A156BB3F");
    });

    test('AIF Scope', () {
      final hint = AuthServerRequestCreationHint(
          authorizationServer: "coaps://as.example.com/token",
          keyID: null,
          audience: "coaps://rs.example.com",
          scope: AifScope(List.of([
            AifScopeElement("/s/temp", List.of([AifRestMethod.GET])),
            AifScopeElement(
                "/a/led", List.of([AifRestMethod.GET, AifRestMethod.PUT]))
          ])),
          clientNonce: HEX.decode("e0a156bb3f"));
      expectSerDeHint(hint,
          "A401781C636F6170733A2F2F61732E6578616D706C652E636F6D2F746F6B656E0576636F6170733A2F2F72732E6578616D706C652E636F6D098282672F732F74656D700182662F612F6C656405182745E0A156BB3F");
    });

    test('libdcaf Scope', () {
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
        audience: "tempSensor4711",
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
            AifScopeElement("restricted", [AifRestMethod.GET]),
            AifScopeElement("extended",
                [AifRestMethod.GET, AifRestMethod.PUT, AifRestMethod.POST]),
            AifScopeElement("dynamic", [
              AifRestMethod.DYNAMIC_GET,
              AifRestMethod.DYNAMIC_PUT,
              AifRestMethod.DYNAMIC_POST
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
            AifScopeElement("restricted", [AifRestMethod.GET]),
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
          reqCnf: KeyID([0xea, 0x48, 0x34, 0x75, 0x72, 0x4c, 0xd7, 0x75]));
      expectSerDeRequest(request,
          "A404A10348EA483475724CD775056876616C76653432340964726561641818686D79636C69656E74");
    });

    test('Request with other fields', () {
      final request = AccessTokenRequest(
        clientId: "myclient",
        redirectUri: "coaps://server.example.com",
        grantType: GrantType.ClientCredentials,
        scope: BinaryScope([0xDC, 0xAF]),
        includeAceProfile: true,
        clientNonce: [0,1,2,3,4]
      );
      expectSerDeRequest(request, "A60942DCAF1818686D79636C69656E74181B781A636F6170733A2F2F7365727665722E6578616D706C652E636F6D1821021826F61827450001020304");
    });

    test('Asymmetric request', () {
      // FIXME: Include req_cnf with COSE_Key!
    });

    test('Encrypted request', () {
      // FIXME: Include req_cnf with COSE_Encrypt0!
    });
  });
}
