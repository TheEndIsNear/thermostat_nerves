# AGENTS.md - Coding Agent Guidelines

## Project Overview

Elixir/Nerves IoT thermostat running on Raspberry Pi 5. Reads temperature from a
DS18B20 1-Wire sensor, stores readings in a PropertyTable, exposes them via gRPC
(port 50051), and renders a Flutter UI on the device display.

**Architecture**: DS18B20 sensor -> `TemperatureSensor` GenServer -> `PropertyTable`
(`SensorTable`) -> gRPC Server -> Flutter UI

**Key tech**: Elixir 1.18+, Nerves (rpi5 target), gRPC + Protobuf, Flutter (Dart),
PropertyTable for in-process state.

## File Layout

```
lib/
  thermostat_nerves.ex              # Root module (placeholder)
  thermostat_nerves/
    application.ex                  # OTP Application & supervision tree
    endpoint.ex                     # gRPC endpoint (routes to Server)
    sensors/
      temperature_client.ex         # Behaviour: @callback list/0 and @callback read/1
      ds18b20_impl.ex               # Real hardware impl (target only)
      mock_impl.ex                  # Host/dev/test impl (sinusoidal ~18–26°C)
      temperature_sensor.ex         # DS18B20 GenServer (reads sensor, writes PropertyTable)
    temperature/
      server.ex                     # gRPC service implementation (reads PropertyTable)
  temperature.pb.ex                 # GENERATED -- protobuf structs & service definition
config/
  config.exs                        # Common config (loads host.exs or target.exs)
  host.exs                          # Dev/test overrides (sets :temperature_client to MockImpl)
  target.exs                        # Device networking, SSH, mDNS, WiFi (sets :temperature_client to Ds18b20Impl)
priv/protos/
  temperature.proto                 # Protobuf service definition (source of truth)
flutter_app/                        # Flutter UI (thermostat_ui), built during release
test/
  support/
    stub_client.ex                  # StubClient module implementing TemperatureClient behaviour for tests
  thermostat_nerves/
    sensors/
      mock_impl_test.exs
      temperature_sensor_test.exs
    temperature/
      server_test.exs
```

## Supervision Tree

```
ThermostatNerves.Supervisor (:one_for_one)
├── {PropertyTable, name: SensorTable}
├── ThermostatNerves.Sensors.TemperatureSensor   (GenServer)
├── GRPC.Server.Supervisor                       (port 50051)
└── [target only] NervesFlutterSupport Engine     (Flutter embedder)
```

New processes go into `application.ex` `children` list. Target-only children
go in `target_children/0`.

## Build & Development Commands

```bash
mix deps.get          # Fetch dependencies
mix compile           # Compile
mix run --no-halt     # Run locally (host target, no hardware needed)
iex -S mix            # Interactive shell
```

### Testing

```bash
mix test                                    # Run all tests
mix test test/thermostat_nerves_test.exs     # Run a single test file
mix test test/thermostat_nerves_test.exs:5   # Run a single test by line number
mix test --trace                            # Verbose output
mix test --failed                           # Re-run only failed tests
```

Tests run on the host target by default (configured in `mix.exs` `cli/0`).
Test files live in `test/` and use `ExUnit.Case`.

### Linting & Static Analysis

```bash
mix format --check-formatted    # Check formatting
mix format                      # Auto-format
mix credo                       # Linting
mix credo --strict              # Strict linting
mix dialyzer                    # Static type analysis (slow first run)
```

### Verification Checklist

Run before submitting changes:

```bash
mix format --check-formatted && mix credo --strict && mix test && mix compile --warnings-as-errors
```

### Firmware (target device)

```bash
export MIX_TARGET=rpi5    # REQUIRED before any firmware commands
mix deps.get
mix firmware              # Build firmware
./upload.sh               # Upload over SSH
mix firmware.burn         # Burn to SD card
```

### Protobuf Code Generation

Only needed when modifying `priv/protos/temperature.proto`:

```bash
# Generates both Elixir (lib/temperature.pb.ex) and Dart (flutter_app/lib/generated/)
bash proto_gen.sh
```

**Do not hand-edit** `lib/temperature.pb.ex` or `flutter_app/lib/generated/` -- these
are generated files.

## Code Style Guidelines

### Formatting

- Use `mix format` before committing. The project uses the standard Elixir formatter.
- Configuration is in `.formatter.exs` -- imports formatting rules from `:grpc` and
  `:protobuf` deps.
- Line length follows the Elixir default (98 characters).

### Module Structure

Follow this order within each module:

1. `@moduledoc` (use `@moduledoc false` for internal/private modules)
2. `use` / `require` / `import` / `alias` declarations
3. Module attributes (`@impl`, `@doc`, constants like `@stream_interval_ms`)
4. Public functions
5. Private functions (prefixed with `defp`)
6. Callback implementations grouped together

### Naming Conventions

- **Modules**: `PascalCase`, namespaced under `ThermostatNerves.*`
  - Sensors: `ThermostatNerves.Sensors.*`
  - gRPC: `ThermostatNerves.Server`, `ThermostatNerves.Endpoint`
- **Functions/variables**: `snake_case`
- **Module attributes**: `@snake_case` (e.g., `@stream_interval_ms`)
- **Test modules**: `<ModuleName>Test` (e.g., `ThermostatNervesTest`)
- **Atoms for messages**: `:snake_case` (e.g., `:read_sensor`)

### Imports & Aliases

- Prefer `alias` over full module paths for repeated references.
- Group aliases at the top of the module after `use`/`require` statements.
- Example from the codebase:
  ```elixir
  alias NervesFlutterSupport.Flutter.Engine
  alias NervesFlutterSupport.Udev
  ```

### OTP & GenServer Patterns

- Always annotate callbacks with `@impl true` or `@impl GenServer` / `@impl Application`.
- Use `{:continue, atom}` for post-init work that shouldn't block `start_link`.
- Use `Process.send_after/3` for periodic work (not `:timer` for recurring).
- Pattern match on message atoms in `handle_info` (e.g., `:read_sensor`).
- State is a plain map -- no struct is used for GenServer state in this project.

### Error Handling

- Use `case` with pattern matching on `{:ok, _}` / `{:error, _}` tuples.
- Log errors with `Logger.error/1` -- don't silently swallow failures.
- For hardware-dependent retries, use recursive calls with a sleep
  (see `list_sensor/0` and `get_output_card/0` patterns).
- Let supervisors handle process crashes (`:one_for_one` strategy).

### Documentation

- Public modules should have `@moduledoc` with a description.
- Internal/generated modules use `@moduledoc false`.
- Public functions should have `@doc` strings.
- Use doctest format in `@doc` for simple pure functions.

### Testing

- Test files mirror `lib/` structure under `test/`.
- Use `use ExUnit.Case` in test modules.
- Use `doctest ModuleName` to run doctests.
- Tests are named descriptively: `test "description" do ... end`.
- Add `test/support` to `elixirc_paths(:test)` in `mix.exs` for shared test helpers.
- Start `GRPC.Client.Supervisor` in `test/test_helper.exs` for tests that open gRPC client channels.

### gRPC Client Return Types

- **Unary RPCs** (`Stub.send_temperature/2`) return `{:ok, %TemperatureReading{}}` — pattern match directly.
- **Server-streaming RPCs** (`Stub.stream_temperature/2`) return `{:ok, Enumerable.t()}` — you must unwrap
  the tuple before enumerating:
  ```elixir
  {:ok, stream} = Stub.stream_temperature(channel, %Empty{})
  readings = Enum.take(stream, 3)
  ```
  Each item in the enumerable is itself `{:ok, %TemperatureReading{}}` or `{:error, error}`.

## Extending the Project

### Adding a New Sensor

The project uses the **behaviour + adapter pattern** for every sensor type:

- A `@behaviour` module defines the contract (e.g., `TemperatureClient` with `list/0` and `read/1`).
- A real implementation (`Ds18b20Impl`) uses `@behaviour` and `@impl` — target hardware only.
- A mock implementation (`MockImpl`) uses `@behaviour` and `@impl` — host/dev, returns
  synthetic data (e.g., sinusoidal values).
- A stub in `test/support/` uses `@behaviour` and `@impl`, backed by an `Agent`, with
  helpers (`set_temperature/2`, `set_error/2`) for controlling test outcomes.

Config selects the real vs mock module at the environment level (host vs target). Tests inject
the stub by passing `{table_name, StubClient}` directly to the GenServer init arg.

**Use behaviour, not protocol.** Behaviour is right when swapping one implementation at
config/compile time. Protocol is only warranted when dispatching over a heterogeneous
*collection* of different value types at runtime — that never occurs here.

To add a new sensor type:

1. Create `lib/thermostat_nerves/sensors/my_client.ex` as a `@behaviour` with `@callback` declarations.
2. Create `lib/thermostat_nerves/sensors/my_real_impl.ex` — real hardware implementation,
   `@behaviour MyClient`, `@impl true` on each callback.
3. Create `lib/thermostat_nerves/sensors/my_mock_impl.ex` — synthetic host implementation,
   `@behaviour MyClient`, `@impl true` on each callback.
4. Create `test/support/my_stub_client.ex` — Agent-backed test stub, `@behaviour MyClient`,
   with `start/2`, `set_value/2`, `set_error/2` helpers. Key the Agent by test PID;
   walk `$ancestors` in the callback to find the owning test process.
5. Create `lib/thermostat_nerves/sensors/my_sensor.ex` as a GenServer.
   - Use `{:continue, :read_sensor}` in `init/1` for initial read.
   - Store readings with `PropertyTable.put(SensorTable, ["my_key"], value)`.
   - Schedule periodic reads with `Process.send_after(self(), :read_sensor, interval)`.
   - Accept `{table_name, client_module}` as the init arg for test injection.
6. Wire config: `host.exs` → `MyMockImpl`, `target.exs` → `MyRealImpl`.
7. Add the GenServer to `children` in `application.ex`.

### Adding a New gRPC Service

1. Define the service in `priv/protos/temperature.proto` (or a new `.proto` file).
2. Run `bash proto_gen.sh` to regenerate code.
3. Create the implementation in `lib/thermostat_nerves/<service>/server.ex`.
4. `use GRPC.Server, service: <GeneratedServiceModule>`.
5. Register it in `endpoint.ex` with `run <YourServer>`.

## Common Pitfalls

- **Never commit `.envrc`** -- it contains WiFi credentials and is gitignored.
- **Never hand-edit generated files** -- `lib/temperature.pb.ex` and
  `flutter_app/lib/generated/` are overwritten by `proto_gen.sh`.
- **Always set `MIX_TARGET=rpi5`** before running firmware commands (`mix firmware`,
  `mix deps.get` for target). Omitting it compiles for host.
- **`list_sensor/0` blocks indefinitely** on host if no DS18B20 is attached. The
  `TemperatureSensor` GenServer is started on host, so test/dev may hang if the
  sensor library returns an empty list.
- **Use `Process.send_after/3`** for periodic work, not `:timer.apply_interval` --
  the codebase convention is explicit message scheduling.
- **PropertyTable keys are string lists**, not atoms or flat strings. Always use
  the form `["temperature"]`, not `:temperature` or `"temperature"`.
- **Config files cannot reference structs at compile time** — structs aren't available
  when config is evaluated. Store the module name (atom) in config and resolve it at
  runtime in `init/1` via `Application.fetch_env!/2`.
- **`$ancestors` PID-keying for test stubs** — `start_supervised!` nests GenServers
  under ExUnit supervisors, so the test PID is not the direct `$callers` parent. Walk
  the full `$ancestors` list and find the first PID with a registered stub agent.
  See `test/support/stub_client.ex` for the pattern.
- **`vintage_net` crashes on host** trying to write `/etc/resolv.conf` — it is a
  device-only library. Its dep entry must have `targets: @all_targets` in `mix.exs`.
- **gRPC server tests: listener name conflict** — the application starts a Ranch listener
  named after `ThermostatNerves.Endpoint` on port 50051. Binding a second endpoint with
  the same name (even on port 0) fails with `:eaddrinuse` because the listener *name* is
  taken, not just the port. Fix: call `GRPC.Server.stop_endpoint/1` to release the name,
  then `GRPC.Server.start_endpoint/2` with port `0`, and restore in `on_exit`.
- **Server-streaming RPCs return `{:ok, Enumerable.t()}`** — do NOT pipe the raw return
  value of `Stub.stream_temperature/2` directly into `Enum`. Unwrap first:
  `{:ok, stream} = Stub.stream_temperature(channel, req)` then `Enum.take(stream, n)`.

## Project-Specific Notes

- **PropertyTable** is the shared state store. Access it via
  `PropertyTable.get(SensorTable, ["temperature"])` and
  `PropertyTable.put(SensorTable, ["temperature"], value)`.
- **gRPC server functions** receive `(request, stream)` args.
  Use `GRPC.Server.send_reply/2` for streaming responses.
- **Host vs Target**: `Mix.target()` determines if code runs on host (dev/test)
  or target (rpi5). Guard target-only children behind
  `if Mix.target() == :host do ... else ... end` at compile time.
- **Config split**: `config/host.exs` for development, `config/target.exs` for
  device. Common config in `config/config.exs`.
- **Flutter app** lives in `flutter_app/`. It is built automatically during the
  Nerves release process. The compiled bundle goes to `priv/flutter_app/`.
- **Flutter on host**: `flutter run -d linux` from `flutter_app/` connects to
  `localhost:50051` unchanged. The `linux/` CMake scaffold is already present.
- **`TemperatureSensor` GenServer injection**: accepts `{table_name, client_module}`
  as its init arg for tests (injecting a stub module atom and isolated `PropertyTable`),
  or `:from_config` for normal startup (reads config via `Application.fetch_env!/2`).
- **`StubClient`** in `test/support/stub_client.ex` is Agent-backed and supports
  `set_temperature/2` and `set_error/2` for controlling test behaviour.

### Dependencies & Tooling

- **asdf** manages tool versions (see `.tool-versions`): `protoc 31.1`,
  `flutter 3.32.8-stable`
- **direnv** loads `.envrc` for environment variables.
- Elixir deps managed via `mix.exs` and `mix.lock`. Run `mix deps.get` after
  changes.
- **`flutter_app/test/widget_test.dart`** has a pre-existing `MyApp` not found
  error — unrelated to this project's work, can be ignored.
