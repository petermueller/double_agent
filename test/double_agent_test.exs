defmodule DoubleAgentTest do
  use ExUnit.Case
  doctest DoubleAgent

  # TODO - reenable once it's converted to some string to be eval'd, so we can do `assert_raise` during runtime, and not compile :'D
  # @tag pending: true
  # test "won't attempt to create a mock for a nonexistent module" do
  # assert_raise(
  #   ArgumentError,
  #   "module NonExistent either does not exist or is not loaded",
  #   fn ->
  #     DoubleAgent.defmock(MyMock, for: NonExistent)
  #   end
  # )
  # end

  # TODO - enable once test stubbing/mocking is implemented
  # @tag pending: true
  # test "can create a mock from a behaviour" do
  #   assert MyBehavedMock = DoubleAgent.defmock(MyBehavedMock, for: MyBehaviour)

  #   # add some stubbing, or something before this
  #   assert MyBehavedMock.hello() == "asdf"
  # end

  test "tracks invocations" do
    test_pid = self()

    assert :world = MyMock.hello()
    assert :foo = MyMock.foo()
    assert :bar = MyMock.foo(:bar)
    assert :baz = MyMock.foo(:baz)

    hello_invokes = [{test_pid, {MyMock, :hello, []}}]
    foo0_invokes = [{test_pid, {MyMock, :foo, []}}]
    foo1_invokes = [{test_pid, {MyMock, :foo, [:baz]}}, {test_pid, {MyMock, :foo, [:bar]}}]
    all_invokes = foo1_invokes ++ foo0_invokes ++ hello_invokes

    assert DoubleAgent.list() == all_invokes

    assert DoubleAgent.fetch(MyMock, :hello, []) == {:ok, hello_invokes}
    assert DoubleAgent.fetch(MyMock, :hello, 0) == {:ok, hello_invokes}

    assert DoubleAgent.fetch(MyMock, :foo, []) == {:ok, foo0_invokes}
    assert DoubleAgent.fetch(MyMock, :foo, 0) == {:ok, foo0_invokes}

    assert DoubleAgent.fetch(MyMock, :foo, [:bar]) ==
             {:ok, [{test_pid, {MyMock, :foo, [:bar]}}]}

    assert DoubleAgent.fetch(MyMock, :foo, 1) == {:ok, foo1_invokes}

    assert DoubleAgent.fetch(MyMock, :foo, :any) ==
             {:ok, foo1_invokes ++ foo0_invokes}
  end

  test "can create a mock from a module" do
    test_pid = self()

    assert :world = MyMock.hello()
    assert DoubleAgent.fetch(MyMock, :hello, []) == {:ok, [{test_pid, {MyMock, :hello, []}}]}
  end
end
