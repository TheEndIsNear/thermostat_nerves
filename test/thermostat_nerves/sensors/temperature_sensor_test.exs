defmodule ThermostatNerves.Sensors.TemperatureSensorTest do
  use ExUnit.Case, async: true

  alias ThermostatNerves.Sensors.StubClient
  alias ThermostatNerves.Sensors.TemperatureSensor

  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------

  defp start_sensor(stub) do
    table = :"SensorTable_#{System.unique_integer([:positive])}"
    start_supervised!({PropertyTable, name: table})
    start_supervised!({TemperatureSensor, {table, stub}})
    # Allow handle_continue to complete before asserting.
    Process.sleep(50)
    table
  end

  # ---------------------------------------------------------------------------
  # Tests
  # ---------------------------------------------------------------------------

  describe "initialisation" do
    test "reads the initial temperature into the PropertyTable on start" do
      stub = StubClient.new(23.0)
      table = start_sensor(stub)

      assert PropertyTable.get(table, ["temperature"]) == 23.0
    end
  end

  describe "periodic reads" do
    test "updates the PropertyTable when the temperature changes" do
      stub = StubClient.new(20.0)
      table = start_sensor(stub)

      assert PropertyTable.get(table, ["temperature"]) == 20.0

      StubClient.set_temperature(stub, 25.5)
      # Wait long enough for at least one @read_interval_ms (100 ms) tick.
      Process.sleep(200)

      assert PropertyTable.get(table, ["temperature"]) == 25.5
    end

    test "does not update the PropertyTable on a read error" do
      stub = StubClient.new(18.0)
      table = start_sensor(stub)

      assert PropertyTable.get(table, ["temperature"]) == 18.0

      StubClient.set_error(stub, "sensor disconnected")
      Process.sleep(200)

      # Value must remain at the last successful reading.
      assert PropertyTable.get(table, ["temperature"]) == 18.0
    end
  end
end
