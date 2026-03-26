import Config

runtime_zone =
  System.get_env("TIME_ZONE") ||
    "America/Denver"

config :nerves_time_zones,
  default_time_zone: runtime_zone
