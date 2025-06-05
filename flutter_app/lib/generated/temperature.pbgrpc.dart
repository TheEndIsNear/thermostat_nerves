//
//  Generated code. Do not modify.
//  source: temperature.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names

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

  static final _$sendTemperature = $grpc.ClientMethod<$0.Empty, $0.TemperatureReading>(
      '/ThermostatNerves.RPC/sendTemperature',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.TemperatureReading.fromBuffer(value));

  RPCClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseFuture<$0.TemperatureReading> sendTemperature($0.Empty request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$sendTemperature, request, options: options);
  }
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
  }

  $async.Future<$0.TemperatureReading> sendTemperature_Pre($grpc.ServiceCall $call, $async.Future<$0.Empty> $request) async {
    return sendTemperature($call, await $request);
  }

  $async.Future<$0.TemperatureReading> sendTemperature($grpc.ServiceCall call, $0.Empty request);
}
