defmodule SystemRegistry.Processor.ConfigTest do
  use ExUnit.Case, async: true
  require SystemRegistry
  alias SystemRegistry, as: SR

  @config [
    priority: [

    ]
  ]

  Application.put_env(:system_registry, SR.Processor.Config, @config)

  setup ctx do
    %{root: ctx.test}
  end

  test "configs are merged in order of priority", %{root: root} do
    scope = [:config, root, :a]
    value = 1
    SR.update(:system_registry, scope, value)
  end

end
