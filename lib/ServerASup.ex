defmodule ServerA.Sup do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def start_child(id) do
    #IO.puts "start_child #{id}"
    ret = Supervisor.start_child(__MODULE__, [id])
    #:io.format "ret ~p~n", [ret]
    ret
  end

  def init(:ok) do
    children = [
      worker(ServerA, [], restart: :temporary)
    ]
    IO.puts "sup init"
    supervise(children, strategy: :simple_one_for_one)
  end
end
