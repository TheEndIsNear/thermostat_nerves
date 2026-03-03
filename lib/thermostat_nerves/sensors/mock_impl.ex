defmodule ThermostatNerves.Sensors.MockImpl do
  @moduledoc """
  `TemperatureClient` protocol implementation for local host development.

  Returns a simulated temperature that cycles sinusoidally between roughly
  18 °C and 26 °C, advancing on every `read/2` call. This lets the gRPC
  server stream realistic-looking data without any hardware attached.

  `list/1` returns immediately with a placeholder sensor identifier so
  the `TemperatureSensor` GenServer does not block on startup.
  """

  defstruct []

  @type t :: %__MODULE__{}

  @doc "Returns a new `MockImpl` struct."
  @spec new() :: t()
  def new, do: %__MODULE__{}
end

defimpl ThermostatNerves.Sensors.TemperatureClient, for: ThermostatNerves.Sensors.MockImpl do
  import :math, only: [sin: 1, pi: 0]

  @mock_sensor "mock_sensor"

  # Cycle period in milliseconds — one full sine wave every 60 seconds.
  @period_ms 60_000

  @impl ThermostatNerves.Sensors.TemperatureClient
  def list(_client), do: {:ok, @mock_sensor}

  @impl ThermostatNerves.Sensors.TemperatureClient
  def read(_client, @mock_sensor) do
    # Derive temperature from wall-clock time so the value changes smoothly
    # and is consistent across process restarts.
    t = rem(:os.system_time(:millisecond), @period_ms) / @period_ms
    temp = 22.0 + 4.0 * sin(2 * pi() * t)
    {:ok, Float.round(temp, 1)}
  end
end
