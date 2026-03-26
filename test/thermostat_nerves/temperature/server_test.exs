defmodule ThermostatNerves.ServerTest do
  use ExUnit.Case, async: false

  alias ThermostatNerves.Server

  # The application already starts SensorTable. Clear its state before each test
  # so tests are isolated from each other and from sensor reads.
  setup do
    PropertyTable.delete(SensorTable, ["temperature"])
    PropertyTable.delete(SensorTable, ["unit"])
    :ok
  end

  describe "set_unit/2" do
    test "stores 'C' in the PropertyTable and returns Empty" do
      request = %ThermostatNerves.UnitRequest{unit: "C"}
      assert %ThermostatNerves.Empty{} = Server.set_unit(request, nil)
      assert PropertyTable.get(SensorTable, ["unit"]) == "C"
    end

    test "stores 'F' in the PropertyTable and returns Empty" do
      request = %ThermostatNerves.UnitRequest{unit: "F"}
      assert %ThermostatNerves.Empty{} = Server.set_unit(request, nil)
      assert PropertyTable.get(SensorTable, ["unit"]) == "F"
    end

    test "overrides a previously stored unit" do
      Server.set_unit(%ThermostatNerves.UnitRequest{unit: "C"}, nil)
      Server.set_unit(%ThermostatNerves.UnitRequest{unit: "F"}, nil)
      assert PropertyTable.get(SensorTable, ["unit"]) == "F"
    end
  end

  describe "send_temperature/2" do
    test "returns a TemperatureReading with Celsius value when no unit set" do
      PropertyTable.put(SensorTable, ["temperature"], 20.0)

      reading = Server.send_temperature(%ThermostatNerves.Empty{}, nil)

      assert %ThermostatNerves.TemperatureReading{value: value, unit: "C"} = reading
      assert_in_delta value, 20.0, 0.01
    end

    test "returns a TemperatureReading with Celsius value when unit is 'C'" do
      PropertyTable.put(SensorTable, ["temperature"], 20.0)
      PropertyTable.put(SensorTable, ["unit"], "C")

      reading = Server.send_temperature(%ThermostatNerves.Empty{}, nil)

      assert %ThermostatNerves.TemperatureReading{value: value, unit: "C"} = reading
      assert_in_delta value, 20.0, 0.01
    end

    test "converts temperature to Fahrenheit when unit is 'F'" do
      PropertyTable.put(SensorTable, ["temperature"], 0.0)
      PropertyTable.put(SensorTable, ["unit"], "F")

      reading = Server.send_temperature(%ThermostatNerves.Empty{}, nil)

      assert %ThermostatNerves.TemperatureReading{value: value, unit: "F"} = reading
      # 0°C == 32°F
      assert_in_delta value, 32.0, 0.01
    end

    test "converts 100°C to 212°F correctly" do
      PropertyTable.put(SensorTable, ["temperature"], 100.0)
      PropertyTable.put(SensorTable, ["unit"], "F")

      reading = Server.send_temperature(%ThermostatNerves.Empty{}, nil)

      assert %ThermostatNerves.TemperatureReading{value: value, unit: "F"} = reading
      assert_in_delta value, 212.0, 0.01
    end

    test "returns 0.0 when no temperature is stored (nil fallback)" do
      reading = Server.send_temperature(%ThermostatNerves.Empty{}, nil)

      assert %ThermostatNerves.TemperatureReading{value: value} = reading
      assert_in_delta value, 0.0, 0.01
    end

    test "reflects unit change from C to F without restarting" do
      PropertyTable.put(SensorTable, ["temperature"], 20.0)
      PropertyTable.put(SensorTable, ["unit"], "C")

      celsius_reading = Server.send_temperature(%ThermostatNerves.Empty{}, nil)
      assert_in_delta celsius_reading.value, 20.0, 0.01
      assert celsius_reading.unit == "C"

      PropertyTable.put(SensorTable, ["unit"], "F")

      fahrenheit_reading = Server.send_temperature(%ThermostatNerves.Empty{}, nil)
      # 20°C == 68°F
      assert_in_delta fahrenheit_reading.value, 68.0, 0.01
      assert fahrenheit_reading.unit == "F"
    end
  end

  describe "set_timezone/2" do
    test "accepts a valid IANA timezone and returns Empty" do
      request = %ThermostatNerves.TimezoneRequest{timezone: "America/New_York"}
      assert %ThermostatNerves.Empty{} = Server.set_timezone(request, nil)
    end

    test "accepts Etc/UTC and returns Empty" do
      request = %ThermostatNerves.TimezoneRequest{timezone: "Etc/UTC"}
      assert %ThermostatNerves.Empty{} = Server.set_timezone(request, nil)
    end

    test "raises a gRPC invalid_argument error for an unknown timezone" do
      request = %ThermostatNerves.TimezoneRequest{timezone: "Not/ATimezone"}

      assert_raise GRPC.RPCError, fn ->
        Server.set_timezone(request, nil)
      end
    end
  end

  describe "get_timezones/2" do
    test "returns a non-empty TimezoneList" do
      response = Server.get_timezones(%ThermostatNerves.Empty{}, nil)

      assert %ThermostatNerves.TimezoneList{timezones: timezones} = response
      assert is_list(timezones)
      assert timezones != []
    end

    test "returned list contains well-known IANA timezone strings" do
      response = Server.get_timezones(%ThermostatNerves.Empty{}, nil)

      assert "Etc/UTC" in response.timezones
      assert "America/New_York" in response.timezones
      assert "America/Denver" in response.timezones
      assert "America/Los_Angeles" in response.timezones
    end

    test "all returned entries are strings" do
      response = Server.get_timezones(%ThermostatNerves.Empty{}, nil)

      assert Enum.all?(response.timezones, &is_binary/1)
    end
  end
end
