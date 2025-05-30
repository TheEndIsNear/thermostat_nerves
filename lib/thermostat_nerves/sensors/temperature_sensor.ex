defmodule ThermostatNerves.Sensors.TemperatureSensor do
  @moduledoc """
    GenServer for handling the reading of a DS18b20 1 wire temperature sensor. Stores the value of
    the temperature PropertyTable
  """
  use GenServer

  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, name: __MODULE__)
  end

  @impl GenServer
  def init(_) do
    {:ok, %{sensor_path: "", temperature: nil}, {:continue, :read_sensor}}
  end

  @impl GenServer
  def handle_continue(:read_sensor, state) do
    sensor_path = list_sensor()
    Logger.info(sensor_path)
    read_sensor(sensor_path)

    schedule_next_read()
    {:noreply, %{state | sensor_path: sensor_path}}
  end

  @impl GenServer
  def handle_info(:read_sensor, %{sensor_path: sensor_path} = state) do
    read_sensor(sensor_path)

    schedule_next_read()
    {:noreply, state}
  end

  defp list_sensor do
    case Ds18b20_1w.list_sensors() do
      [sensor_path] ->
        sensor_path

      _ ->
        :timer.sleep(100)
        list_sensor()
    end
  end

  defp read_sensor(sensor_path) do
    case Ds18b20_1w.read_temperature_file(sensor_path) do
      {:ok, _, temp} ->
        PropertyTable.put(SensorTable, ["temperature"], temp)

      {:error, sensor, error} ->
        Logger.error("Error reading sensor #{sensor} #{error}")
    end
  end

  defp schedule_next_read, do: Process.send_after(self(), :read_sensor, :timer.seconds(5))
end
