defmodule ThermostatNerves.Empty do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.14.1", syntax: :proto3
end

defmodule ThermostatNerves.TemperatureReading do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.14.1", syntax: :proto3

  field :value, 1, type: :float
  field :unit, 2, type: :string
end

defmodule ThermostatNerves.RPC.Service do
  @moduledoc false

  use GRPC.Service, name: "ThermostatNerves.RPC", protoc_gen_elixir_version: "0.14.1"

  rpc(:sendTemperature, ThermostatNerves.Empty, ThermostatNerves.TemperatureReading, %{
    http: %{
      type: Google.Api.PbExtension,
      value: %Google.Api.HttpRule{
        selector: "",
        body: "",
        additional_bindings: [],
        response_body: "",
        pattern: {:get, "/temperature"},
        __unknown_fields__: []
      }
    }
  })
end

defmodule ThermostatNerves.RPC.Stub do
  @moduledoc false

  use GRPC.Stub, service: ThermostatNerves.RPC.Service
end
