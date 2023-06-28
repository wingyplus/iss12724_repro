Mix.install(
  [
    {:dagger, github: "dagger/dagger", sparse: "sdk/elixir"}
  ],
  verbose: true
)

alias Dagger.{Container, Host, Query}

[elixir, otp, platform] =
  case System.argv() do
    [elixir, otp] -> [elixir, otp, "linux/arm64/v8"]
    [elixir, otp, platform] -> [elixir, otp, platform]
  end

client = Dagger.connect!()

source =
  client
  |> Query.host()
  |> Host.directory(".")

client
|> Query.container(platform: platform)
|> Container.from("hexpm/elixir:#{elixir}-erlang-#{otp}-ubuntu-jammy-20230126")
|> Container.with_mounted_directory("/app", source)
|> Container.with_workdir("/app")
|> Container.with_exec(["mix", "local.rebar", "--force"])
|> Container.with_exec(["mix", "local.hex", "--force"])
|> Container.with_exec(["mix", "deps.get"])
|> Container.with_exec(["mix", "compile"])
|> Container.stdout()
