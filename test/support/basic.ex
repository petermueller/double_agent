defmodule Basic do
  def hello do
    :world
  end

  def foo(resp \\ :foo) do
    resp
  end
end
