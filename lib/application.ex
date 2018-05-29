defmodule DeleteDups.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: true
    children = [
      worker(Mongo, [Confex.get_env(:delete_dups, :mongo_config)])
    ]

    check_priorties_file()
    if !System.get_env("DATA_BASE") do
      raise "please provide the DATA_BASE name by exporting it in your shell or change the './config/config.exs' file to use fixed DATA_BASE name"
    end
    opts = [strategy: :one_for_one, name: DeleteDups.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @doc """
  if priorties.txt does not exists then create it
  """
  def check_priorties_file() do
    file = File.cwd! |> Path.join("priorties.txt")
    case File.stat(file) do
      {:error, _reason} -> File.touch!(file)
      _state -> nil
    end
  end
end
