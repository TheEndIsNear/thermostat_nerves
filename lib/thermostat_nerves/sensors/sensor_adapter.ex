defmodule ThermostatNerves.Sensors.SensorAdapter do
  @moduledoc """
  Behaviour for DS18B20 1-Wire sensor hardware access.

  The default implementation delegates to `Ds18b20_1w`. A different module
  can be configured for testing via:

      config :thermostat_nerves, :sensor_adapter, MyMockAdapter
  """

  @doc """
  Returns a list of sensor paths found on the 1-Wire bus.
  Returns an empty list when no sensors are attached.
  """
  @callback list_sensors() :: [String.t()]

  @doc """
  Reads the temperature from the sensor at the given path.
  Returns `{:ok, sensor_id, temperature_celsius}` on success,
  or `{:error, sensor_id, reason}` on failure.
  """
  @callback read_temperature_file(sensor_path :: String.t()) ::
              {:ok, String.t(), float()} | {:error, String.t(), term()}
end
