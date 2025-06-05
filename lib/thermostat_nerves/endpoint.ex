defmodule ThermostatNerves.Endpoint do
  use GRPC.Endpoint

  intercept GRPC.Server.Interceptors.Logger
  run ThermostatNerves.Server
end
