defmodule DoubleAgent do
  @moduledoc """
  Documentation for `DoubleAgent`.
  """

  defdelegate list(), to: DoubleAgent.ListeningPost
  defdelegate fetch(mod, func, args_arity_or_atom), to: DoubleAgent.ListeningPost

  # TODO - document the SHIT out of this
  defmacro defmock(mock_name, for: source) do
    mock_name = Macro.expand(mock_name, __CALLER__)
    source = Macro.expand(source, __CALLER__)

    unless Code.ensure_compiled(source) == {:module, source} do
      raise(ArgumentError, "module #{inspect(source)} either does not exist or is not loaded")
    end

    func_defs =
      for {func_name, arity} <- source.__info__(:functions) do
        args = Macro.generate_arguments(arity, source)

        quote do
          def unquote(func_name)(unquote_splicing(args)) do
            IO.puts("Hello from #{unquote(func_name)}")

            DoubleAgent.ListeningPost.record(
              {unquote(mock_name), unquote(func_name), [unquote_splicing(args)]}
            )

            # TODO - resume here
            # DoubleAgent.Handoff.call(
            #   {unquote(source), unquote(func_name), [unquote_splicing(args)]}
            # )

            apply(unquote(source), unquote(func_name), [unquote_splicing(args)])
          end
        end
      end

    quote do
      defmodule unquote(mock_name) do
        unquote(func_defs)
      end
    end
  end
end
