defmodule DoubleAgent.ListeningPost do
  use GenServer

  ### CLIENT

  def fetch(module, func, args_arity_or_atom) do
    GenServer.call(__MODULE__, {:fetch, {module, func, args_arity_or_atom}})
  end

  def list do
    GenServer.call(__MODULE__, :list)
  end

  def record({_mod, _function_name, _args} = mfa) do
    GenServer.call(__MODULE__, {:record, mfa})
  end

  ### SERVER & CALLBACKS

  @impl GenServer
  def init(state \\ []) do
    {:ok, state}
  end

  @impl GenServer
  def handle_call({:fetch, fetch_args}, _from, state) do
    result =
      case Enum.filter(state, &invoke_matches?(&1, fetch_args)) do
        [] -> :error
        invokes -> {:ok, invokes}
      end

    {:reply, result, state}
  end

  def handle_call(:list, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:record, mfa}, {pid, _tag} = _from, state) do
    state = [{pid, mfa} | state]
    {:reply, state, state}
  end

  @type invocation :: {pid(), mfargs()}
  @type mfargs :: {module :: atom(), function_name :: atom(), args :: list()}
  @type matcher :: {module(), atom(), :any}
  @type mfargs_mfa_or_matcher :: mfargs() | mfa() | matcher()

  @spec invoke_matches?(invocation(), mfargs_mfa_or_matcher()) :: boolean()
  def invoke_matches?({_pid, {mod, func, _args}}, {mod, func, :any}), do: true

  def invoke_matches?({_pid, {m, f, args}}, {m, f, arity}) when is_integer(arity),
    do: length(args) == arity

  def invoke_matches?({_pid, {mod, func, args}}, {mod, func, args}) when is_list(args), do: true
  def invoke_matches?({_pid, _invoked_mfa}, _fetch_args), do: false
end
