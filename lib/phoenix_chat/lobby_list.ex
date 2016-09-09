defmodule PhoenixChat.LobbyList do

  @table __MODULE__

  @doc """
  Create an :ets table for this module.
  """
  def init do
    opts = [:public, :named_table, {:write_concurrency, true}, {:read_concurrency, false}]
    # set read_concurrency to true if you have multiple admins/users reading the table at the same time..
    # set write_concurrency to false if you mostly read data and do few writes...
    # both should not be set to true because you can get lock contentions...  so ETS is not a good example for that 
    :ets.new(@table, opts)
  end

  def insert(uuid) do
    :ets.insert(@table, {uuid})
  end

  def delete(uuid) do
    :ets.delete(@table, uuid)
  end

  @doc """
  This returns a list of ids stored in the `PhoenixChat.LobbyList` table.
  We return all values in the table but match on the element stored in the
  tuple. That way, a stored value of `{1}`, is returned as `1`.
  """
  def all do
    @table
    |> :ets.match({:'$1'})
    |> Enum.map(fn [item] -> item end)
  end

  @doc """
  Returns `true` if a uuid exists in this module's :ets table.
  """
  def exists?(uuid) do
    case :ets.lookup(@table, uuid) do
      [{^uuid}] ->
        true
      [] ->
        false
    end
  end
end