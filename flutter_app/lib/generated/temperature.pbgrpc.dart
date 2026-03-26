// This is a generated file - do not edit.
//
// Generated from temperature.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'temperature.pb.dart' as $0;

export 'temperature.pb.dart';

@$pb.GrpcServiceName('ThermostatNerves.RPC')
class RPCClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  RPCClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.TemperatureReading> sendTemperature(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$sendTemperature, request, options: options);
  }

  $grpc.ResponseStream<$0.TemperatureReading> streamTemperature(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$streamTemperature, $async.Stream.fromIterable([request]),
        options: options);
  }

  $grpc.ResponseFuture<$0.Empty> setUnit(
    $0.UnitRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setUnit, request, options: options);
  }

  $grpc.ResponseFuture<$0.Empty> setTimezone(
    $0.TimezoneRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$setTimezone, request, options: options);
  }

  $grpc.ResponseFuture<$0.TimezoneList> getTimezones(
    $0.Empty request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$getTimezones, request, options: options);
  }

  // method descriptors

  static final _$sendTemperature =
      $grpc.ClientMethod<$0.Empty, $0.TemperatureReading>(
          '/ThermostatNerves.RPC/sendTemperature',
          ($0.Empty value) => value.writeToBuffer(),
          $0.TemperatureReading.fromBuffer);
  static final _$streamTemperature =
      $grpc.ClientMethod<$0.Empty, $0.TemperatureReading>(
          '/ThermostatNerves.RPC/streamTemperature',
          ($0.Empty value) => value.writeToBuffer(),
          $0.TemperatureReading.fromBuffer);
  static final _$setUnit = $grpc.ClientMethod<$0.UnitRequest, $0.Empty>(
      '/ThermostatNerves.RPC/setUnit',
      ($0.UnitRequest value) => value.writeToBuffer(),
      $0.Empty.fromBuffer);
  static final _$setTimezone = $grpc.ClientMethod<$0.TimezoneRequest, $0.Empty>(
      '/ThermostatNerves.RPC/setTimezone',
      ($0.TimezoneRequest value) => value.writeToBuffer(),
      $0.Empty.fromBuffer);
  static final _$getTimezones = $grpc.ClientMethod<$0.Empty, $0.TimezoneList>(
      '/ThermostatNerves.RPC/getTimezones',
      ($0.Empty value) => value.writeToBuffer(),
      $0.TimezoneList.fromBuffer);
}

@$pb.GrpcServiceName('ThermostatNerves.RPC')
abstract class RPCServiceBase extends $grpc.Service {
  $core.String get $name => 'ThermostatNerves.RPC';

  RPCServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.TemperatureReading>(
        'sendTemperature',
        sendTemperature_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.TemperatureReading value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.TemperatureReading>(
        'streamTemperature',
        streamTemperature_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.TemperatureReading value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.UnitRequest, $0.Empty>(
        'setUnit',
        setUnit_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.UnitRequest.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.TimezoneRequest, $0.Empty>(
        'setTimezone',
        setTimezone_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.TimezoneRequest.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.TimezoneList>(
        'getTimezones',
        getTimezones_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.TimezoneList value) => value.writeToBuffer()));
  }

  $async.Future<$0.TemperatureReading> sendTemperature_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return sendTemperature($call, await $request);
  }

  $async.Future<$0.TemperatureReading> sendTemperature(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Stream<$0.TemperatureReading> streamTemperature_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async* {
    yield* streamTemperature($call, await $request);
  }

  $async.Stream<$0.TemperatureReading> streamTemperature(
      $grpc.ServiceCall call, $0.Empty request);

  $async.Future<$0.Empty> setUnit_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.UnitRequest> $request) async {
    return setUnit($call, await $request);
  }

  $async.Future<$0.Empty> setUnit(
      $grpc.ServiceCall call, $0.UnitRequest request);

  $async.Future<$0.Empty> setTimezone_Pre($grpc.ServiceCall $call,
      $async.Future<$0.TimezoneRequest> $request) async {
    return setTimezone($call, await $request);
  }

  $async.Future<$0.Empty> setTimezone(
      $grpc.ServiceCall call, $0.TimezoneRequest request);

  $async.Future<$0.TimezoneList> getTimezones_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return getTimezones($call, await $request);
  }

  $async.Future<$0.TimezoneList> getTimezones(
      $grpc.ServiceCall call, $0.Empty request);
}
