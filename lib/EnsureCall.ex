defmodule EnsureCall do
  use Application

  def start(_type, _args) do
    IO.puts "running"
    ret = ServerA.Sup.start_link()
    #Sample.a()
    ret
  end
end
