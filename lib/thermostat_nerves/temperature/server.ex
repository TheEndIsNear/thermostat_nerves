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

  @doc """
  Unary RPC: sets the preferred temperature unit ("C" or "F") in the PropertyTable.
  """
  def set_unit(%ThermostatNerves.UnitRequest{unit: unit}, _stream)
      when unit in ["C", "F"] do
    PropertyTable.put(SensorTable, ["unit"], unit)
    %ThermostatNerves.Empty{}
  end

  defp stream_loop(stream) do
    reading = read_temperature()
    GRPC.Server.send_reply(stream, reading)
    Process.sleep(@stream_interval_ms)
    stream_loop(stream)
  end

  defp read_temperature do
    temp_c = PropertyTable.get(SensorTable, ["temperature"])
    unit = PropertyTable.get(SensorTable, ["unit"]) || "C"

    value =
      case unit do
        "F" -> celsius_to_fahrenheit(temp_c || 0.0)
        _ -> temp_c || 0.0
      end

    %ThermostatNerves.TemperatureReading{
      value: value,
      unit: unit
    }
  end

  defp celsius_to_fahrenheit(celsius), do: celsius * 9 / 5 + 32
end
