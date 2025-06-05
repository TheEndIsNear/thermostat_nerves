# Tool to aid in generate the protobuf code generation.
# You probably do not need to run this tool unless you modify the protobuf files in this example.
export PATH="$PATH":"$HOME/.pub-cache/bin"
mix protobuf.generate --include-path=priv/protos --plugin=ProtobufGenerate.Plugins.GRPCWithOptions --output-path=./lib priv/protos/temperature.proto
protoc -I priv/protos/google/api/ -I priv/protos/ priv/protos/temperature.proto --dart_out=grpc:flutter_app/lib/generated
