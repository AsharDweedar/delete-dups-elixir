defmodule DeleteDups.DataBase do
  @moduledoc """
  """

  @pool DBConnection.Poolboy

  @doc """
  the `Mongo.find` function returns a **`Mnogo.Cursor`** map, so `Enum.into([])` or `Enum.to_list` to turn it into list

  ```elixir
  %Mongo.Cursor{
    coll: "table name",
    conn: #PID<0.194.0>,
    opts: [slave_ok: true, pool: DBConnection.Poolboy],
    query: %{"keys" => "values"},
    select: nil
  }
  ```
  """
  def find(table, query, opts \\ []), do: Mongo.find(:data_base, table, query, [pool: @pool] ++ opts) |> Enum.to_list

  def find_one(table, query, opts \\ []), do: Mongo.find_one(:data_base, table, query, [pool: @pool] ++ opts)

  def update_one(table, query, update, opts \\ []), do: Mongo.update_one(:data_base, table, query, update, [pool: @pool] ++ opts)

  def insert_one(table, data, opts \\ []), do: Mongo.insert_one(:data_base, table, data, [pool: @pool] ++ opts)

  @spec delete_many(String, map, list) :: {:ok, %Mongo.DeleteResult{deleted_count: Int}} | {:error, any()}
  def delete_many(table, filter, opts \\ []), do: Mongo.delete_many(:data_base, table, filter, [pool: @pool] ++ opts)

  # :bypass_document_validation, :max_time, :projection, :return_document, :sort, :upsert
  # find_one_and_update(topology_pid, coll, filter, update, opts)

  # :limit, :skip, :hint,
  # count(topology_pid, coll, filter, opts)

  # :bypass_document_validation, :max_time, :projection, :return_document, :sort, :upsert, :collation
  # find_one_and_replace(topology_pid, coll, filter, replacement, opts)

  # :max_time, :projection, :sort, :collation
  # find_one_and_delete(topology_pid, coll, filter, opts)

  # :comment, :cursor_type, :max_time, :modifiers, :cursor_timeout, :sort, :projection, :skip
  # find

  # :comment, :cursor_type, :max_time, :modifiers, :cursor_timeout, :projection, :skip
  # find_one

  # :max_time
  # distinct(topology_pid, coll, field, filter, opts)

  # :continue_on_error
  # insert_many(topology_pid, coll, docs, opts) [docs]

  # :upsert
  # replace_one(topology_pid, coll, filter, replacement, opts)
  # update_one(topology_pid, coll, filter, update, opts)
  # update_many(topology_pid, coll, filter, update, opts)

end
