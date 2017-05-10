defmodule SystemRegistry.Processor.Config do
  use SystemRegistry.Processor

  @mount :config

  #alias SystemRegistry.Storage.Binding, as: B
  alias SystemRegistry.Transaction

  def init(_) do
    opts = Application.get_env(:system_registry, SystemRegistry.Processor.Config)
    {:ok, %{opts: opts, priorities: opts[:priorities], producers: []}}
  end

  def handle_validate(%Transaction{} = _t, s) do
    {:ok, :ok, s}
  end

  def handle_commit(%Transaction{} = _t, s) do
    # :erlang.process_info(t.pid, [:initial_call])
    # |> IO.inspect()
    # mount = s.opts[:mount] || @mount
    # updates = Map.get(t.updates, mount)
    # deletes = Enum.filter(t.deletes, fn
    #   [^mount | _] -> true
    #   _ -> false
    # end)
    #
    # modified? =
    #   apply_updates(updates, mount) or apply_deletes(deletes)
    #
    # if modified? do
    #   global = SystemRegistry.match(:global, :_)
    #   Registration.notify(:global, global)
    # end
    {:ok, :ok, s}
  end

  # def apply_updates(nil, _), do: false
  # def apply_updates(updates, mount) do
  #
  #
  #   updates = Map.put(%{}, mount, updates)
  #   case Global.apply_updates(updates) do
  #     {_, _} -> true
  #     error -> false
  #   end
  # end
  #
  # def apply_deletes([]), do: false
  # def apply_deletes(deletes) do
  #
  #
  #   case Global.apply_deletes(deletes) do
  #     {:ok, _} -> true
  #     error -> false
  #   end
  # end

end
