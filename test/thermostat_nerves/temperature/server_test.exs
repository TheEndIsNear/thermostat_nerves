defmodule ThermostatNerves.ServerTest do
  use ExUnit.Case, async: false

  alias ThermostatNerves.RPC.Stub
  alias ThermostatNerves.TemperatureReading

  # ---------------------------------------------------------------------------
  # Setup
  # ---------------------------------------------------------------------------
  # The application starts a gRPC server on port 50051 as part of its
  # supervision tree, which uses the ranch listener named after
  # `ThermostatNerves.Endpoint`.  We stop that listener, bind a new one on a
  # free port (port: 0) for the test run, and restore the original afterward.
  #
  # `async: false` ensures no other test module interferes with the shared
  # `SensorTable` or the global gRPC endpoint listener name.
  # ---------------------------------------------------------------------------

  setup_all do
    # Stop the TemperatureSensor GenServer so its periodic writes don't race
    # with test assertions against SensorTable.
    :ok =
      Supervisor.terminate_child(
        ThermostatNerves.Supervisor,
        ThermostatNerves.Sensors.TemperatureSensor
      )

    on_exit(fn ->
      Supervisor.restart_child(
        ThermostatNerves.Supervisor,
        ThermostatNerves.Sensors.TemperatureSensor
      )
    end)

    # Stop the application's gRPC server to free the listener name.
    GRPC.Server.stop_endpoint(ThermostatNerves.Endpoint)

    {_ref, _pid, port} = GRPC.Server.start_endpoint(ThermostatNerves.Endpoint, 0)

    on_exit(fn ->
      # Stop our test endpoint. The app supervisor will automatically restart
      # its own endpoint on port 50_051.
      GRPC.Server.stop_endpoint(ThermostatNerves.Endpoint)
    end)

    {:ok, channel} = GRPC.Stub.connect("localhost:#{port}", [])

    on_exit(fn ->
      GRPC.Stub.disconnect(channel)
    end)

    {:ok, channel: channel}
  end

  setup do
    # Clear any leftover temperature between individual tests.
    PropertyTable.delete(SensorTable, ["temperature"])
    :ok
  end

  # ---------------------------------------------------------------------------
  # send_temperature — unary RPC
  # ---------------------------------------------------------------------------

  describe "send_temperature/2 (unary)" do
    test "returns 0.0 when no reading is stored", %{channel: channel} do
      assert {:ok, %TemperatureReading{value: value, unit: "C"}} =
               Stub.send_temperature(channel, %ThermostatNerves.Empty{})

      assert_in_delta value, 0.0, 0.001
    end

    test "returns the current temperature from SensorTable", %{channel: channel} do
      PropertyTable.put(SensorTable, ["temperature"], 21.3)

      assert {:ok, %TemperatureReading{value: value, unit: "C"}} =
               Stub.send_temperature(channel, %ThermostatNerves.Empty{})

      assert_in_delta value, 21.3, 0.01
    end

    test "reflects an updated temperature after the table is written", %{channel: channel} do
      PropertyTable.put(SensorTable, ["temperature"], 18.0)

      {:ok, %TemperatureReading{value: first}} =
        Stub.send_temperature(channel, %ThermostatNerves.Empty{})

      assert_in_delta first, 18.0, 0.01

      PropertyTable.put(SensorTable, ["temperature"], 25.0)

      {:ok, %TemperatureReading{value: second}} =
        Stub.send_temperature(channel, %ThermostatNerves.Empty{})

      assert_in_delta second, 25.0, 0.01
    end

    test "response unit is always Celsius", %{channel: channel} do
      assert {:ok, %TemperatureReading{unit: unit}} =
               Stub.send_temperature(channel, %ThermostatNerves.Empty{})

      assert unit == "C"
    end
  end

  # ---------------------------------------------------------------------------
  # stream_temperature — server-streaming RPC
  # ---------------------------------------------------------------------------

  describe "stream_temperature/2 (server-streaming)" do
    test "streams TemperatureReading structs", %{channel: channel} do
      PropertyTable.put(SensorTable, ["temperature"], 22.5)

      {:ok, stream} = Stub.stream_temperature(channel, %ThermostatNerves.Empty{})

      reading =
        stream
        |> Enum.take(1)
        |> List.first()

      assert {:ok, %TemperatureReading{value: value, unit: "C"}} = reading
      assert_in_delta value, 22.5, 0.01
    end

    test "streams multiple readings", %{channel: channel} do
      PropertyTable.put(SensorTable, ["temperature"], 19.0)

      {:ok, stream} = Stub.stream_temperature(channel, %ThermostatNerves.Empty{})
      readings = Enum.take(stream, 2)

      assert length(readings) == 2

      for {:ok, %TemperatureReading{unit: unit}} <- readings do
        assert unit == "C"
      end
    end
  end
end
