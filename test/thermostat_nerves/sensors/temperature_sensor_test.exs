defmodule ThermostatNerves.Sensors.TemperatureSensorTest do
  use ExUnit.Case, async: false

  alias ThermostatNerves.Sensors.StubSensorAdapter

  # The application supervision tree already starts TemperatureSensor under the
  # registered name __MODULE__. We interact with it by:
  #   1. Configuring the StubSensorAdapter before the GenServer processes a message.
  #   2. Observing the side-effect in SensorTable via PropertyTable.
  #
  # Because the sensor loop runs every 100 ms we poll SensorTable with a short
  # timeout rather than calling private functions directly.

  setup do
    # Reset adapter to a known good state before each test.
    StubSensorAdapter.put(:sensors, ["/stub/28-000000000001"])
    StubSensorAdapter.put(:reading, {:ok, "28-000000000001", 21.0})

    # Clear sensor reading so assertions are not contaminated by a prior test.
    PropertyTable.delete(SensorTable, ["temperature"])

    :ok
  end

  describe "handle_info(:read_sensor, ...)" do
    test "stores a successful temperature reading in SensorTable" do
      StubSensorAdapter.put(:reading, {:ok, "28-000000000001", 25.5})

      assert_temperature_stored(25.5)
    end

    test "updates the stored temperature when the sensor value changes" do
      StubSensorAdapter.put(:reading, {:ok, "28-000000000001", 10.0})
      assert_temperature_stored(10.0)

      StubSensorAdapter.put(:reading, {:ok, "28-000000000001", 99.9})
      assert_temperature_stored(99.9)
    end

    test "does not update SensorTable on a read error" do
      # Pre-populate a known value then switch the adapter to return an error.
      PropertyTable.put(SensorTable, ["temperature"], 20.0)

      StubSensorAdapter.put(:reading, {:error, "28-000000000001", :enoent})

      # Give the sensor loop a couple of cycles to fire — value must stay at 20.0.
      Process.sleep(300)

      assert PropertyTable.get(SensorTable, ["temperature"]) == 20.0
    end
  end

  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------

  # Polls SensorTable until the expected value appears or the timeout expires.
  defp assert_temperature_stored(expected, timeout \\ 500) do
    deadline = System.monotonic_time(:millisecond) + timeout

    result =
      Enum.reduce_while(Stream.repeatedly(fn -> :poll end), nil, fn _, _ ->
        value = PropertyTable.get(SensorTable, ["temperature"])

        cond do
          value == expected ->
            {:halt, :ok}

          System.monotonic_time(:millisecond) >= deadline ->
            {:halt, :timeout}

          true ->
            Process.sleep(10)
            {:cont, nil}
        end
      end)

    assert result == :ok, "Expected #{inspect(expected)} in SensorTable within #{timeout}ms"
    assert PropertyTable.get(SensorTable, ["temperature"]) == expected
  end
end
