// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workbench_filter_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WorkbenchFacet {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkbenchFacet);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'WorkbenchFacet()';
}


}

/// @nodoc
class $WorkbenchFacetCopyWith<$Res>  {
$WorkbenchFacetCopyWith(WorkbenchFacet _, $Res Function(WorkbenchFacet) __);
}


/// Adds pattern-matching-related methods to [WorkbenchFacet].
extension WorkbenchFacetPatterns on WorkbenchFacet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( WorkbenchFacetAll value)?  all,TResult Function( WorkbenchFacetLowStock value)?  lowStock,TResult Function( WorkbenchFacetUnassigned value)?  unassigned,TResult Function( WorkbenchFacetCategory value)?  category,required TResult orElse(),}){
final _that = this;
switch (_that) {
case WorkbenchFacetAll() when all != null:
return all(_that);case WorkbenchFacetLowStock() when lowStock != null:
return lowStock(_that);case WorkbenchFacetUnassigned() when unassigned != null:
return unassigned(_that);case WorkbenchFacetCategory() when category != null:
return category(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( WorkbenchFacetAll value)  all,required TResult Function( WorkbenchFacetLowStock value)  lowStock,required TResult Function( WorkbenchFacetUnassigned value)  unassigned,required TResult Function( WorkbenchFacetCategory value)  category,}){
final _that = this;
switch (_that) {
case WorkbenchFacetAll():
return all(_that);case WorkbenchFacetLowStock():
return lowStock(_that);case WorkbenchFacetUnassigned():
return unassigned(_that);case WorkbenchFacetCategory():
return category(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( WorkbenchFacetAll value)?  all,TResult? Function( WorkbenchFacetLowStock value)?  lowStock,TResult? Function( WorkbenchFacetUnassigned value)?  unassigned,TResult? Function( WorkbenchFacetCategory value)?  category,}){
final _that = this;
switch (_that) {
case WorkbenchFacetAll() when all != null:
return all(_that);case WorkbenchFacetLowStock() when lowStock != null:
return lowStock(_that);case WorkbenchFacetUnassigned() when unassigned != null:
return unassigned(_that);case WorkbenchFacetCategory() when category != null:
return category(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  all,TResult Function()?  lowStock,TResult Function()?  unassigned,TResult Function( String category)?  category,required TResult orElse(),}) {final _that = this;
switch (_that) {
case WorkbenchFacetAll() when all != null:
return all();case WorkbenchFacetLowStock() when lowStock != null:
return lowStock();case WorkbenchFacetUnassigned() when unassigned != null:
return unassigned();case WorkbenchFacetCategory() when category != null:
return category(_that.category);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  all,required TResult Function()  lowStock,required TResult Function()  unassigned,required TResult Function( String category)  category,}) {final _that = this;
switch (_that) {
case WorkbenchFacetAll():
return all();case WorkbenchFacetLowStock():
return lowStock();case WorkbenchFacetUnassigned():
return unassigned();case WorkbenchFacetCategory():
return category(_that.category);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  all,TResult? Function()?  lowStock,TResult? Function()?  unassigned,TResult? Function( String category)?  category,}) {final _that = this;
switch (_that) {
case WorkbenchFacetAll() when all != null:
return all();case WorkbenchFacetLowStock() when lowStock != null:
return lowStock();case WorkbenchFacetUnassigned() when unassigned != null:
return unassigned();case WorkbenchFacetCategory() when category != null:
return category(_that.category);case _:
  return null;

}
}

}

/// @nodoc


class WorkbenchFacetAll implements WorkbenchFacet {
  const WorkbenchFacetAll();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkbenchFacetAll);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'WorkbenchFacet.all()';
}


}




/// @nodoc


class WorkbenchFacetLowStock implements WorkbenchFacet {
  const WorkbenchFacetLowStock();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkbenchFacetLowStock);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'WorkbenchFacet.lowStock()';
}


}




/// @nodoc


class WorkbenchFacetUnassigned implements WorkbenchFacet {
  const WorkbenchFacetUnassigned();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkbenchFacetUnassigned);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'WorkbenchFacet.unassigned()';
}


}




/// @nodoc


class WorkbenchFacetCategory implements WorkbenchFacet {
  const WorkbenchFacetCategory(this.category);
  

 final  String category;

/// Create a copy of WorkbenchFacet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkbenchFacetCategoryCopyWith<WorkbenchFacetCategory> get copyWith => _$WorkbenchFacetCategoryCopyWithImpl<WorkbenchFacetCategory>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is WorkbenchFacetCategory&&(identical(other.category, category) || other.category == category));
}


@override
int get hashCode {
    return Object.hash(runtimeType,category);
}

@override
String toString() {
    return 'WorkbenchFacet.category(category: $category)';
}


}

/// @nodoc
abstract mixin class $WorkbenchFacetCategoryCopyWith<$Res> implements $WorkbenchFacetCopyWith<$Res> {
  factory $WorkbenchFacetCategoryCopyWith(WorkbenchFacetCategory value, $Res Function(WorkbenchFacetCategory) _then) = _$WorkbenchFacetCategoryCopyWithImpl;
@useResult
$Res call({
 String category
});




}
/// @nodoc
class _$WorkbenchFacetCategoryCopyWithImpl<$Res>
    implements $WorkbenchFacetCategoryCopyWith<$Res> {
  _$WorkbenchFacetCategoryCopyWithImpl(this._self, this._then);

  final WorkbenchFacetCategory _self;
  final $Res Function(WorkbenchFacetCategory) _then;

/// Create a copy of WorkbenchFacet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? category = null,}) {
  return _then(WorkbenchFacetCategory(
null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
