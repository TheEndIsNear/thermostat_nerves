defmodule ThermostatNerves.Server do
  @moduledoc """
  Server for GRPO to enable sending data to and from the UI
  """

  use GRPC.Server, service: ThermostatNerves.RPC.Service, http_transcode: true

  @doc """
    gRPC function to send the current temperature
  """
  def send_temperature(_request, _stream) do
    temp = PropertyTable.get(SensorTable, ["temperature"])

    %ThermostatNerves.TemperatureReading{
      value: temp,
      unit: "C"
    }
  end
end
