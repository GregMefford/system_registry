defmodule SystemRegistry.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    registries =
      Enum.map([Registration, Binding, State], fn(reg) ->
        reg = Module.concat(SystemRegistry.Storage, reg)
        reg_sup = Module.concat(reg, Supervisor)
        supervisor(Registry, [:unique, reg,
          [partitions: System.schedulers_online]],
          [id: reg_sup])
      end)
    # Define workers and child supervisors to be supervised
    workers = [
      worker(SystemRegistry.Local, []),
      worker(SystemRegistry.Global, []),
      worker(SystemRegistry.Registration, []),
      worker(SystemRegistry.Processor.State, []),
      worker(SystemRegistry.Processor.Config, []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SystemRegistry.Supervisor]
    Supervisor.start_link(registries ++ workers, opts)
  end
end
