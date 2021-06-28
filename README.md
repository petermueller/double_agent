# DoubleAgent

An Elixir mocking and spying library inspired by [`mox`](https://github.com/dashbitco/mox), [`double`](https://github.com/sonerdy/double) and [this Martin article](https://martinfowler.com/articles/mocksArentStubs.html).

You still use a Mox-like defmock, which defines a behavior implementation, but all it does is start a genserver or agent that tracks the expectations like a spy. It can then delegate to functions, modules, mfas, or custom runtime compiled modules built using macros in the tests. Think how "mock" library or fastglobal works except without actually replacing the original name, which was the main trickiness that Mox wanted to avoid.

## Status
Highly proof-of-concept. This currently implements neither feature-set of `mox` or `double`.

## Roadmap

1. hand-written GenServer that tracks invocations of its hard-coded functions
2. hand-written GenServer that can "spy" and delegate to another module, or set of anonymous functions, defined at init()
3. GenServer that can have its implementation "programmed" after it's started
4. `expect` syntax for anon-functions and MFAs
5. `use DoubleAgent, [{Mod, :func, arity}, ...]` for writing static spy-modules that you want to wrap other modules
6. Others, to-be-updated
  - `defmock` w/ `@behaviour` support/enforcement that generates the genserver "spy" module
  - `expect(...)` and other "programming" functions somehow generate a custom module that is delegated to by the "spy"
  - maybe a `defspy` that requires a `@behaviour`???
  - `dbl = DoubleAgent.double()` maybe???

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
I've really liked `double` and it's approach to using `assert_receive`, but it unfortunately limits it's ability to provide a default implementation at a config level. This means that the code under test can't use module attributes or `Application.get_env` without having to also provide a form of dependency injection in the function signature, this might seem trivial, but it ends up having a large impact on people's likelihood to properly isolate their side-effects and use mocks.

I've also like `mox` and its ability to provide a global-mode and generate a module that can be used in config.

My aim is to combine these approaches into one library that can support both, and provide examples and guidance on how to implement them and when it might make sense to pick one over the other.
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
