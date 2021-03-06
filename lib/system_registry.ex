defmodule SystemRegistry do
  @moduledoc """
  The System Registry is a global storage and dispatch system for state and configuration.
  Processes can supply state and expose configuration for other processes to query.
  """

  @type scope ::
    {:state | :config, group :: atom, component :: term}

  alias SystemRegistry.{Local, Transaction, Registration}
  alias SystemRegistry.Storage.State, as: S
  import SystemRegistry.Utils

  @doc """
  Returns a transaction struct to pass to update/3 and delete/4 to chain
  modifications to to group. Prevents notifying registrants for each action.
  """
  @type transaction :: Transaction.t
  def transaction() do
    Transaction.begin
  end

  @doc """
  Commit a transaction. Attempts to apply all changes. If successful, will notify_all.
  """
  @spec commit(Transaction.t) ::
    {:ok, map} | {:error, term}
  def commit(transaction) do
    GenServer.call(Local, {:commit, transaction})
  end

  @doc """
    Execute an transaction to insert or modify state, or config
  """
  @spec update(scope :: tuple, value :: term) ::
    {:ok, map} | {:error, term}
  def update(scope, value) do
    transaction()
    |> update(scope, value)
    |> commit()
  end

  @spec update(Transaction.t, scope :: tuple, value :: term) ::
    {:ok, map} | {:error, term}
  def update(transaction, scope, value) do
    Transaction.update(transaction, scope, value)
  end

  @doc """
    Execute an transaction to delete keys
  """
  @spec delete(scope) ::
    {:ok, map} | {:error, term}
  def delete(scope) do
    transaction()
    |> delete(scope)
    |> commit()
  end

  @spec delete(Transaction.t, scope) ::
    {:ok, map} | {:error, term}
  def delete(transaction, scope) do
    Transaction.delete(transaction, scope)
  end

  @doc """
  Delete all keys owned by the calling process
  """
  @spec delete_all(pid) ::
    {:ok, map} | {:error, term}
  def delete_all(pid \\ nil) do
    GenServer.call(Local, {:delete_all, (pid || self())})
  end

  @doc """
  Query the SystemRegistry using a match spec
  """
  @spec match(key :: term, match_spec :: term) :: map
  def match(key \\ :global, match_spec) do
    value =
      Registry.match(S, key, match_spec) |> strip()
    case value do
      [] -> %{}
      value -> value
    end
  end

  @doc """
    Register process to receive notifications
  """
  @spec register(key :: term, interval :: integer) ::
    {:ok, map} | {:error, term}
  def register(key \\ :global, interval) do
    case Registration.registered?(key) do
      true -> {:error, :already_registered}
      false -> Registration.register(key, interval)
    end
  end

  @doc """
    Unregister process from receiving notifications
  """
  @spec unregister(key :: term) ::
    :ok | {:error, term}
  def unregister(key) do
    Registration.unregister(key)
  end

  @doc """
    Unregister process from receiving notifications
  """
  @spec unregister_all(pid) ::
    :ok | {:error, term}
  def unregister_all(pid \\ nil) do
    Registration.unregister_all((pid || self()))
  end

end
