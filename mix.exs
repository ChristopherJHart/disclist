defmodule Disclist.MixProject do
  use Mix.Project

  def project do
    [
      app: :disclist,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :inets, :ssl],
      mod: {Disclist.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nostrum, git: "https://github.com/Kraigie/nostrum.git"},
      {:tesla, "~> 1.2"},
      {:floki, "~> 0.20.4"},
      {:timex, "~> 3.4"},
      {:postgrex, "~> 0.14.1"},
      {:ecto_sql, "~> 3.0"},
      {:plug_cowboy, "~> 2.0"}
    ]
  end
end
