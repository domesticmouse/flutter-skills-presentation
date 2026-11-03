// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'lcsc_client.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LcscPartMetadata {

 String get lcscCode; String get name; String? get mpn; String? get manufacturer; String? get category; String? get package; String? get datasheetUrl; Map<String, String> get specs;
/// Create a copy of LcscPartMetadata
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LcscPartMetadataCopyWith<LcscPartMetadata> get copyWith => _$LcscPartMetadataCopyWithImpl<LcscPartMetadata>(this as LcscPartMetadata, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LcscPartMetadata;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LcscPartMetadata&&(identical(other.lcscCode, _this.lcscCode) || other.lcscCode == _this.lcscCode)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.mpn, _this.mpn) || other.mpn == _this.mpn)&&(identical(other.manufacturer, _this.manufacturer) || other.manufacturer == _this.manufacturer)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.package, _this.package) || other.package == _this.package)&&(identical(other.datasheetUrl, _this.datasheetUrl) || other.datasheetUrl == _this.datasheetUrl)&&const DeepCollectionEquality().equals(other.specs, _this.specs));
}


@override
int get hashCode {
  final _this = this as LcscPartMetadata;
  return Object.hash(runtimeType,_this.lcscCode,_this.name,_this.mpn,_this.manufacturer,_this.category,_this.package,_this.datasheetUrl,const DeepCollectionEquality().hash(_this.specs));
}

@override
String toString() {
  final _this = this as LcscPartMetadata;
  return 'LcscPartMetadata(lcscCode: ${_this.lcscCode}, name: ${_this.name}, mpn: ${_this.mpn}, manufacturer: ${_this.manufacturer}, category: ${_this.category}, package: ${_this.package}, datasheetUrl: ${_this.datasheetUrl}, specs: ${_this.specs})';
}


}

/// @nodoc
abstract mixin class $LcscPartMetadataCopyWith<$Res>  {
  factory $LcscPartMetadataCopyWith(LcscPartMetadata value, $Res Function(LcscPartMetadata) _then) = _$LcscPartMetadataCopyWithImpl;
@useResult
$Res call({
 String lcscCode, String name, String? mpn, String? manufacturer, String? category, String? package, String? datasheetUrl, Map<String, String> specs
});




}
/// @nodoc
class _$LcscPartMetadataCopyWithImpl<$Res>
    implements $LcscPartMetadataCopyWith<$Res> {
  _$LcscPartMetadataCopyWithImpl(this._self, this._then);

  final LcscPartMetadata _self;
  final $Res Function(LcscPartMetadata) _then;

/// Create a copy of LcscPartMetadata
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? lcscCode = null,Object? name = null,Object? mpn = freezed,Object? manufacturer = freezed,Object? category = freezed,Object? package = freezed,Object? datasheetUrl = freezed,Object? specs = null,}) {
  return _then(LcscPartMetadata(
lcscCode: null == lcscCode ? _self.lcscCode : lcscCode // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,mpn: freezed == mpn ? _self.mpn : mpn // ignore: cast_nullable_to_non_nullable
as String?,manufacturer: freezed == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,package: freezed == package ? _self.package : package // ignore: cast_nullable_to_non_nullable
as String?,datasheetUrl: freezed == datasheetUrl ? _self.datasheetUrl : datasheetUrl // ignore: cast_nullable_to_non_nullable
as String?,specs: null == specs ? _self.specs : specs // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [LcscPartMetadata].
extension LcscPartMetadataPatterns on LcscPartMetadata {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LcscPartMetadata value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LcscPartMetadata() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LcscPartMetadata value)  $default,){
final _that = this;
switch (_that) {
case _LcscPartMetadata():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LcscPartMetadata value)?  $default,){
final _that = this;
switch (_that) {
case _LcscPartMetadata() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String lcscCode,  String name,  String? mpn,  String? manufacturer,  String? category,  String? package,  String? datasheetUrl,  Map<String, String> specs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LcscPartMetadata() when $default != null:
return $default(_that.lcscCode,_that.name,_that.mpn,_that.manufacturer,_that.category,_that.package,_that.datasheetUrl,_that.specs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String lcscCode,  String name,  String? mpn,  String? manufacturer,  String? category,  String? package,  String? datasheetUrl,  Map<String, String> specs)  $default,) {final _that = this;
switch (_that) {
case _LcscPartMetadata():
return $default(_that.lcscCode,_that.name,_that.mpn,_that.manufacturer,_that.category,_that.package,_that.datasheetUrl,_that.specs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String lcscCode,  String name,  String? mpn,  String? manufacturer,  String? category,  String? package,  String? datasheetUrl,  Map<String, String> specs)?  $default,) {final _that = this;
switch (_that) {
case _LcscPartMetadata() when $default != null:
return $default(_that.lcscCode,_that.name,_that.mpn,_that.manufacturer,_that.category,_that.package,_that.datasheetUrl,_that.specs);case _:
  return null;

}
}

}

/// @nodoc


class _LcscPartMetadata implements LcscPartMetadata {
  const _LcscPartMetadata({required this.lcscCode, required this.name, this.mpn, this.manufacturer, this.category, this.package, this.datasheetUrl,  Map<String, String> specs = const <String, String>{}}): _specs = specs;
  

@override final  String lcscCode;
@override final  String name;
@override final  String? mpn;
@override final  String? manufacturer;
@override final  String? category;
@override final  String? package;
@override final  String? datasheetUrl;
 final  Map<String, String> _specs;
@override@JsonKey() Map<String, String> get specs {
  if (_specs is EqualUnmodifiableMapView) return _specs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_specs);
}


/// Create a copy of LcscPartMetadata
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LcscPartMetadataCopyWith<_LcscPartMetadata> get copyWith => __$LcscPartMetadataCopyWithImpl<_LcscPartMetadata>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LcscPartMetadata&&(identical(other.lcscCode, lcscCode) || other.lcscCode == lcscCode)&&(identical(other.name, name) || other.name == name)&&(identical(other.mpn, mpn) || other.mpn == mpn)&&(identical(other.manufacturer, manufacturer) || other.manufacturer == manufacturer)&&(identical(other.category, category) || other.category == category)&&(identical(other.package, package) || other.package == package)&&(identical(other.datasheetUrl, datasheetUrl) || other.datasheetUrl == datasheetUrl)&&const DeepCollectionEquality().equals(other.specs, _specs));
}


@override
int get hashCode {
    return Object.hash(runtimeType,lcscCode,name,mpn,manufacturer,category,package,datasheetUrl,const DeepCollectionEquality().hash(_specs));
}

@override
String toString() {
    return 'LcscPartMetadata(lcscCode: $lcscCode, name: $name, mpn: $mpn, manufacturer: $manufacturer, category: $category, package: $package, datasheetUrl: $datasheetUrl, specs: $specs)';
}


}

/// @nodoc
abstract mixin class _$LcscPartMetadataCopyWith<$Res> implements $LcscPartMetadataCopyWith<$Res> {
  factory _$LcscPartMetadataCopyWith(_LcscPartMetadata value, $Res Function(_LcscPartMetadata) _then) = __$LcscPartMetadataCopyWithImpl;
@override @useResult
$Res call({
 String lcscCode, String name, String? mpn, String? manufacturer, String? category, String? package, String? datasheetUrl, Map<String, String> specs
});




}
/// @nodoc
class __$LcscPartMetadataCopyWithImpl<$Res>
    implements _$LcscPartMetadataCopyWith<$Res> {
  __$LcscPartMetadataCopyWithImpl(this._self, this._then);

  final _LcscPartMetadata _self;
  final $Res Function(_LcscPartMetadata) _then;

/// Create a copy of LcscPartMetadata
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? lcscCode = null,Object? name = null,Object? mpn = freezed,Object? manufacturer = freezed,Object? category = freezed,Object? package = freezed,Object? datasheetUrl = freezed,Object? specs = null,}) {
  return _then(_LcscPartMetadata(
lcscCode: null == lcscCode ? _self.lcscCode : lcscCode // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,mpn: freezed == mpn ? _self.mpn : mpn // ignore: cast_nullable_to_non_nullable
as String?,manufacturer: freezed == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,package: freezed == package ? _self.package : package // ignore: cast_nullable_to_non_nullable
as String?,datasheetUrl: freezed == datasheetUrl ? _self.datasheetUrl : datasheetUrl // ignore: cast_nullable_to_non_nullable
as String?,specs: null == specs ? _self._specs : specs // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

// dart format on
