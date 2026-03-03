defmodule ThermostatNerves.Sensors.Ds18b20Impl do
  @moduledoc """
  `TemperatureClient` behaviour implementation for the DS18B20 1-Wire sensor.

  Wraps the `Ds18b20_1w` library. Intended for use on the target device only.
  `list/0` blocks with a 100 ms retry loop until exactly one sensor is
  detected on the bus.
  """

  @behaviour ThermostatNerves.Sensors.TemperatureClient

  require Logger

  @impl ThermostatNerves.Sensors.TemperatureClient
  def list do
    case Ds18b20_1w.list_sensors() do
      [sensor_path] ->
        {:ok, sensor_path}

      _ ->
        Process.sleep(100)
        list()
    end
  end

  @impl ThermostatNerves.Sensors.TemperatureClient
  def read(sensor_path) do
    case Ds18b20_1w.read_temperature_file(sensor_path) do
      {:ok, _, temp} ->
        {:ok, temp}

      {:error, sensor, error} ->
        {:error, "Error reading sensor #{sensor}: #{error}"}
    end
  end
end
