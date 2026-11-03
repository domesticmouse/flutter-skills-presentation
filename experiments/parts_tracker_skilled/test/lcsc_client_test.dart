import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:parts_tracker_skilled/lcsc/lcsc_client.dart';

void main() {
  group('HttpLcscClient Seam', () {
    test('normalizes Cxxxxxx codes, sends browser User-Agent header, maps LCSC product detail fields, strips HTML/entities, and skips "-" placeholders', () async {
      Uri? capturedUri;
      Map<String, String>? capturedHeaders;

      final mockHttp = MockClient((request) async {
        capturedUri = request.url;
        capturedHeaders = request.headers;
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'code': 200,
              'msg': null,
              'ok': true,
              'result': {
                'productCode': 'C14663',
                'productModel': 'CC0603KRX7R9BB104',
                'productNameEn': 'CAP CER 100nF 50V X7R 0603',
                'productDescEn': '100nF &plusmn;10% 50V <b>Ceramic</b> Capacitor X7R 0603',
                'productIntroEn': '100nF intro',
                'parentCatalogName': 'Capacitors',
                'catalogName': 'Ceramic Capacitors',
                'brandNameEn': 'YAGEO &amp; Co.',
                'encapStandard': '0603',
                'pdfUrl': 'https://datasheet.lcsc.com/datasheet/pdf/C14663.pdf',
                'paramVOList': [
                  {
                    'paramNameEn': 'Capacitance',
                    'paramValueEn': '100nF',
                  },
                  {
                    'paramNameEn': 'Tolerance',
                    'paramValueEn': '&plusmn;10%',
                  },
                  {
                    'paramNameEn': 'Voltage Rated',
                    'paramValueEn': '<span>50V</span>',
                  },
                  {
                    'paramNameEn': 'Empty Placeholder',
                    'paramValueEn': '-',
                  },
                  {
                    'paramNameEn': 'Blank Value',
                    'paramValueEn': '   ',
                  },
                ],
              },
            }),
          ),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final client = HttpLcscClient(httpClient: mockHttp);
      final metadata = await client.fetchPart('  14663 ');

      expect(
        capturedUri.toString(),
        'https://wmsc.lcsc.com/ftps/wm/product/detail?productCode=C14663',
      );
      expect(capturedHeaders?['User-Agent'], contains('Mozilla/5.0'));
      expect(capturedHeaders?['Accept'], 'application/json');

      expect(metadata.lcscCode, 'C14663');
      expect(metadata.name, '100nF ±10% 50V Ceramic Capacitor X7R 0603');
      expect(metadata.mpn, 'CC0603KRX7R9BB104');
      expect(metadata.manufacturer, 'YAGEO & Co.');
      expect(metadata.category, 'Ceramic Capacitors');
      expect(metadata.package, '0603');
      expect(
        metadata.datasheetUrl,
        'https://datasheet.lcsc.com/datasheet/pdf/C14663.pdf',
      );
      expect(metadata.specs, {
        'Capacitance': '100nF',
        'Tolerance': '±10%',
        'Voltage Rated': '50V',
      });
    });

    test('falls back when productDescEn is null or encapStandard is "-" and handles invalid codes, not-found codes, and network failures', () async {
      final mockHttp = MockClient((request) async {
        final code = request.url.queryParameters['productCode'];
        if (code == 'C2040') {
          return http.Response(
            jsonEncode({
              'code': 200,
              'result': {
                'productCode': 'C2040',
                'productModel': 'RP2040',
                'productDescEn': null,
                'productIntroEn': 'ARM Cortex-M0+ 32 Bit MCU',
                'parentCatalogName': 'Embedded Processors & Controllers',
                'catalogName': null,
                'brandNameEn': 'Raspberry Pi',
                'encapStandard': '-',
                'pdfUrl': '-',
                'paramVOList': [],
              },
            }),
            200,
          );
        }
        if (code == 'C999999999') {
          return http.Response(
            jsonEncode({
              'code': 200,
              'result': null,
              'ok': true,
            }),
            200,
          );
        }
        return http.Response('Server Error', 503);
      });

      final client = HttpLcscClient(httpClient: mockHttp);

      // Invalid format rejected before HTTP request
      await expectLater(
        () => client.fetchPart('ABC-INVALID'),
        throwsA(isA<LcscInvalidCodeException>()),
      );

      // Fallback fields & "-" placeholder stripping
      final rp2040 = await client.fetchPart('c2040');
      expect(rp2040.lcscCode, 'C2040');
      expect(rp2040.name, 'ARM Cortex-M0+ 32 Bit MCU');
      expect(rp2040.category, 'Embedded Processors & Controllers');
      expect(rp2040.package, isNull);
      expect(rp2040.datasheetUrl, isNull);
      expect(rp2040.specs, isEmpty);

      // Not-found code (result: null)
      await expectLater(
        () => client.fetchPart('C999999999'),
        throwsA(isA<LcscPartNotFoundException>()),
      );

      // HTTP error status
      await expectLater(
        () => client.fetchPart('C50000'),
        throwsA(isA<LcscLookupException>()),
      );
    });
  });
}
