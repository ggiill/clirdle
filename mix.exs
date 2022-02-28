defmodule Clirdle.MixProject do
  use Mix.Project

  def project do
    [
      app: :clirdle,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: [main_module: Clirdle],
      preferred_cli_env: ["escript.build": :prod]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    []
  end
end
