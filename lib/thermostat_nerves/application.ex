defmodule ThermostatNerves.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  alias NervesFlutterSupport.Flutter.Engine
  alias NervesFlutterSupport.Udev

  @impl Application
  def start(_type, _args) do
    children =
      [
        # Children for all targets
        # Starts a worker by calling: ThermostatNerves.Worker.start_link(arg)
        # {ThermostatNerves.Worker, arg},
        {PropertyTable, name: SensorTable},
        ThermostatNerves.Sensors.TemperatureSensor,
        {GRPC.Server.Supervisor,
         endpoint: ThermostatNerves.Endpoint, port: 50_051, start_server: true}
      ] ++ target_children()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ThermostatNerves.Supervisor]

    with {:ok, pid} <- Supervisor.start_link(children, opts) do
      # Mark firmware as valid so the automatic rollback mechanism in
      # nerves_system_rpi5 v2+ does not revert to the previous version.
      Nerves.Runtime.validate_firmware()
      {:ok, pid}
    end
  end

  # List all child processes to be supervised
  if Mix.target() == :host do
    defp target_children do
      [
        # Children that only run on the host during development or test.
      ]
    end
  else
    defp target_children do
      [
        # Children for all targets except host
      ] ++ flutter_children()
    end
  end

  defp flutter_children do
    # Bit of a hack, but we need to wait for /dev/dri to exists...
    Logger.info("Looking for the output card to use")
    dri_card = get_output_card()

    Logger.info("Dri Card: #{dri_card}")

    launch_env = %{
      "FLUTTER_DRM_DEVICE" => "/dev/dri/#{dri_card}",
      # Override GBM_BACKENDS_PATH to use the system's DRI backend instead of the
      # (missing) one in nerves_flutter_support's priv dir
      "GBM_BACKENDS_PATH" => "/usr/lib/gbm",
      # Append /usr/lib so the system's dri_gbm.so can find its matching libgallium
      "LD_LIBRARY_PATH" => "/usr/lib:#{:code.priv_dir(:nerves_flutter_support)}/lib",
      "GALLIUM_HUD" => "cpu+fps",
      "GALLIUM_HUD_PERIOD" => "0.25",
      "GALLIUM_HUD_SCALE" => "3",
      "GALLIUM_HUD_VISIBLE" => "false",
      "GALLIUM_HUD_TOGGLE_SIGNAL" => "10"
    }

    [
      # Create a child that runs the Flutter embedder.
      # The `:app_name` matches this application, since it contains the AOT bundle at `priv/flutter_app`.
      # See the doc annotation for `create_child/1` for all valid options.
      Engine.create_child(
        app_name: :thermostat_nerves,
        env: launch_env
      )
    ]
  end

  defp get_output_card do
    Process.sleep(100)
    output = Udev.get_cards() |> Enum.find(fn card -> Udev.is_output_card?(card) end)
    Logger.info("Output from gettting card: #{output}")

    if is_nil(output) do
      get_output_card()
    else
      output
    end
  end
end
