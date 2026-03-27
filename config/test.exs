import Config

# Use the stub adapter in tests so the GenServer never touches real hardware.
config :thermostat_nerves, :sensor_adapter, ThermostatNerves.Sensors.StubSensorAdapter
