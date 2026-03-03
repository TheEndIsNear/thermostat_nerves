defmodule ThermostatNerves.Sensors.MockImplTest do
  use ExUnit.Case, async: true

  alias ThermostatNerves.Sensors.MockImpl

  describe "list/0" do
    test "returns ok immediately without blocking" do
      assert {:ok, sensor} = MockImpl.list()
      assert is_binary(sensor)
    end
  end

  describe "read/1" do
    test "returns a float temperature" do
      {:ok, sensor} = MockImpl.list()
      assert {:ok, temp} = MockImpl.read(sensor)
      assert is_float(temp)
    end

    test "temperature is within the simulated range (18.0..26.0)" do
      {:ok, sensor} = MockImpl.list()
      {:ok, temp} = MockImpl.read(sensor)
      assert temp >= 18.0
      assert temp <= 26.0
    end

    test "temperature is rounded to one decimal place" do
      {:ok, sensor} = MockImpl.list()
      {:ok, temp} = MockImpl.read(sensor)
      assert Float.round(temp, 1) == temp
    end
  end
end
