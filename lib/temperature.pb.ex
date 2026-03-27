defmodule ThermostatNerves.Empty do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.16.0", syntax: :proto3
end

defmodule ThermostatNerves.UnitRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.16.0", syntax: :proto3

  field :unit, 1, type: :string
end

defmodule ThermostatNerves.TimezoneRequest do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.16.0", syntax: :proto3

  field :timezone, 1, type: :string
end

defmodule ThermostatNerves.TimezoneList do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.16.0", syntax: :proto3

  field :timezones, 1, repeated: true, type: :string
end

defmodule ThermostatNerves.TemperatureReading do
  @moduledoc false
  use Protobuf, protoc_gen_elixir_version: "0.16.0", syntax: :proto3

  field :value, 1, type: :float
  field :unit, 2, type: :string
  field :utc_offset_seconds, 3, type: :int32, json_name: "utcOffsetSeconds"
end

defmodule ThermostatNerves.RPC.Service do
  @moduledoc false
  use GRPC.Service, name: "ThermostatNerves.RPC", protoc_gen_elixir_version: "0.16.0"

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

  rpc(
    :streamTemperature,
    ThermostatNerves.Empty,
    stream(ThermostatNerves.TemperatureReading),
    %{}
  )

  rpc(:setUnit, ThermostatNerves.UnitRequest, ThermostatNerves.Empty, %{
    http: %{
      type: Google.Api.PbExtension,
      value: %Google.Api.HttpRule{
        selector: "",
        body: "*",
        additional_bindings: [],
        response_body: "",
        pattern: {:post, "/unit"},
        __unknown_fields__: []
      }
    }
  })

  rpc(:setTimezone, ThermostatNerves.TimezoneRequest, ThermostatNerves.Empty, %{
    http: %{
      type: Google.Api.PbExtension,
      value: %Google.Api.HttpRule{
        selector: "",
        body: "*",
        additional_bindings: [],
        response_body: "",
        pattern: {:post, "/timezone"},
        __unknown_fields__: []
      }
    }
  })

  rpc(:getTimezones, ThermostatNerves.Empty, ThermostatNerves.TimezoneList, %{
    http: %{
      type: Google.Api.PbExtension,
      value: %Google.Api.HttpRule{
        selector: "",
        body: "",
        additional_bindings: [],
        response_body: "",
        pattern: {:get, "/timezones"},
        __unknown_fields__: []
      }
    }
  })
end

defmodule ThermostatNerves.RPC.Stub do
  @moduledoc false
  use GRPC.Stub, service: ThermostatNerves.RPC.Service
end
