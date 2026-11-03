import 'dart:convert';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../catalog/catalog_provider.dart';

part 'lcsc_client.freezed.dart';
part 'lcsc_client.g.dart';

class LcscLookupException implements Exception {
  const LcscLookupException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LcscInvalidCodeException extends LcscLookupException {
  const LcscInvalidCodeException(super.message);
}

class LcscPartNotFoundException extends LcscLookupException {
  const LcscPartNotFoundException(this.lcscCode)
      : super('No LCSC part found for "$lcscCode".');

  final String lcscCode;
}

@freezed
abstract class LcscPartMetadata with _$LcscPartMetadata {
  const factory LcscPartMetadata({
    required String lcscCode,
    required String name,
    String? mpn,
    String? manufacturer,
    String? category,
    String? package,
    String? datasheetUrl,
    @Default(<String, String>{}) Map<String, String> specs,
  }) = _LcscPartMetadata;
}

abstract class LcscClient {
  Future<LcscPartMetadata> fetchPart(String rawCode);

  static String normalizeLcscCode(String rawCode) {
    final trimmed = rawCode.trim();
    if (trimmed.isEmpty) {
      throw const LcscInvalidCodeException(
        'Enter an LCSC part code (e.g. C14663).',
      );
    }
    final normalized = Catalog.normalizeLcscCodeOrNull(trimmed);
    if (normalized == null) {
      throw LcscInvalidCodeException(
        'Invalid LCSC code "$rawCode". Expected format Cxxxxxx (e.g. C14663).',
      );
    }
    return normalized;
  }
}

class HttpLcscClient implements LcscClient {
  HttpLcscClient({
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 10),
  }) : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;
  final Duration timeout;

  static const String _userAgent =
      'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) '
      'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 '
      'Mobile/15E148 Safari/604.1';

  @override
  Future<LcscPartMetadata> fetchPart(String rawCode) async {
    final normalizedCode = LcscClient.normalizeLcscCode(rawCode);
    final uri = Uri.https(
      'wmsc.lcsc.com',
      '/ftps/wm/product/detail',
      <String, String>{'productCode': normalizedCode},
    );

    final http.Response response;
    try {
      response = await _httpClient.get(
        uri,
        headers: const <String, String>{
          'Accept': 'application/json',
          'Accept-Language': 'en-US,en;q=0.9',
          'User-Agent': _userAgent,
        },
      ).timeout(timeout);
    } on Object catch (e) {
      throw LcscLookupException(
        'Could not reach LCSC ($e). You can still fill all part fields manually.',
      );
    }

    if (response.statusCode != 200) {
      throw LcscLookupException(
        'LCSC returned HTTP ${response.statusCode} for $normalizedCode.',
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } on Object {
      throw const LcscLookupException('Received malformed JSON from LCSC.');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const LcscLookupException('Unexpected response format from LCSC.');
    }

    final code = decoded['code'];
    final result = decoded['result'];
    if ((code != null && code != 200) || result is! Map<String, dynamic>) {
      throw LcscPartNotFoundException(normalizedCode);
    }

    final productCode =
        _sanitizeField(result['productCode']) ?? normalizedCode;
    final mpn = _sanitizeField(result['productModel']);
    final name = _sanitizeField(result['productDescEn']) ??
        _sanitizeField(result['productIntroEn']) ??
        _sanitizeField(result['productNameEn']) ??
        mpn ??
        productCode;
    final manufacturer = _sanitizeField(result['brandNameEn']);
    final category = _sanitizeField(result['catalogName']) ??
        _sanitizeField(result['parentCatalogName']);
    final package = _sanitizeField(result['encapStandard']);
    final datasheetUrl = _sanitizeField(result['pdfUrl']);

    final specs = <String, String>{};
    final rawSpecs = result['paramVOList'];
    if (rawSpecs is List) {
      for (final item in rawSpecs) {
        if (item is Map<String, dynamic>) {
          final specName = _sanitizeField(item['paramNameEn']);
          final specVal = _sanitizeField(item['paramValueEn']);
          if (specName != null && specVal != null) {
            specs[specName] = specVal;
          }
        }
      }
    }

    return LcscPartMetadata(
      lcscCode: productCode.toUpperCase(),
      name: name,
      mpn: mpn,
      manufacturer: manufacturer,
      category: category,
      package: package,
      datasheetUrl: datasheetUrl,
      specs: Map<String, String>.unmodifiable(specs),
    );
  }

  static String? _sanitizeField(Object? raw) {
    if (raw is! String) return null;
    // Strip HTML tags
    var text = raw.replaceAll(RegExp(r'<[^>]*>'), '');
    // Decode common HTML entities
    text = text
        .replaceAll('&plusmn;', '±')
        .replaceAll('&#177;', '±')
        .replaceAll('&mu;', 'µ')
        .replaceAll('&micro;', 'µ')
        .replaceAll('&Omega;', 'Ω')
        .replaceAll('&omega;', 'ω')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (text.isEmpty || text == '-') return null;
    return text;
  }
}

@Riverpod(keepAlive: true)
LcscClient lcscClient(Ref ref) {
  return HttpLcscClient();
}
