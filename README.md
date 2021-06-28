# DoubleAgent

An Elixir mocking and spying library inspired by [`mox`](https://github.com/dashbitco/mox), [`double`](https://github.com/sonerdy/double) and [this Martin article](https://martinfowler.com/articles/mocksArentStubs.html).

You still use a Mox-like defmock, which defines a behavior implementation, but all it does is start a genserver or agent that tracks the expectations like a spy. It can then delegate to functions, modules, mfas, or custom runtime compiled modules built using macros in the tests. Think how "mock" library or fastglobal works except without actually replacing the original name, which was the main trickiness that Mox wanted to avoid.

## Status
Highly proof-of-concept. This currently implements neither feature-set of `mox` or `double`.

- an early form of `defmock` generates a wrapper around a given module
- a minimal `DoubleAgent.ListeningPost` (there are going to be a lot of spy-based puns) for tracking invocations.
```elixir
iex> GenServer.start_link(DoubleAgent.ListeningPost, [], name: DoubleAgent.ListeningPost)

# defines and compiles CalcMock based on the functions defs of Calc
iex> DoubleAgent.defmock(CalcMock, for: Calc)

iex> CalcMock.add(1,2) # sends it to ListeningPost to record, and delegates to Calc
3

```

### Next Up
- update `ListeningPost` to record invocations separately per PID
- `allow(MyMock, _??, self())` or something similar to `Ecto.SQL.Sandbox.allow`
- extract `allow` functionality to some sort of registry
- `raise` if not `ListeningPost.fetch` or something is called and test process wasn't `allow`-ed
  - assumes that a module was set as the wrapped implementation, a la `Mox.stub_with`
  - `raise` if no implementation was never set, i.e. if only a `behaviour` was used

```elixir
DoubleAgent.defmock(MyMock, for: Basic)

# ListeningPost `state` something like:
allowed_callers = MapSet.new([parent_pid, child_pid, test1_pid])

state = %{
  {MyMock, allowed_callers} => [{parent_pid, {MyMock, :hello, []}}, {child_pid, {MyMock, :foo, [:bar]}}]
}
```


## Roadmap

### 1. MVP for use as a `spy` tool
- [x] hand-written GenServer that tracks invocations of its hard-coded functions
- [x] hand-written GenServer that can "spy"
- [x] ... and delegate to another module,
- [ ] ... or set of anonymous functions, defined at init() (still necessary? maybe `only: [...]` and `except: [...]`)
- [x] `defmock` (or `defspy`) macro for generating thin wrappers that delegate to some GenServers for spying/etc. and `apply` to the wrapped module
- [ ] `allow` of some sort for the `ListeningPost` GenServer(s), where `allow` is more like the `Ecto.SqlSandbox`, for scoping the pids that can call it, (Registry?)
- [ ] make `allow` able to be set as global or something (Registry?)
- [ ] make `set_double_agent_mode` ???

### 2. Additional features needed to use as "Spy" + "Fake"
- [ ] GenServer for implementations, delegating to the wrapped module
- [ ] `allow` extended to implementation GenServer, so it can be set per pid, group of pids, or globally

### 3. Additional features needed to use as a Stub
- [ ] `stub` for the implementation GenServer for individual functions
- [ ] `expect` syntax for anon-functions and MFAs

### Unordered features
- [ ] `defmock` w/ `@behaviour` support/enforcement
- [ ] `assert_receive`/`assert_received` in tests from `ListeningPost` GenServer(s)

### Anticipated Interface:
```elixir
# test/support/mocks.ex
DoubleAgent.defmock(BehavedCalcMock, Calculator) # @behaviour-based generation and enforcement
DoubleAgent.defmock(ConfiguredCalcMock, [add: 2, subtract: 2, ...]) # config-based generation, no enforcement, (maybe only in alpha???)
DoubleAgent.defmock(BareCalcMock) # no generation, no enforcement (probably only in alpha)

# test/support/spies.ex
DoubleAgent.defspy(BehavedCalcSpy, Calculator) # @behaviour-based delegation
DoubleAgent.defspy(ConfiguredCalcSpy, [{Calculator, :add, 2}, {Calculator, :subtract, 2}, ...]) # config-based delegation

# test/example_test.exs
# ...
# any of the mocks

expect(CalcMock, :add, {m,f,a}) # delegates to a mock, essentially treating it like a spy
expect(CalcMock, :add, fn x,y,z -> ... end)
expect(CalcMock, :add, the_actual_function_head_match) # TBD how best to implement this

stub(CalcMock, :add, {m,f,a}) # provides default implementation
stub(CalcMock, :add, fn x,y,z -> ... end) # provides fallback/default implementation, checks matches of `expect`s first
stub(CalcMock, :add, the_actual_function_head_match) # TBD how best to implement this, maybe not worth it?

assert_called(CalcSpy) # maybe???
assert_receive(...) # maybe support both depending on some "mode"?

DoubleAgent.verify(CalcMock)
```

### Why?
I've really liked `Double` and it's approach to using `assert_receive`, but it unfortunately seems to have a limited ability to provide a default implementation at a config level without being called in the config files.
This means that the code under test can't use module attributes or `Application.get_env` without having to also provide a form of dependency injection in the function signature, this might seem trivial, but it ends up having a large impact on people's likelihood to properly isolate their side-effects and use mocks.

I've also liked `Mox` and its ability to provide a global-mode and generate a module that can be used in config.

My aim is to combine these approaches into one library that can support both, and provide examples and guidance on how to implement them and when it might make sense to pick one over the other.

Once the general "module"/`defmock`/`defspy`/etc. approach is functional, I'll turn my focus towards feature-parity with `Double` (or will see if the maintainer of it is interested in merging some of this approach)
## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `double_agent` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:double_agent, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/double_agent](https://hexdocs.pm/double_agent).
