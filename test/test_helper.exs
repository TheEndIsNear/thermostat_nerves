ExUnit.start()

# Start the gRPC client supervisor so tests can open client channels.
{:ok, _} = DynamicSupervisor.start_link(strategy: :one_for_one, name: GRPC.Client.Supervisor)
