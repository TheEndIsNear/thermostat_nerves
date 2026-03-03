defmodule ThermostatNerves.MixProject do
  use Mix.Project

  @app :thermostat_nerves
  @version "0.1.0"
  @all_targets [:rpi5]

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.18",
      elixirc_paths: elixirc_paths(Mix.env()),
      archives: [nerves_bootstrap: "~> 1.13"],
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: [{@app, release()}],
      dialyzer: [plt_file: {:no_warn, "priv/plts/project.plt"}]
    ]
  end

  def cli do
    [preferred_targets: [run: :host, test: :host]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :runtime_tools],
      mod: {ThermostatNerves.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Dependencies for all targets
      {:nerves, "~> 1.13", runtime: false},
      {:shoehorn, "~> 0.9"},
      {:ring_logger, "~> 0.11"},
      {:toolshed, "~> 0.4"},

      # Allow Nerves.Runtime on host to support development, testing and CI.
      # See config/host.exs for usage.
      {:nerves_runtime, "~> 0.13"},

      # Dependencies for all targets except :host
      {:nerves_pack, "~> 0.7", targets: @all_targets},

      # Dependencies for specific targets
      # NOTE: It's generally low risk and recommended to follow minor version
      # bumps to Nerves systems. Since these include Linux kernel and Erlang
      # version updates, please review their release notes in case
      # changes to your application are needed.
      {:nerves_system_rpi5, "~> 2.0", runtime: false, targets: :rpi5},
      {:vintage_net, "~> 0.13", targets: @all_targets},
      {:vintage_net_wifi, "~> 0.12", targets: @all_targets},
      {:ds18b20_1w, "~> 0.1"},
      {:nerves_flutter_support, "~> 1.3"},
      {:grpc, "~> 0.11"},
      {:protobuf, "~> 0.15"},
      {:protobuf_generate, "~> 0.1"},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
    ]
  end

  def release do
    [
      overwrite: true,
      # Erlang distribution is not started automatically.
      # See https://hexdocs.pm/nerves_pack/readme.html#erlang-distribution
      cookie: "#{@app}_cookie",
      include_erts: &Nerves.Release.erts/0,
      steps: [
        &Nerves.Release.init/1,
        &NervesFlutterSupport.InstallRuntime.run/1,
        &NervesFlutterSupport.BuildFlutterApp.run/1,
        :assemble
      ],
      strip_beams: Mix.env() == :prod or [keep: ["Docs"]]
    ]
  end
end
