defmodule DeleteDups do
  @moduledoc """
  main function is here.
  """

  @extensions ~w(.png .jpg .giff .tiff .tif .jpeg .bmp)
  @priorties_path File.cwd!() |> Path.join("priorties.txt")

  import DeleteDups.Workers.Scanner
  import DeleteDups.Delete
  alias DeleteDups.DataBase, as: DB
  require Logger

  @doc """
  delete duplictes in provided paths
  opts can have:
    * `:delete` - true or false to decide weather to find dups or find and delete
    * `:priorties_path` - set path to `.txt` file to store prirties at, this can't ba passed along with `:delete` key set to true, so you can set priorties_path before deleting
    * `:extensions` - allowed extensions
  """
  @spec run(any, map) :: map | String
  def run(path, opts \\ %{})
  def run(path, opts) when is_binary(path), do: run([path], opts)

  def run(paths, opts) when is_list(paths) do
    opts = opts || %{}

    with :ok <- setup(opts[:priorties_path]),
         %{"folders" => _n_folders, "files" => _n_files} = conc <-
           find_dups(paths, opts[:priorties_path], opts[:extensions]),
         _ <- IO.inspect(conc, label: "operations conclusion:"),
         _ <- opts_handler(opts) do
      "DONE.........."
    else
      {:error, reason} ->
        Logger.error(
          "some error happened while setting up DataBase and priorties file because: #{reason}"
        )

      _ ->
        Logger.error("unknown error")
    end
  end

  @doc """
  handle different options
  """
  def opts_handler(%{priorties: false} = opts), do: opts[:delete] && delete_matches(:all)

  def opts_handler(opts) do
    cond do
      !opts[:delete] -> store_folders(opts[:priorties_path])
      true -> IO.inspect("can't delete untill priorties_path is set")
    end
  end

  @doc """
  find duplictes in provided paths and store them in db
  """
  @spec find_dups(list, nil, any) :: map
  def find_dups(paths, nil, extensions),
    do: find_dups(paths, IO.inspect(@priorties_path, label: "adding def path to opts"), extensions || @extensions)

  @spec find_dups(list, String, list) :: map
  def find_dups(paths, priorties_path, extensions),
    do:
      paths
      |> Enum.map(
        &Task.async(fn ->
          surfe_folders_recursive(&1, extensions || @extensions, priorties_path)
        end)
      )
      |> Enum.map(&Task.await(&1, 3_000_000))
      |> Enum.reduce(
        &%{"folders" => &1["folders"] + &2["folders"], "files" => &1["files"] + &2["files"]}
      )

  @doc """
  delete all previouse data in DataBase and priorties_path file
  """
  @spec setup(nil) :: :ok | {:error, any()}
  def setup(nil), do: setup(@priorties_path)
  @spec setup(String) :: :ok | {:error, any()}
  def setup(priorties_path) do
    drop_table("paths")
    drop_table("folders")
    File.write(priorties_path, "")
  end

  @spec drop_table(String) :: {:ok, %Mongo.DeleteResult{deleted_count: Int}} | {:error, any()}
  def drop_table(table), do: DB.delete_many(table, %{})
end
