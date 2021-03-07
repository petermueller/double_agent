defmodule DoubleAgentTest do
  use ExUnit.Case
  doctest DoubleAgent

  test "greets the world" do
    assert DoubleAgent.hello() == :world
  end
end
