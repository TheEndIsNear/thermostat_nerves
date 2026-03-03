defmodule ThermostatNerves.Sensors.TemperatureClient do
  @moduledoc """
  Behaviour for reading temperature from a sensor source.

  Implementations provide the hardware-specific (or mock) details while the
  `TemperatureSensor` GenServer remains agnostic of the underlying source.

  ## Implementations

  - `ThermostatNerves.Sensors.Ds18b20Impl` — real DS18B20 1-Wire sensor (target only)
  - `ThermostatNerves.Sensors.MockImpl` — cycling fake readings (host/dev/test)
  """

  @doc """
  Returns the sensor path (or identifier) to read from.

  Blocks/retries until a sensor is available. Returns `{:ok, sensor}` on
  success or `{:error, reason}` if the sensor cannot be found.
  """
  @callback list() :: {:ok, term()} | {:error, term()}

  @doc """
  Reads the current temperature from the given `sensor`.

  Returns `{:ok, float()}` on success or `{:error, reason}` on failure.
  """
  @callback read(sensor :: term()) :: {:ok, float()} | {:error, term()}
end
