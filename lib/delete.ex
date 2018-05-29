defmodule DeleteDups.Delete do
  @moduledoc """
  """

  alias DeleteDups.DataBase, as: DB
  require Logger

  @doc """
  delete files according to thier priority if tag is :sorted, if tag is :all will delete all matches and keep one no matter the folder
  """
  @spec delete_matches(atom) :: :ok
  def delete_matches(tag) when is_atom(tag) do
    DB.find("paths", %{"$where" => "(this.paths.length > 1)"})
    |> Enum.each(fn %{"paths" => paths} -> delete_matches(tag, paths, (paths|> length) -1) end)
  end
  @doc """
  delete matches of one file that have been scaned and stored in db
  """
  @spec delete_matches(String) :: [:ok | {:error, any}]
  def delete_matches(hash) do
    case DB.find_one("paths", %{"hash" => hash, "$where" => "(this.paths.length > 1)"}) do
      nil -> [:ok]
      %{"paths" => paths} -> delete_matches(:all, paths, length(paths) - 1)
    end
  end
  @spec delete_matches(:all, list, integer()) :: [any]
  def delete_matches(:all, paths, n), do: delete_from(paths, n)
  @spec delete_matches(:sorted, String, Int) :: [:ok | {:error, any}]
  def delete_matches(:sorted, paths, n), do: delete_from(sorter(paths), n)

  @doc false
  @spec sorter(list) :: list
  defp sorter(paths) do
    paths
    |> Enum.sort(fn path1, path2 ->
      get_order(path1 |> Path.dirname) >= get_order(path2 |> Path.dirname)
    end)
  end

  @doc """
  set up order priorty for given path
  """
  @spec get_order(String) :: Integer
  def get_order(""), do: 1000
  def get_order(folder) do
    case DB.find_one("folders", %{"name" => folder}) do
      %{"order" => order1} -> order1 |> Integer.parse
      nil -> get_order(folder |> Path.dirname)
    end
  end

  @doc false
  @spec delete_from(list, integer()) :: [any]
  defp delete_from(list, n) when n >= 1 do
    for n <- 1..n do
      list |> Enum.at(n) |> IO.inspect(label: "deleteing:") |> File.rm()
    end
  end
  defp delete_from(_list, _n), do: []

  @doc """
  scan a folder and all it's sub_folders for a specific folder/file name and delete it
  ps: this function is not used @(^_^)@
  """
  def delete_by_name(path, name) do
    path
    |> File.ls!
    |> Enum.reduce(0, fn(file, acc) ->
      full_path = Path.join(path, file)
      acc =
        case file do
          name ->
            Logger.info("deleting: #{full_path}")
            File.rm_rf(full_path)
            acc + 1
          _ -> acc
        end
      case full_path |> File.dir? do
        true -> acc + delete_by_name(full_path, name)
        false -> acc
      end
    end)
  end
end
