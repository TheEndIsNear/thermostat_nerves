// This is a generated file - do not edit.
//
// Generated from temperature.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Empty extends $pb.GeneratedMessage {
  factory Empty() => create();

  Empty._();

  factory Empty.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory Empty.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'Empty',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'ThermostatNerves'),
      createEmptyInstance: create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Empty clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Empty copyWith(void Function(Empty) updates) =>
      super.copyWith((message) => updates(message as Empty)) as Empty;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Empty create() => Empty._();
  @$core.override
  Empty createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static Empty getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Empty>(create);
  static Empty? _defaultInstance;
}

class UnitRequest extends $pb.GeneratedMessage {
  factory UnitRequest({
    $core.String? unit,
  }) {
    final result = create();
    if (unit != null) result.unit = unit;
    return result;
  }

  UnitRequest._();

  factory UnitRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UnitRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UnitRequest',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'ThermostatNerves'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'unit')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnitRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnitRequest copyWith(void Function(UnitRequest) updates) =>
      super.copyWith((message) => updates(message as UnitRequest))
          as UnitRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnitRequest create() => UnitRequest._();
  @$core.override
  UnitRequest createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UnitRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UnitRequest>(create);
  static UnitRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get unit => $_getSZ(0);
  @$pb.TagNumber(1)
  set unit($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUnit() => $_has(0);
  @$pb.TagNumber(1)
  void clearUnit() => $_clearField(1);
}

class TemperatureReading extends $pb.GeneratedMessage {
  factory TemperatureReading({
    $core.double? value,
    $core.String? unit,
  }) {
    final result = create();
    if (value != null) result.value = value;
    if (unit != null) result.unit = unit;
    return result;
  }

  TemperatureReading._();

  factory TemperatureReading.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TemperatureReading.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TemperatureReading',
      package:
          const $pb.PackageName(_omitMessageNames ? '' : 'ThermostatNerves'),
      createEmptyInstance: create)
    ..aD(1, _omitFieldNames ? '' : 'value', fieldType: $pb.PbFieldType.OF)
    ..aOS(2, _omitFieldNames ? '' : 'unit')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TemperatureReading clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TemperatureReading copyWith(void Function(TemperatureReading) updates) =>
      super.copyWith((message) => updates(message as TemperatureReading))
          as TemperatureReading;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TemperatureReading create() => TemperatureReading._();
  @$core.override
  TemperatureReading createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TemperatureReading getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TemperatureReading>(create);
  static TemperatureReading? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get value => $_getN(0);
  @$pb.TagNumber(1)
  set value($core.double value) => $_setFloat(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValue() => $_has(0);
  @$pb.TagNumber(1)
  void clearValue() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get unit => $_getSZ(1);
  @$pb.TagNumber(2)
  set unit($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUnit() => $_has(1);
  @$pb.TagNumber(2)
  void clearUnit() => $_clearField(2);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
