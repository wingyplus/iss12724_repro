Mix.install(
  [
    {:dagger, github: "dagger/dagger", sparse: "sdk/elixir"}
  ],
  verbose: true
)

alias Dagger.{Container, Host, Query}

client = Dagger.connect!()

source =
  client
  |> Query.host()
  |> Host.directory(".")

client
|> Query.container(platform: "linux/arm64/v8")
|> Container.from("hexpm/elixir:1.15.0-erlang-26.0.1-ubuntu-jammy-20230126")
|> Container.with_mounted_directory("/app", source)
|> Container.with_workdir("/app")
|> Container.with_exec(["mix", "local.rebar", "--force"])
|> Container.with_exec(["mix", "local.hex", "--force"])
|> Container.with_exec(["mix", "deps.get"])
|> Container.with_exec(["mix", "compile"])
|> Container.stdout()
