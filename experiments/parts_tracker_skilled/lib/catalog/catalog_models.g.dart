// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Container _$ContainerFromJson(Map<String, dynamic> json) => _Container(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
);

Map<String, dynamic> _$ContainerToJson(_Container instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
    };

_Part _$PartFromJson(Map<String, dynamic> json) => _Part(
  id: json['id'] as String,
  name: json['name'] as String,
  quantity: (json['quantity'] as num?)?.toInt() ?? 0,
  lcscCode: json['lcscCode'] as String?,
  mpn: json['mpn'] as String?,
  manufacturer: json['manufacturer'] as String?,
  category: json['category'] as String?,
  package: json['package'] as String?,
  datasheetUrl: json['datasheetUrl'] as String?,
  containerId: json['containerId'] as String?,
  slot: json['slot'] as String?,
  lowStockThreshold: (json['lowStockThreshold'] as num?)?.toInt(),
  notes: json['notes'] as String?,
  specs:
      (json['specs'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
);

Map<String, dynamic> _$PartToJson(_Part instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'quantity': instance.quantity,
  'lcscCode': instance.lcscCode,
  'mpn': instance.mpn,
  'manufacturer': instance.manufacturer,
  'category': instance.category,
  'package': instance.package,
  'datasheetUrl': instance.datasheetUrl,
  'containerId': instance.containerId,
  'slot': instance.slot,
  'lowStockThreshold': instance.lowStockThreshold,
  'notes': instance.notes,
  'specs': instance.specs,
};

_CatalogSnapshot _$CatalogSnapshotFromJson(Map<String, dynamic> json) =>
    _CatalogSnapshot(
      schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? 1,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      containers:
          (json['containers'] as List<dynamic>?)
              ?.map((e) => Container.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Container>[],
      parts:
          (json['parts'] as List<dynamic>?)
              ?.map((e) => Part.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <Part>[],
    );

Map<String, dynamic> _$CatalogSnapshotToJson(_CatalogSnapshot instance) =>
    <String, dynamic>{
      'schemaVersion': instance.schemaVersion,
      'updatedAt': instance.updatedAt.toIso8601String(),
      'containers': instance.containers,
      'parts': instance.parts,
    };
