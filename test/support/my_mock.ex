require DoubleAgent
DoubleAgent.defmock(MyMock, for: Basic)
# defmodule MyMock do
#   @source_mod Basic

#   def hello do
#     DoubleAgent.ListeningPost.record({__MODULE__, :hello, []})
#     # find or start a GenServer
#     # inform the GenServer of self(), the function_name, and args
#     # call the implementation

#     apply(@source_mod, :hello, [])
#   end

#   def foo do
#     DoubleAgent.ListeningPost.record({__MODULE__, :foo, []})
#     apply(@source_mod, :foo, [])
#   end

#   def foo(resp) do
#     DoubleAgent.ListeningPost.record({__MODULE__, :foo, [resp]})

#     apply(@source_mod, :foo, [resp])
#   end
# end
