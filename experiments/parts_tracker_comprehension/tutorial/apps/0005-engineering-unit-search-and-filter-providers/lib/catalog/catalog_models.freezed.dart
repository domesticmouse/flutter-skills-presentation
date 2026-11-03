// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'catalog_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Container {

 String get id; String get name; String? get description;
/// Create a copy of Container
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ContainerCopyWith<Container> get copyWith => _$ContainerCopyWithImpl<Container>(this as Container, _$identity);

  /// Serializes this Container to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Container;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Container&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.description, _this.description) || other.description == _this.description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Container;
  return Object.hash(runtimeType,_this.id,_this.name,_this.description);
}

@override
String toString() {
  final _this = this as Container;
  return 'Container(id: ${_this.id}, name: ${_this.name}, description: ${_this.description})';
}


}

/// @nodoc
abstract mixin class $ContainerCopyWith<$Res>  {
  factory $ContainerCopyWith(Container value, $Res Function(Container) _then) = _$ContainerCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description
});




}
/// @nodoc
class _$ContainerCopyWithImpl<$Res>
    implements $ContainerCopyWith<$Res> {
  _$ContainerCopyWithImpl(this._self, this._then);

  final Container _self;
  final $Res Function(Container) _then;

/// Create a copy of Container
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,}) {
  return _then(Container(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Container].
extension ContainerPatterns on Container {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Container value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Container() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Container value)  $default,){
final _that = this;
switch (_that) {
case _Container():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Container value)?  $default,){
final _that = this;
switch (_that) {
case _Container() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Container() when $default != null:
return $default(_that.id,_that.name,_that.description);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description)  $default,) {final _that = this;
switch (_that) {
case _Container():
return $default(_that.id,_that.name,_that.description);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description)?  $default,) {final _that = this;
switch (_that) {
case _Container() when $default != null:
return $default(_that.id,_that.name,_that.description);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Container extends Container {
  const _Container({required this.id, required this.name, this.description}): super._();
  factory _Container.fromJson(Map<String, dynamic> json) => _$ContainerFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? description;

/// Create a copy of Container
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ContainerCopyWith<_Container> get copyWith => __$ContainerCopyWithImpl<_Container>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ContainerToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Container&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,description);
}

@override
String toString() {
    return 'Container(id: $id, name: $name, description: $description)';
}


}

/// @nodoc
abstract mixin class _$ContainerCopyWith<$Res> implements $ContainerCopyWith<$Res> {
  factory _$ContainerCopyWith(_Container value, $Res Function(_Container) _then) = __$ContainerCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description
});




}
/// @nodoc
class __$ContainerCopyWithImpl<$Res>
    implements _$ContainerCopyWith<$Res> {
  __$ContainerCopyWithImpl(this._self, this._then);

  final _Container _self;
  final $Res Function(_Container) _then;

/// Create a copy of Container
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,}) {
  return _then(_Container(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Part {

 String get id; String get name; int get quantity; String? get lcscCode; String? get mpn; String? get manufacturer; String? get category; String? get package; String? get datasheetUrl; String? get containerId; String? get slot; int? get lowStockThreshold; String? get notes; Map<String, String> get specs;
/// Create a copy of Part
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PartCopyWith<Part> get copyWith => _$PartCopyWithImpl<Part>(this as Part, _$identity);

  /// Serializes this Part to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Part;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Part&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.quantity, _this.quantity) || other.quantity == _this.quantity)&&(identical(other.lcscCode, _this.lcscCode) || other.lcscCode == _this.lcscCode)&&(identical(other.mpn, _this.mpn) || other.mpn == _this.mpn)&&(identical(other.manufacturer, _this.manufacturer) || other.manufacturer == _this.manufacturer)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.package, _this.package) || other.package == _this.package)&&(identical(other.datasheetUrl, _this.datasheetUrl) || other.datasheetUrl == _this.datasheetUrl)&&(identical(other.containerId, _this.containerId) || other.containerId == _this.containerId)&&(identical(other.slot, _this.slot) || other.slot == _this.slot)&&(identical(other.lowStockThreshold, _this.lowStockThreshold) || other.lowStockThreshold == _this.lowStockThreshold)&&(identical(other.notes, _this.notes) || other.notes == _this.notes)&&const DeepCollectionEquality().equals(other.specs, _this.specs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Part;
  return Object.hash(runtimeType,_this.id,_this.name,_this.quantity,_this.lcscCode,_this.mpn,_this.manufacturer,_this.category,_this.package,_this.datasheetUrl,_this.containerId,_this.slot,_this.lowStockThreshold,_this.notes,const DeepCollectionEquality().hash(_this.specs));
}

@override
String toString() {
  final _this = this as Part;
  return 'Part(id: ${_this.id}, name: ${_this.name}, quantity: ${_this.quantity}, lcscCode: ${_this.lcscCode}, mpn: ${_this.mpn}, manufacturer: ${_this.manufacturer}, category: ${_this.category}, package: ${_this.package}, datasheetUrl: ${_this.datasheetUrl}, containerId: ${_this.containerId}, slot: ${_this.slot}, lowStockThreshold: ${_this.lowStockThreshold}, notes: ${_this.notes}, specs: ${_this.specs})';
}


}

/// @nodoc
abstract mixin class $PartCopyWith<$Res>  {
  factory $PartCopyWith(Part value, $Res Function(Part) _then) = _$PartCopyWithImpl;
@useResult
$Res call({
 String id, String name, int quantity, String? lcscCode, String? mpn, String? manufacturer, String? category, String? package, String? datasheetUrl, String? containerId, String? slot, int? lowStockThreshold, String? notes, Map<String, String> specs
});




}
/// @nodoc
class _$PartCopyWithImpl<$Res>
    implements $PartCopyWith<$Res> {
  _$PartCopyWithImpl(this._self, this._then);

  final Part _self;
  final $Res Function(Part) _then;

/// Create a copy of Part
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? quantity = null,Object? lcscCode = freezed,Object? mpn = freezed,Object? manufacturer = freezed,Object? category = freezed,Object? package = freezed,Object? datasheetUrl = freezed,Object? containerId = freezed,Object? slot = freezed,Object? lowStockThreshold = freezed,Object? notes = freezed,Object? specs = null,}) {
  return _then(Part(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,lcscCode: freezed == lcscCode ? _self.lcscCode : lcscCode // ignore: cast_nullable_to_non_nullable
as String?,mpn: freezed == mpn ? _self.mpn : mpn // ignore: cast_nullable_to_non_nullable
as String?,manufacturer: freezed == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,package: freezed == package ? _self.package : package // ignore: cast_nullable_to_non_nullable
as String?,datasheetUrl: freezed == datasheetUrl ? _self.datasheetUrl : datasheetUrl // ignore: cast_nullable_to_non_nullable
as String?,containerId: freezed == containerId ? _self.containerId : containerId // ignore: cast_nullable_to_non_nullable
as String?,slot: freezed == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as String?,lowStockThreshold: freezed == lowStockThreshold ? _self.lowStockThreshold : lowStockThreshold // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,specs: null == specs ? _self.specs : specs // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [Part].
extension PartPatterns on Part {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Part value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Part() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Part value)  $default,){
final _that = this;
switch (_that) {
case _Part():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Part value)?  $default,){
final _that = this;
switch (_that) {
case _Part() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  int quantity,  String? lcscCode,  String? mpn,  String? manufacturer,  String? category,  String? package,  String? datasheetUrl,  String? containerId,  String? slot,  int? lowStockThreshold,  String? notes,  Map<String, String> specs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Part() when $default != null:
return $default(_that.id,_that.name,_that.quantity,_that.lcscCode,_that.mpn,_that.manufacturer,_that.category,_that.package,_that.datasheetUrl,_that.containerId,_that.slot,_that.lowStockThreshold,_that.notes,_that.specs);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  int quantity,  String? lcscCode,  String? mpn,  String? manufacturer,  String? category,  String? package,  String? datasheetUrl,  String? containerId,  String? slot,  int? lowStockThreshold,  String? notes,  Map<String, String> specs)  $default,) {final _that = this;
switch (_that) {
case _Part():
return $default(_that.id,_that.name,_that.quantity,_that.lcscCode,_that.mpn,_that.manufacturer,_that.category,_that.package,_that.datasheetUrl,_that.containerId,_that.slot,_that.lowStockThreshold,_that.notes,_that.specs);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  int quantity,  String? lcscCode,  String? mpn,  String? manufacturer,  String? category,  String? package,  String? datasheetUrl,  String? containerId,  String? slot,  int? lowStockThreshold,  String? notes,  Map<String, String> specs)?  $default,) {final _that = this;
switch (_that) {
case _Part() when $default != null:
return $default(_that.id,_that.name,_that.quantity,_that.lcscCode,_that.mpn,_that.manufacturer,_that.category,_that.package,_that.datasheetUrl,_that.containerId,_that.slot,_that.lowStockThreshold,_that.notes,_that.specs);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Part extends Part {
  const _Part({required this.id, required this.name, this.quantity = 0, this.lcscCode, this.mpn, this.manufacturer, this.category, this.package, this.datasheetUrl, this.containerId, this.slot, this.lowStockThreshold, this.notes,  Map<String, String> specs = const <String, String>{}}): _specs = specs,super._();
  factory _Part.fromJson(Map<String, dynamic> json) => _$PartFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey() final  int quantity;
@override final  String? lcscCode;
@override final  String? mpn;
@override final  String? manufacturer;
@override final  String? category;
@override final  String? package;
@override final  String? datasheetUrl;
@override final  String? containerId;
@override final  String? slot;
@override final  int? lowStockThreshold;
@override final  String? notes;
 final  Map<String, String> _specs;
@override@JsonKey() Map<String, String> get specs {
  if (_specs is EqualUnmodifiableMapView) return _specs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_specs);
}


/// Create a copy of Part
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PartCopyWith<_Part> get copyWith => __$PartCopyWithImpl<_Part>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PartToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Part&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.lcscCode, lcscCode) || other.lcscCode == lcscCode)&&(identical(other.mpn, mpn) || other.mpn == mpn)&&(identical(other.manufacturer, manufacturer) || other.manufacturer == manufacturer)&&(identical(other.category, category) || other.category == category)&&(identical(other.package, package) || other.package == package)&&(identical(other.datasheetUrl, datasheetUrl) || other.datasheetUrl == datasheetUrl)&&(identical(other.containerId, containerId) || other.containerId == containerId)&&(identical(other.slot, slot) || other.slot == slot)&&(identical(other.lowStockThreshold, lowStockThreshold) || other.lowStockThreshold == lowStockThreshold)&&(identical(other.notes, notes) || other.notes == notes)&&const DeepCollectionEquality().equals(other.specs, _specs));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,name,quantity,lcscCode,mpn,manufacturer,category,package,datasheetUrl,containerId,slot,lowStockThreshold,notes,const DeepCollectionEquality().hash(_specs));
}

@override
String toString() {
    return 'Part(id: $id, name: $name, quantity: $quantity, lcscCode: $lcscCode, mpn: $mpn, manufacturer: $manufacturer, category: $category, package: $package, datasheetUrl: $datasheetUrl, containerId: $containerId, slot: $slot, lowStockThreshold: $lowStockThreshold, notes: $notes, specs: $specs)';
}


}

/// @nodoc
abstract mixin class _$PartCopyWith<$Res> implements $PartCopyWith<$Res> {
  factory _$PartCopyWith(_Part value, $Res Function(_Part) _then) = __$PartCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, int quantity, String? lcscCode, String? mpn, String? manufacturer, String? category, String? package, String? datasheetUrl, String? containerId, String? slot, int? lowStockThreshold, String? notes, Map<String, String> specs
});




}
/// @nodoc
class __$PartCopyWithImpl<$Res>
    implements _$PartCopyWith<$Res> {
  __$PartCopyWithImpl(this._self, this._then);

  final _Part _self;
  final $Res Function(_Part) _then;

/// Create a copy of Part
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? quantity = null,Object? lcscCode = freezed,Object? mpn = freezed,Object? manufacturer = freezed,Object? category = freezed,Object? package = freezed,Object? datasheetUrl = freezed,Object? containerId = freezed,Object? slot = freezed,Object? lowStockThreshold = freezed,Object? notes = freezed,Object? specs = null,}) {
  return _then(_Part(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,lcscCode: freezed == lcscCode ? _self.lcscCode : lcscCode // ignore: cast_nullable_to_non_nullable
as String?,mpn: freezed == mpn ? _self.mpn : mpn // ignore: cast_nullable_to_non_nullable
as String?,manufacturer: freezed == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,package: freezed == package ? _self.package : package // ignore: cast_nullable_to_non_nullable
as String?,datasheetUrl: freezed == datasheetUrl ? _self.datasheetUrl : datasheetUrl // ignore: cast_nullable_to_non_nullable
as String?,containerId: freezed == containerId ? _self.containerId : containerId // ignore: cast_nullable_to_non_nullable
as String?,slot: freezed == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as String?,lowStockThreshold: freezed == lowStockThreshold ? _self.lowStockThreshold : lowStockThreshold // ignore: cast_nullable_to_non_nullable
as int?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,specs: null == specs ? _self._specs : specs // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}


/// @nodoc
mixin _$CatalogSnapshot {

 int get schemaVersion; DateTime get updatedAt; List<Container> get containers; List<Part> get parts;
/// Create a copy of CatalogSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CatalogSnapshotCopyWith<CatalogSnapshot> get copyWith => _$CatalogSnapshotCopyWithImpl<CatalogSnapshot>(this as CatalogSnapshot, _$identity);

  /// Serializes this CatalogSnapshot to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as CatalogSnapshot;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CatalogSnapshot&&(identical(other.schemaVersion, _this.schemaVersion) || other.schemaVersion == _this.schemaVersion)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&const DeepCollectionEquality().equals(other.containers, _this.containers)&&const DeepCollectionEquality().equals(other.parts, _this.parts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as CatalogSnapshot;
  return Object.hash(runtimeType,_this.schemaVersion,_this.updatedAt,const DeepCollectionEquality().hash(_this.containers),const DeepCollectionEquality().hash(_this.parts));
}

@override
String toString() {
  final _this = this as CatalogSnapshot;
  return 'CatalogSnapshot(schemaVersion: ${_this.schemaVersion}, updatedAt: ${_this.updatedAt}, containers: ${_this.containers}, parts: ${_this.parts})';
}


}

/// @nodoc
abstract mixin class $CatalogSnapshotCopyWith<$Res>  {
  factory $CatalogSnapshotCopyWith(CatalogSnapshot value, $Res Function(CatalogSnapshot) _then) = _$CatalogSnapshotCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, DateTime updatedAt, List<Container> containers, List<Part> parts
});




}
/// @nodoc
class _$CatalogSnapshotCopyWithImpl<$Res>
    implements $CatalogSnapshotCopyWith<$Res> {
  _$CatalogSnapshotCopyWithImpl(this._self, this._then);

  final CatalogSnapshot _self;
  final $Res Function(CatalogSnapshot) _then;

/// Create a copy of CatalogSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? updatedAt = null,Object? containers = null,Object? parts = null,}) {
  return _then(CatalogSnapshot(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,containers: null == containers ? _self.containers : containers // ignore: cast_nullable_to_non_nullable
as List<Container>,parts: null == parts ? _self.parts : parts // ignore: cast_nullable_to_non_nullable
as List<Part>,
  ));
}

}


/// Adds pattern-matching-related methods to [CatalogSnapshot].
extension CatalogSnapshotPatterns on CatalogSnapshot {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CatalogSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CatalogSnapshot() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CatalogSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _CatalogSnapshot():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CatalogSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _CatalogSnapshot() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schemaVersion,  DateTime updatedAt,  List<Container> containers,  List<Part> parts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CatalogSnapshot() when $default != null:
return $default(_that.schemaVersion,_that.updatedAt,_that.containers,_that.parts);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schemaVersion,  DateTime updatedAt,  List<Container> containers,  List<Part> parts)  $default,) {final _that = this;
switch (_that) {
case _CatalogSnapshot():
return $default(_that.schemaVersion,_that.updatedAt,_that.containers,_that.parts);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schemaVersion,  DateTime updatedAt,  List<Container> containers,  List<Part> parts)?  $default,) {final _that = this;
switch (_that) {
case _CatalogSnapshot() when $default != null:
return $default(_that.schemaVersion,_that.updatedAt,_that.containers,_that.parts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CatalogSnapshot extends CatalogSnapshot {
  const _CatalogSnapshot({this.schemaVersion = 1, required this.updatedAt,  List<Container> containers = const <Container>[],  List<Part> parts = const <Part>[]}): _containers = containers,_parts = parts,super._();
  factory _CatalogSnapshot.fromJson(Map<String, dynamic> json) => _$CatalogSnapshotFromJson(json);

@override@JsonKey() final  int schemaVersion;
@override final  DateTime updatedAt;
 final  List<Container> _containers;
@override@JsonKey() List<Container> get containers {
  if (_containers is EqualUnmodifiableListView) return _containers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_containers);
}

 final  List<Part> _parts;
@override@JsonKey() List<Part> get parts {
  if (_parts is EqualUnmodifiableListView) return _parts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_parts);
}


/// Create a copy of CatalogSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CatalogSnapshotCopyWith<_CatalogSnapshot> get copyWith => __$CatalogSnapshotCopyWithImpl<_CatalogSnapshot>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CatalogSnapshotToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _CatalogSnapshot&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.containers, _containers)&&const DeepCollectionEquality().equals(other.parts, _parts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,schemaVersion,updatedAt,const DeepCollectionEquality().hash(_containers),const DeepCollectionEquality().hash(_parts));
}

@override
String toString() {
    return 'CatalogSnapshot(schemaVersion: $schemaVersion, updatedAt: $updatedAt, containers: $containers, parts: $parts)';
}


}

/// @nodoc
abstract mixin class _$CatalogSnapshotCopyWith<$Res> implements $CatalogSnapshotCopyWith<$Res> {
  factory _$CatalogSnapshotCopyWith(_CatalogSnapshot value, $Res Function(_CatalogSnapshot) _then) = __$CatalogSnapshotCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, DateTime updatedAt, List<Container> containers, List<Part> parts
});




}
/// @nodoc
class __$CatalogSnapshotCopyWithImpl<$Res>
    implements _$CatalogSnapshotCopyWith<$Res> {
  __$CatalogSnapshotCopyWithImpl(this._self, this._then);

  final _CatalogSnapshot _self;
  final $Res Function(_CatalogSnapshot) _then;

/// Create a copy of CatalogSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? updatedAt = null,Object? containers = null,Object? parts = null,}) {
  return _then(_CatalogSnapshot(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,containers: null == containers ? _self._containers : containers // ignore: cast_nullable_to_non_nullable
as List<Container>,parts: null == parts ? _self._parts : parts // ignore: cast_nullable_to_non_nullable
as List<Part>,
  ));
}


}

// dart format on
