defmodule ThermostatNerves.Sensors.StubClient do
  @moduledoc """
  A test-only `TemperatureClient` behaviour implementation backed by an `Agent`.

  Each test process gets its own isolated agent (keyed by the test PID), so
  tests running concurrently do not interfere with each other.

  ## Usage

      StubClient.start(self(), 21.5)
      StubClient.set_temperature(self(), 25.0)
      StubClient.set_error(self(), "sensor fault")

  Pass the test PID (or any unique key) when starting the sensor:

      start_supervised!({TemperatureSensor, {table, StubClient}})

  The GenServer will call `StubClient.list/0` and `StubClient.read/1`, which
  look up the agent registered under the **calling process's** PID. For this
  to work, the test must start the agent before starting the sensor, and the
  sensor GenServer must have been started with the test process as the owner.
  Because the sensor GenServer is a child of the test, the agent owner is
  inherited through the call chain via the registered name.

  In practice: register the agent under the test PID and pass that PID to
  `start/2`. The behaviour callbacks resolve the agent via the test PID stored
  at startup.
  """

  @behaviour ThermostatNerves.Sensors.TemperatureClient

  @stub_sensor :stub_sensor

  @doc "Starts the stub agent for `owner` with an initial temperature."
  @spec start(pid(), float()) :: {:ok, pid()}
  def start(owner, initial_temp \\ 21.5) do
    Agent.start_link(fn -> {:ok, initial_temp} end, name: agent_name(owner))
  end

  @doc "Updates the stub so the next `read/1` returns `{:ok, temp}`."
  @spec set_temperature(pid(), float()) :: :ok
  def set_temperature(owner, temp),
    do: Agent.update(agent_name(owner), fn _ -> {:ok, temp} end)

  @doc "Updates the stub so the next `read/1` returns `{:error, reason}`."
  @spec set_error(pid(), term()) :: :ok
  def set_error(owner, reason),
    do: Agent.update(agent_name(owner), fn _ -> {:error, reason} end)

  @impl ThermostatNerves.Sensors.TemperatureClient
  def list, do: {:ok, @stub_sensor}

  @impl ThermostatNerves.Sensors.TemperatureClient
  def read(@stub_sensor) do
    Agent.get(agent_name(owner_pid()), & &1)
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp agent_name(pid), do: :"stub_client_#{:erlang.pid_to_list(pid)}"

  # Walk the $ancestors chain to find the process that registered an agent.
  # `start_supervised!` nests the GenServer under ExUnit supervisors, so the
  # test PID may not be the direct parent — but it will be somewhere in the list.
  defp owner_pid do
    ancestors = Process.get(:"$ancestors", [])

    Enum.find(ancestors, fn pid ->
      is_pid(pid) and Process.whereis(agent_name(pid)) != nil
    end) || self()
  end
end
