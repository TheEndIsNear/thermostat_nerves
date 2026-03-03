defmodule ThermostatNerves.Sensors.StubClient do
  @moduledoc """
  A test-only `TemperatureClient` implementation backed by an `Agent`.

  Each test can create an independent stub and control both the temperature
  value returned and whether a read error is simulated.

  ## Usage

      stub = StubClient.new(21.5)
      StubClient.set_temperature(stub, 25.0)
      StubClient.set_error(stub, "sensor fault")
  """

  defstruct [:agent]

  @doc "Creates a new stub with an optional initial temperature (default 21.5 °C)."
  @spec new(float()) :: %__MODULE__{}
  def new(initial_temp \\ 21.5) do
    {:ok, agent} = Agent.start_link(fn -> {:ok, initial_temp} end)
    %__MODULE__{agent: agent}
  end

  @doc "Updates the stub so the next `read/2` returns `{:ok, temp}`."
  @spec set_temperature(%__MODULE__{}, float()) :: :ok
  def set_temperature(%__MODULE__{agent: agent}, temp),
    do: Agent.update(agent, fn _ -> {:ok, temp} end)

  @doc "Updates the stub so the next `read/2` returns `{:error, reason}`."
  @spec set_error(%__MODULE__{}, term()) :: :ok
  def set_error(%__MODULE__{agent: agent}, reason),
    do: Agent.update(agent, fn _ -> {:error, reason} end)
end

defimpl ThermostatNerves.Sensors.TemperatureClient,
  for: ThermostatNerves.Sensors.StubClient do
  alias ThermostatNerves.Sensors.StubClient

  @impl ThermostatNerves.Sensors.TemperatureClient
  def list(_client), do: {:ok, :stub_sensor}

  @impl ThermostatNerves.Sensors.TemperatureClient
  def read(%StubClient{agent: agent}, :stub_sensor),
    do: Agent.get(agent, & &1)
end
