defmodule DeleteDups.Mixfile do
  use Mix.Project

  def project do
    [
      app: :delete_dups,
      version: "0.0.0",
      build_path: "./_build",
      config_path: "./config/config.exs",
      deps_path: "./deps",
      lockfile: "./mix.lock",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      applications: [:que],
      extra_applications: [:logger, :mongodb, :poolboy],
      mod: {DeleteDups.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:mongodb, "~> 0.4.3"},
      {:confex, "~> 3.3.1"},
      {:poolboy, "~> 1.5.1"},
      {:que, "~> 0.5.0"}
    ]
  end
end
