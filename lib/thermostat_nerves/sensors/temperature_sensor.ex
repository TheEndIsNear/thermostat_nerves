defmodule ThermostatNerves.Sensors.TemperatureSensor do
  @moduledoc """
  GenServer that periodically reads temperature and stores it in a PropertyTable.

  The hardware details are abstracted behind the `TemperatureClient` behaviour.
  The concrete implementation is injected at startup via the application
  environment key `:temperature_client`, allowing the real DS18B20 driver to
  be used on target and a mock to be used on host without changing this module.

  ## Configuration

      # host.exs
      config :thermostat_nerves, :temperature_client,
        ThermostatNerves.Sensors.MockImpl

      # target.exs
      config :thermostat_nerves, :temperature_client,
        ThermostatNerves.Sensors.Ds18b20Impl

  ## Test injection

  For unit tests, pass `{table_name, client_module}` as the init arg to
  `start_link/1` to bypass config and use a stub module against an
  isolated PropertyTable:

      start_supervised({TemperatureSensor, {my_table, MyStubClient}})
  """

  use GenServer

  require Logger

  @read_interval_ms 100

  @doc """
  Starts the sensor GenServer.

  When called from the supervision tree (no args), the client module is
  resolved from application config and readings are written to `SensorTable`.

  For testing, pass `{table_name, client_module}` to inject a specific
  PropertyTable and client module directly.
  """
  def start_link(opts \\ [])

  def start_link({table, client}) do
    GenServer.start_link(__MODULE__, {table, client})
  end

  def start_link(_) do
    GenServer.start_link(__MODULE__, :from_config, name: __MODULE__)
  end

  @impl GenServer
  def init(:from_config) do
    client = Application.fetch_env!(:thermostat_nerves, :temperature_client)
    {:ok, %{table: SensorTable, client: client, sensor: nil}, {:continue, :init_sensor}}
  end

  def init({table, client}) do
    {:ok, %{table: table, client: client, sensor: nil}, {:continue, :init_sensor}}
  end

  @impl GenServer
  def handle_continue(:init_sensor, %{client: client} = state) do
    {:ok, sensor} = client.list()
    Logger.info("Temperature sensor found: #{inspect(sensor)}")
    read_and_store(state.table, client, sensor)
    schedule_next_read()
    {:noreply, %{state | sensor: sensor}}
  end

  @impl GenServer
  def handle_info(:read_sensor, %{table: table, client: client, sensor: sensor} = state) do
    read_and_store(table, client, sensor)
    schedule_next_read()
    {:noreply, state}
  end

  defp read_and_store(table, client, sensor) do
    case client.read(sensor) do
      {:ok, temp} ->
        PropertyTable.put(table, ["temperature"], temp)

      {:error, reason} ->
        Logger.error("Failed to read temperature: #{reason}")
    end
  end

  defp schedule_next_read, do: Process.send_after(self(), :read_sensor, @read_interval_ms)
end
