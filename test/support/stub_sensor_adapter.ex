defmodule ThermostatNerves.Sensors.StubSensorAdapter do
  @moduledoc false

  use Agent

  @behaviour ThermostatNerves.Sensors.SensorAdapter

  @default_state %{
    sensors: ["/stub/28-000000000001"],
    reading: {:ok, "28-000000000001", 21.0}
  }

  def start_link(_opts \\ []) do
    Agent.start_link(fn -> @default_state end, name: __MODULE__)
  end

  @doc "Update a key in the stub state between tests."
  def put(key, value), do: Agent.update(__MODULE__, &Map.put(&1, key, value))

  @impl ThermostatNerves.Sensors.SensorAdapter
  def list_sensors, do: Agent.get(__MODULE__, & &1.sensors)

  @impl ThermostatNerves.Sensors.SensorAdapter
  def read_temperature_file(_sensor_path), do: Agent.get(__MODULE__, & &1.reading)
end
