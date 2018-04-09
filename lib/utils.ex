defmodule DeleteDups.Utils do
  @moduledoc """
  """

  alias DeleteDups.DataBase
  require Logger

  @priorties_path File.cwd! |> Path.join("priorties.txt")


  @doc """
  hash function taken from answer in "https://stackoverflow.com/questions/41008487/how-can-i-calculate-a-file-checksum-in-elixir"

  is unique and the same for any given file, 64 long string

  ## Examples

      iex> import DeleteDups.Hasher
      iex> hash("./test/support/tests_helper.txt")
      "C07C5A7FA0A166D4927CFB1B44CD86AAA1EE2D9DF77DA0B0D6D30008F3D93D9D"
      iex> hash("./test/support/tests_helper (same content).txt")
      "C07C5A7FA0A166D4927CFB1B44CD86AAA1EE2D9DF77DA0B0D6D30008F3D93D9D"
      iex> hash("./test/support/tests_helper (different content).txt")
      "05DBEF76A0953DDB06459DD7B31A05C5EFC18744B4F926FEFCE4662AC1E0F5F6"

  """
  @spec hash(String.t()) :: String.t()
  def hash(file_path) do
    file_path
    |> File.stream!([],2048)
    |> Enum.reduce(:crypto.hash_init(:sha256),fn(line, acc) -> :crypto.hash_update(acc,line) end )
    |> :crypto.hash_final
    |> Base.encode16
  end

  @doc """
  surfe all files and folders in the passed path
  hash the file
  call handle DB
  """
  @spec surfe_folders_recursive(String.t(), list, String.t(), map) :: map
  def surfe_folders_recursive(path, extensions, priorties_path, conclusion \\ %{"folders" => 0, "files" => 0}) do
    update_folders(path, conclusion["folders"], priorties_path)

    path
    |> File.ls!
    |> Enum.reduce(conclusion, fn(file, sub_conc) ->
      full_path = Path.join(path, file)
      case full_path |> File.dir? do
        true ->
          new_conc =
          surfe_folders_recursive(full_path, extensions, priorties_path, %{sub_conc | "folders" => (1 + sub_conc["folders"])})
        false ->
          ex = Path.extname(file) |> String.downcase()
          if (ex in extensions), do: (full_path |> hash() |> handle_db(full_path))
          %{sub_conc | "files" => (1 + sub_conc["files"])}
      end
    end)
  end

  @doc """
  check the path existance in db
  add if not exist
  """
  @spec handle_db(String.t(), String.t()) :: any
  def handle_db(hash, path) do
    case DataBase.find_one("paths", %{"hash" => hash}) do
      nil ->
        DataBase.insert_one("paths", %{"hash" => hash, "paths" => [path]})

      %{"paths" => paths} ->
        case paths |> Enum.member?(path) do
          false -> DataBase.update_one("paths", %{"hash" => hash}, %{"$set" => %{"paths" => [path | paths]}})
          true -> nil
        end
    end
  end

  @doc """
  store all folders searched in DB and priorties file.txt
  """
  @spec update_folders(String.t(), Int, String.t()) :: :ok | {:error, any}
  def update_folders(path, n_folders, priorties_path \\ @priorties_path) do
    content = priorties_path |> File.read!()

    case String.contains?(content, "*#*" <> path <> "\n") do
      true -> :ok
      false ->
        new_content = content <> to_string(n_folders) <> "*#*" <> path <> "\n"

        case File.write(priorties_path, new_content) do
          :ok -> :ok
          {:error, reason} -> Logger.warn("coudn't write to path: #{path} to #{priorties_path} because error: #{reason}")
        end
    end
  end

  @doc """
  store proirties of folders in db
  """
  @spec store_folders(nil) :: :ok
  def store_folders(nil), do: store_folders(@priorties_path)
  @spec store_folders(String.t()) :: :ok
  def store_folders(priorties) do
    priorties
    |> File.read!()
    |> String.split("\n")
    |> Enum.each(fn line ->
      if line != "" do
        [order, path] = line |> String.split("*#*")
        query = %{"name" => path, "order" => order}
        case DataBase.find_one("folders", query) do
          nil -> DataBase.insert_one("folders", query)
          _path -> nil
        end
      end
    end)
  end

  @doc """
  delete files according to thier priority if tag is :sorted, if tag is :all will delete all matches and keep one no matter the folder
  """
  @spec delete_matches(atom) :: :ok
  def delete_matches(tag) when is_atom(tag) do
    # TODO:
    # find some way to get  %{"paths" => when_value_is %{"$gt" => 0}}
    DataBase.find("paths", %{})
    |> Enum.each(fn %{"paths" => paths} -> delete_matches(tag, paths, (paths|> length) -1) end)
  end
  @doc """
  delete matches of one file that have been scaned and stored in db
  """
  @spec delete_matches(String.t()) :: [:ok | {:error, any}]
  def delete_matches(hash) do
    %{"paths" => paths} = DataBase.find_one("paths", %{"hash" => hash})
    case paths |> length do
      1 -> [:ok]
      n -> delete_matches(hash, paths, n-1)
    end
  end
  @spec delete_matches(:all, list,integer()) :: [any]
  def delete_matches(:all, paths, n) do

    IO.inspect paths
    IO.inspect n
    delete_from(paths, n)
  end
  @spec delete_matches(:sorted, String.t(), Int) :: [:ok | {:error, any}]
  def delete_matches(:sorted, paths, n), do: delete_from(sorter(paths), n)

  @doc false
  defp sorter(paths) do
    paths
    |> Enum.sort(fn path1, path2 ->
      %{"order" => order1} = DataBase.find_one("folders", %{"name" => path1 |> Path.dirname})
      %{"order" => order2} = DataBase.find_one("folders", %{"name" => path2 |> Path.dirname})
      (order2|> Integer.parse) >= (order1|> Integer.parse)
    end)
  end

  @doc false
  @spec delete_from(list, integer()) :: [any]
  defp delete_from(list, n) when n >= 1 do
    for n <- 1..n do
      list |> Enum.at(n) |> IO.inspect(label: "deleteing:") |> File.rm()
    end
  end
  defp delete_from(_list, _n), do: []
end
