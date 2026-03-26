// This is a generated file - do not edit.
//
// Generated from temperature.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use emptyDescriptor instead')
const Empty$json = {
  '1': 'Empty',
};

/// Descriptor for `Empty`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List emptyDescriptor =
    $convert.base64Decode('CgVFbXB0eQ==');

@$core.Deprecated('Use unitRequestDescriptor instead')
const UnitRequest$json = {
  '1': 'UnitRequest',
  '2': [
    {'1': 'unit', '3': 1, '4': 1, '5': 9, '10': 'unit'},
  ],
};

/// Descriptor for `UnitRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List unitRequestDescriptor =
    $convert.base64Decode('CgtVbml0UmVxdWVzdBISCgR1bml0GAEgASgJUgR1bml0');

@$core.Deprecated('Use timezoneRequestDescriptor instead')
const TimezoneRequest$json = {
  '1': 'TimezoneRequest',
  '2': [
    {'1': 'timezone', '3': 1, '4': 1, '5': 9, '10': 'timezone'},
  ],
};

/// Descriptor for `TimezoneRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timezoneRequestDescriptor = $convert.base64Decode(
    'Cg9UaW1lem9uZVJlcXVlc3QSGgoIdGltZXpvbmUYASABKAlSCHRpbWV6b25l');

@$core.Deprecated('Use timezoneListDescriptor instead')
const TimezoneList$json = {
  '1': 'TimezoneList',
  '2': [
    {'1': 'timezones', '3': 1, '4': 3, '5': 9, '10': 'timezones'},
  ],
};

/// Descriptor for `TimezoneList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timezoneListDescriptor = $convert.base64Decode(
    'CgxUaW1lem9uZUxpc3QSHAoJdGltZXpvbmVzGAEgAygJUgl0aW1lem9uZXM=');

@$core.Deprecated('Use temperatureReadingDescriptor instead')
const TemperatureReading$json = {
  '1': 'TemperatureReading',
  '2': [
    {'1': 'value', '3': 1, '4': 1, '5': 2, '10': 'value'},
    {'1': 'unit', '3': 2, '4': 1, '5': 9, '10': 'unit'},
  ],
};

/// Descriptor for `TemperatureReading`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List temperatureReadingDescriptor = $convert.base64Decode(
    'ChJUZW1wZXJhdHVyZVJlYWRpbmcSFAoFdmFsdWUYASABKAJSBXZhbHVlEhIKBHVuaXQYAiABKA'
    'lSBHVuaXQ=');
