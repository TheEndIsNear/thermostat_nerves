defmodule ThermostatNerves.Server do
  @moduledoc """
  gRPC server for sending temperature data to the Flutter UI.
  """

  use GRPC.Server, service: ThermostatNerves.RPC.Service, http_transcode: true

  @stream_interval_ms 2_000

  @doc """
  Unary RPC: returns the current temperature reading.
  """
  def send_temperature(_request, _stream) do
    read_temperature()
  end

  @doc """
  Server-streaming RPC: pushes temperature readings every #{@stream_interval_ms}ms.
  Runs until the client disconnects.
  """
  def stream_temperature(_request, stream) do
    stream_loop(stream)
  end

  defp stream_loop(stream) do
    reading = read_temperature()
    GRPC.Server.send_reply(stream, reading)
    Process.sleep(@stream_interval_ms)
    stream_loop(stream)
  end

  defp read_temperature do
    temp = PropertyTable.get(SensorTable, ["temperature"])

    %ThermostatNerves.TemperatureReading{
      value: temp || 0.0,
      unit: "C"
    }
  end
end
