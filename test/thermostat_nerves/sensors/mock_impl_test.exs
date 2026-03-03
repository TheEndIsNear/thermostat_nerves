defmodule ThermostatNerves.Sensors.MockImplTest do
  use ExUnit.Case, async: true

  alias ThermostatNerves.Sensors.MockImpl
  alias ThermostatNerves.Sensors.TemperatureClient

  describe "list/1" do
    test "returns ok immediately without blocking" do
      client = MockImpl.new()
      assert {:ok, sensor} = TemperatureClient.list(client)
      assert is_binary(sensor)
    end
  end

  describe "read/2" do
    test "returns a float temperature" do
      client = MockImpl.new()
      {:ok, sensor} = TemperatureClient.list(client)

      assert {:ok, temp} = TemperatureClient.read(client, sensor)
      assert is_float(temp)
    end

    test "temperature is within the simulated range (18.0..26.0)" do
      client = MockImpl.new()
      {:ok, sensor} = TemperatureClient.list(client)

      {:ok, temp} = TemperatureClient.read(client, sensor)
      assert temp >= 18.0
      assert temp <= 26.0
    end

    test "temperature is rounded to one decimal place" do
      client = MockImpl.new()
      {:ok, sensor} = TemperatureClient.list(client)

      {:ok, temp} = TemperatureClient.read(client, sensor)
      assert Float.round(temp, 1) == temp
    end
  end
end
